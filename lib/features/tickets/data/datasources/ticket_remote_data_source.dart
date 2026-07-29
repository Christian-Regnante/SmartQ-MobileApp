import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../shared/enums/ticket_status.dart';
import '../models/ticket_model.dart';
import '../models/cancelled_ticket_model.dart';

abstract class TicketRemoteDataSource {
  Future<TicketModel> joinQueue({
    required String organizationId,
    required String serviceId,
    required String userId,
    required String phoneNumber,
  });

  Stream<TicketModel?> streamActiveTicket(String userId);

  Stream<List<TicketModel>> streamTicketHistory(String userId);

  Stream<List<CancelledTicketModel>> streamUserCancelledTickets(String userId);

  Future<void> cancelTicket(
    String ticketId, {
    String? userId,
    String? cancelledBy,
    String? cancellationReason,
  });
}

class TicketRemoteDataSourceImpl implements TicketRemoteDataSource {
  final FirebaseFirestore _firestore;

  TicketRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<TicketModel> joinQueue({
    required String organizationId,
    required String serviceId,
    required String userId,
    required String phoneNumber,
  }) async {
    try {
      return await _firestore.runTransaction((transaction) async {
        // Prevent multiple active tickets per user
        final activeUserTickets = await _firestore
            .collection(FirebaseConstants.ticketsCollection)
            .where('userId', isEqualTo: userId)
            .where('status', whereIn: [TicketStatus.waiting.value, TicketStatus.serving.value])
            .get();

        if (activeUserTickets.docs.isNotEmpty) {
          final existingNum = activeUserTickets.docs.first.data()['ticketNumber'] ?? 'active';
          throw ServerException('You already have an active ticket (#$existingNum) in the queue.');
        }

        // Fetch organization name directly from firestore document
        final orgRef = _firestore.collection('organizations').doc(organizationId);
        final orgDoc = await transaction.get(orgRef);
        final realOrgName = orgDoc.exists ? (orgDoc.data()?['name'] as String? ?? 'Organization') : 'Organization';

        // Fetch service details
        final serviceRef = _firestore.collection('services').doc(serviceId);
        final serviceDoc = await transaction.get(serviceRef);

        if (!serviceDoc.exists) {
          throw const ServerException('Service not found');
        }

        final serviceData = serviceDoc.data()!;
        final serviceName = serviceData['name'] as String? ?? 'Service';
        final prefix = serviceData['prefix'] as String? ?? 'T';
        final currentCount = (serviceData['currentQueueCount'] as num?)?.toInt() ?? 0;
        final lastTicketNum = (serviceData['lastTicketNumber'] as num?)?.toInt() ?? 0;

        final nextTicketSeq = lastTicketNum + 1;
        final ticketNumber = '$prefix${nextTicketSeq.toString().padLeft(3, '0')}';
        final estimatedWait = (currentCount + 1) * 10; // 10 mins average per ticket

        final newTicketRef = _firestore.collection(FirebaseConstants.ticketsCollection).doc();

        final ticketModel = TicketModel(
          id: newTicketRef.id,
          ticketNumber: ticketNumber,
          userId: userId,
          organizationId: organizationId,
          organizationName: realOrgName,
          serviceId: serviceId,
          serviceName: serviceName,
          phoneNumber: phoneNumber,
          status: TicketStatus.waiting,
          position: currentCount + 1,
          estimatedWaitMinutes: estimatedWait,
          createdAt: DateTime.now(),
        );

        transaction.set(newTicketRef, ticketModel.toFirestore());

        transaction.update(serviceRef, {
          'currentQueueCount': currentCount + 1,
          'lastTicketNumber': nextTicketSeq,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        return ticketModel;
      });
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to join queue: ${e.toString()}');
    }
  }

  @override
  Stream<TicketModel?> streamActiveTicket(String userId) {
    return _firestore
        .collection(FirebaseConstants.ticketsCollection)
        .where('userId', isEqualTo: userId)
        .where('status', whereIn: [
          TicketStatus.waiting.value,
          TicketStatus.serving.value,
        ])
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          return TicketModel.fromFirestore(snapshot.docs.first);
        });
  }

