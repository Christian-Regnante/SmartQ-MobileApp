import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../shared/enums/ticket_status.dart';
import '../../../tickets/data/models/ticket_model.dart';

abstract class StaffRemoteDataSource {
  Stream<List<TicketModel>> streamWaitingQueue(String serviceId);
  Stream<TicketModel?> streamCurrentlyServing(String serviceId);
  Future<TicketModel?> callNextTicket({
    required String organizationId,
    required String serviceId,
    required String staffId,
    required String counterNumber,
  });
  Future<TicketModel?> callSpecificTicket({
    required String ticketId,
    required String staffId,
    required String counterNumber,
  });
  Future<void> completeCurrentTicket(String ticketId);
  Future<void> skipCurrentTicket(String ticketId);
  Future<void> cancelCurrentTicket(String ticketId, {required String staffId});
  Future<void> transferTicket(String ticketId, String newServiceId, String newServiceName);
}

class StaffRemoteDataSourceImpl implements StaffRemoteDataSource {
  final FirebaseFirestore _firestore;

  StaffRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<TicketModel>> streamWaitingQueue(String serviceId) {
    return _firestore
        .collection(FirebaseConstants.ticketsCollection)
        .where('serviceId', isEqualTo: serviceId)
        .where('status', isEqualTo: TicketStatus.waiting.value)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TicketModel.fromFirestore(doc))
              .toList()
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
        });
  }

  @override
  Stream<TicketModel?> streamCurrentlyServing(String serviceId) {
    return _firestore
        .collection(FirebaseConstants.ticketsCollection)
        .where('serviceId', isEqualTo: serviceId)
        .where('status', isEqualTo: TicketStatus.serving.value)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          return TicketModel.fromFirestore(snapshot.docs.first);
        });
  }

  @override
  Future<TicketModel?> callNextTicket({
    required String organizationId,
    required String serviceId,
    required String staffId,
    required String counterNumber,
  }) async {
    try {
      // 1. Check single serving ticket restriction
      final servingQuery = await _firestore
          .collection(FirebaseConstants.ticketsCollection)
          .where('serviceId', isEqualTo: serviceId)
          .where('status', isEqualTo: TicketStatus.serving.value)
          .get();

      if (servingQuery.docs.isNotEmpty) {
        final servingNum = servingQuery.docs.first.data()['ticketNumber'] ?? 'active';
        throw ServerException(
          'You are currently serving ticket #$servingNum. Complete, skip, or cancel before calling another customer.',
        );
      }

      // 2. Query waiting tickets
      final waitingQuery = await _firestore
          .collection(FirebaseConstants.ticketsCollection)
          .where('serviceId', isEqualTo: serviceId)
          .where('status', isEqualTo: TicketStatus.waiting.value)
          .get();

      if (waitingQuery.docs.isEmpty) {
        return null;
      }

      final nextDocs = waitingQuery.docs
        ..sort((a, b) {
          final aTime = (a.data()['createdAt'] as Timestamp?) ?? Timestamp.now();
          final bTime = (b.data()['createdAt'] as Timestamp?) ?? Timestamp.now();
          return aTime.compareTo(bTime);
        });

      final targetDoc = nextDocs.first;
      final targetRef = targetDoc.reference;
      final ticketData = targetDoc.data();
      final clientUserId = ticketData['userId'] as String? ?? '';
      final ticketNum = ticketData['ticketNumber'] as String? ?? 'Ticket';
      final orgName = ticketData['organizationName'] as String? ?? 'Organization';
      final serviceName = ticketData['serviceName'] as String? ?? 'Service';

      // 3. Update the ticket document directly
      await targetRef.update({
        'status': TicketStatus.serving.value,
        'counterNumber': counterNumber,
        'staffId': staffId,
        'calledAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 4. Non-blocking secondary collection updates
      try {
        await _firestore.collection('services').doc(serviceId).update({
          'currentQueueCount': FieldValue.increment(-1),
        });
      } catch (_) {}

      try {
        if (clientUserId.isNotEmpty) {
          await _firestore.collection('notifications').add({
            'userId': clientUserId,
            'ticketId': targetDoc.id,
            'organizationId': organizationId,
            'serviceId': serviceId,
            'type': 'ticket_called',
            'title': 'Your turn has arrived! 🔔',
            'message': 'Ticket $ticketNum is now being served at $orgName - $serviceName ($counterNumber).',
            'isRead': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      } catch (_) {}

      final updatedDoc = await targetRef.get();
      return TicketModel.fromFirestore(updatedDoc);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to call next ticket: ${e.toString()}');
    }
  }

  @override
  Future<TicketModel?> callSpecificTicket({
    required String ticketId,
    required String staffId,
    required String counterNumber,
  }) async {
    try {
      final targetRef = _firestore.collection(FirebaseConstants.ticketsCollection).doc(ticketId);
      final targetDoc = await targetRef.get();

      if (!targetDoc.exists) {
        throw const ServerException('The selected ticket no longer exists.');
      }

      final ticketData = targetDoc.data() ?? {};
      final serviceId = ticketData['serviceId'] as String? ?? '';
      final organizationId = ticketData['organizationId'] as String? ?? '';

      // Check single serving ticket restriction
      if (serviceId.isNotEmpty) {
        final servingQuery = await _firestore
            .collection(FirebaseConstants.ticketsCollection)
            .where('serviceId', isEqualTo: serviceId)
            .where('status', isEqualTo: TicketStatus.serving.value)
            .get();

        if (servingQuery.docs.isNotEmpty && servingQuery.docs.first.id != ticketId) {
          final servingNum = servingQuery.docs.first.data()['ticketNumber'] ?? 'active';
          throw ServerException(
            'You are currently serving ticket #$servingNum. Complete, skip, or cancel before calling another customer.',
          );
        }
      }

      final clientUserId = ticketData['userId'] as String? ?? '';
      final ticketNum = ticketData['ticketNumber'] as String? ?? 'Ticket';
      final orgName = ticketData['organizationName'] as String? ?? 'Organization';
      final serviceName = ticketData['serviceName'] as String? ?? 'Service';

      // Update target ticket directly
      await targetRef.update({
        'status': TicketStatus.serving.value,
        'counterNumber': counterNumber,
        'staffId': staffId,
        'calledAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Non-blocking secondary collection updates
      if (serviceId.isNotEmpty) {
        try {
          await _firestore.collection('services').doc(serviceId).update({
            'currentQueueCount': FieldValue.increment(-1),
          });
        } catch (_) {}
      }

      try {
        if (clientUserId.isNotEmpty) {
          await _firestore.collection('notifications').add({
            'userId': clientUserId,
            'ticketId': targetDoc.id,
            'organizationId': organizationId,
            'serviceId': serviceId,
            'type': 'ticket_called',
            'title': 'Your turn has arrived! 🔔',
            'message': 'Ticket $ticketNum is now being served at $orgName - $serviceName ($counterNumber).',
            'isRead': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      } catch (_) {}

      final finalDoc = await targetRef.get();
      return TicketModel.fromFirestore(finalDoc);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to call ticket: ${e.toString()}');
    }
  }

  @override
  Future<void> completeCurrentTicket(String ticketId) async {
    try {
      final ticketRef = _firestore.collection(FirebaseConstants.ticketsCollection).doc(ticketId);
      final doc = await ticketRef.get();
      final data = doc.data() ?? {};
      final clientUserId = data['userId'] as String? ?? '';
      final ticketNum = data['ticketNumber'] as String? ?? '';
      final orgName = data['organizationName'] as String? ?? 'Organization';

      await ticketRef.update({
        'status': TicketStatus.done.value,
        'completedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      try {
        if (clientUserId.isNotEmpty) {
          await _firestore.collection('notifications').add({
            'userId': clientUserId,
            'ticketId': ticketId,
            'type': 'ticket_completed',
            'title': 'Service Completed ✅',
            'message': 'Thank you for visiting $orgName. Your ticket $ticketNum has been completed.',
            'isRead': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      } catch (_) {}
    } catch (e) {
      throw ServerException('Failed to complete ticket: ${e.toString()}');
    }
  }

  @override
  Future<void> skipCurrentTicket(String ticketId) async {
    try {
      final ticketRef = _firestore.collection(FirebaseConstants.ticketsCollection).doc(ticketId);
      final doc = await ticketRef.get();
      final data = doc.data() ?? {};
      final clientUserId = data['userId'] as String? ?? '';
      final ticketNum = data['ticketNumber'] as String? ?? '';
      final serviceId = data['serviceId'] as String?;

      await ticketRef.update({
        'status': TicketStatus.waiting.value,
        'skippedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (serviceId != null && serviceId.isNotEmpty) {
        try {
          await _firestore.collection('services').doc(serviceId).update({
            'currentQueueCount': FieldValue.increment(1),
          });
        } catch (_) {}
      }

      try {
        if (clientUserId.isNotEmpty) {
          await _firestore.collection('notifications').add({
            'userId': clientUserId,
            'ticketId': ticketId,
            'type': 'skipped',
            'title': 'Ticket Skipped',
            'message': 'Your ticket $ticketNum was skipped and returned to the end of the waiting queue. Please remain available.',
            'isRead': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      } catch (_) {}
    } catch (e) {
      throw ServerException('Failed to skip ticket: ${e.toString()}');
    }
  }

  @override
  Future<void> cancelCurrentTicket(String ticketId, {required String staffId}) async {
    try {
      final ticketRef = _firestore.collection(FirebaseConstants.ticketsCollection).doc(ticketId);
      final doc = await ticketRef.get();
      final data = doc.data() ?? {};
      final serviceId = data['serviceId'] as String? ?? '';
      final orgId = data['organizationId'] as String? ?? '';
      final clientUserId = data['userId'] as String? ?? '';
      final ticketNum = data['ticketNumber'] as String? ?? '';

      // 1. PRIMARY OPERATION: Update original ticket document to status = 'cancelled'
      await ticketRef.update({
        'status': TicketStatus.cancelled.value,
        'cancelledAt': FieldValue.serverTimestamp(),
        'cancelledBy': staffId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 2. SECONDARY OPERATION: Idempotent write to cancelledTickets snapshot
      try {
        final existingCancelledSnap = await _firestore
            .collection('cancelledTickets')
            .where('originalTicketId', isEqualTo: ticketId)
            .get();

        if (existingCancelledSnap.docs.isEmpty) {
          String realOrgName = data['organizationName'] as String? ?? '';
          if (realOrgName.isEmpty && orgId.isNotEmpty) {
            try {
              final orgDoc = await _firestore.collection('organizations').doc(orgId).get();
              if (orgDoc.exists) realOrgName = orgDoc.data()?['name'] as String? ?? 'Organization';
            } catch (_) {}
          }

          String realServiceName = data['serviceName'] as String? ?? '';
          if (realServiceName.isEmpty && serviceId.isNotEmpty) {
            try {
              final sDoc = await _firestore.collection('services').doc(serviceId).get();
              if (sDoc.exists) realServiceName = sDoc.data()?['name'] as String? ?? 'Service Desk';
            } catch (_) {}
          }

          final newCancelledRef = _firestore.collection('cancelledTickets').doc();
          await newCancelledRef.set({
            'originalTicketId': ticketId,
            'clientId': clientUserId,
            'userId': clientUserId,
            'organizationId': orgId,
            'organizationName': realOrgName,
            'serviceId': serviceId,
            'serviceName': realServiceName,
            'queueNumber': ticketNum,
            'ticketNumber': ticketNum,
            'phoneNumber': data['phoneNumber'] as String?,
            'counterNumber': data['counterNumber'] as String?,
            'cancellationReason': 'Staff cancelled service',
            'cancelledBy': staffId,
            'cancelledAt': FieldValue.serverTimestamp(),
            'originalCreatedAt': data['createdAt'] ?? FieldValue.serverTimestamp(),
            'originalCalledAt': data['calledAt'],
            'originalStatus': data['status'] ?? 'serving',
          });
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

      // 4. SECONDARY OPERATION: Create in-app notification
      try {
        if (clientUserId.isNotEmpty) {
          await _firestore.collection('notifications').add({
            'userId': clientUserId,
            'ticketId': ticketId,
            'type': 'cancelled',
            'title': 'Ticket Cancelled',
            'message': 'Your ticket $ticketNum has been cancelled by the service desk staff.',
            'isRead': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      } catch (_) {}
    } catch (e) {
      throw ServerException('Failed to cancel ticket: ${e.toString()}');
    }
  }

  @override
  Future<void> transferTicket(String ticketId, String newServiceId, String newServiceName) async {
    try {
      await _firestore
          .collection(FirebaseConstants.ticketsCollection)
          .doc(ticketId)
          .update({
        'status': TicketStatus.waiting.value,
        'serviceId': newServiceId,
        'serviceName': newServiceName,
        'transferredAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException('Failed to transfer ticket: ${e.toString()}');
    }
  }
}