  @override
  Stream<List<TicketModel>> streamTicketHistory(String userId) {
    return _firestore
        .collection(FirebaseConstants.ticketsCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final tickets = snapshot.docs
              .map((doc) => TicketModel.fromFirestore(doc))
              .where((t) => t.status == TicketStatus.done || t.status == TicketStatus.cancelled)
              .toList();
          tickets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return tickets;
        });
  }

  @override
  Stream<List<CancelledTicketModel>> streamUserCancelledTickets(String userId) {
    return _firestore
        .collection('cancelledTickets')
        .where('clientId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => CancelledTicketModel.fromFirestore(doc))
              .toList();
          list.sort((a, b) => b.cancelledAt.compareTo(a.cancelledAt));
          return list;
        });
  }

  @override
  Future<void> cancelTicket(
    String ticketId, {
    String? userId,
    String? cancelledBy,
    String? cancellationReason,
  }) async {
    try {
      DocumentSnapshot<Map<String, dynamic>>? targetDoc;
      if (ticketId.isNotEmpty) {
        final doc = await _firestore.collection(FirebaseConstants.ticketsCollection).doc(ticketId).get();
        if (doc.exists) {
          targetDoc = doc;
        }
      }

      if (targetDoc == null && userId != null && userId.isNotEmpty) {
        final snap = await _firestore
            .collection(FirebaseConstants.ticketsCollection)
            .where('userId', isEqualTo: userId)
            .where('status', whereIn: [TicketStatus.waiting.value, TicketStatus.serving.value])
            .get();
        if (snap.docs.isNotEmpty) {
          targetDoc = snap.docs.first;
        }
      }

      if (targetDoc == null || !targetDoc.exists) {
        throw const ServerException('Ticket not found or already processed.');
      }

      final actualTicketId = targetDoc.id;
      final ticketData = targetDoc.data() ?? {};
      final clientUserId = ticketData['userId'] as String? ?? userId ?? '';
      final orgId = ticketData['organizationId'] as String? ?? '';
      final serviceId = ticketData['serviceId'] as String? ?? '';
      final queueNum = ticketData['ticketNumber'] as String? ?? 'Ticket';
      final currentStatus = ticketData['status'] as String? ?? 'waiting';

      // 1. PRIMARY OPERATION: Update original Queue Ticket document to status = 'cancelled'
      await _firestore.collection(FirebaseConstants.ticketsCollection).doc(actualTicketId).update({
        'status': TicketStatus.cancelled.value,
        'cancelledAt': FieldValue.serverTimestamp(),
        'cancelledBy': cancelledBy ?? clientUserId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 2. SECONDARY OPERATION: Idempotent write to cancelledTickets snapshot
      try {
        final existingCancelledSnap = await _firestore
            .collection('cancelledTickets')
            .where('originalTicketId', isEqualTo: actualTicketId)
            .get();

        if (existingCancelledSnap.docs.isEmpty) {
          String realOrgName = ticketData['organizationName'] as String? ?? '';
          if (realOrgName.isEmpty && orgId.isNotEmpty) {
            try {
              final orgDoc = await _firestore.collection('organizations').doc(orgId).get();
              if (orgDoc.exists) {
                realOrgName = orgDoc.data()?['name'] as String? ?? 'Organization';
              }
            } catch (_) {}
          }

          String realServiceName = ticketData['serviceName'] as String? ?? '';
          if (realServiceName.isEmpty && serviceId.isNotEmpty) {
            try {
              final sDoc = await _firestore.collection('services').doc(serviceId).get();
              if (sDoc.exists) {
                realServiceName = sDoc.data()?['name'] as String? ?? 'Service Desk';
              }
            } catch (_) {}
          }

          final newCancelledRef = _firestore.collection('cancelledTickets').doc();
          final cancelledModel = CancelledTicketModel(
            id: newCancelledRef.id,
            originalTicketId: actualTicketId,
            userId: clientUserId,
            organizationId: orgId,
            organizationName: realOrgName,
            serviceId: serviceId,
            serviceName: realServiceName,
            queueNumber: queueNum,
            phoneNumber: ticketData['phoneNumber'] as String?,
            counterNumber: ticketData['counterNumber'] as String?,
            cancellationReason: cancellationReason ?? 'Ticket cancelled',
            cancelledBy: cancelledBy ?? clientUserId,
            cancelledAt: DateTime.now(),
            originalCreatedAt: (ticketData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            originalCalledAt: (ticketData['calledAt'] as Timestamp?)?.toDate(),
            originalStatus: currentStatus,
          );

          await newCancelledRef.set(cancelledModel.toFirestore());
        }
      } catch (_) {}

      // 3. SECONDARY OPERATION: Decrement queue count on services collection
      if (serviceId.isNotEmpty) {
        try {
          final serviceRef = _firestore.collection('services').doc(serviceId);
          final serviceDoc = await serviceRef.get();
          if (serviceDoc.exists) {
            final count = (serviceDoc.data()?['currentQueueCount'] as num?)?.toInt() ?? 1;
            final updatedCount = count > 0 ? count - 1 : 0;
            await serviceRef.update({'currentQueueCount': updatedCount});
          }
        } catch (_) {}
      }

      // 4. SECONDARY OPERATION: Create in-app notification for client
      if (clientUserId.isNotEmpty) {
        try {
          await _firestore.collection('notifications').add({
            'userId': clientUserId,
            'ticketId': actualTicketId,
            'type': 'cancelled',
            'title': 'Ticket Cancelled',
            'message': 'Your ticket $queueNum has been cancelled.',
            'isRead': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
        } catch (_) {}
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to cancel ticket: ${e.toString()}');
    }
  }
}
