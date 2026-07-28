import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/cancelled_ticket_entity.dart';

class CancelledTicketModel extends CancelledTicketEntity {
  const CancelledTicketModel({
    required super.id,
    required super.originalTicketId,
    required super.userId,
    required super.organizationId,
    super.organizationName,
    required super.serviceId,
    super.serviceName,
    required super.queueNumber,
    super.phoneNumber,
    super.counterNumber,
    super.cancellationReason,
    super.cancelledBy,
    required super.cancelledAt,
    required super.originalCreatedAt,
    super.originalCalledAt,
    required super.originalStatus,
  });

  factory CancelledTicketModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return CancelledTicketModel(
      id: doc.id,
      originalTicketId: data['originalTicketId'] as String? ?? '',
      userId: data['clientId'] as String? ?? data['userId'] as String? ?? '',
      organizationId: data['organizationId'] as String? ?? '',
      organizationName: data['organizationName'] as String?,
      serviceId: data['serviceId'] as String? ?? '',
      serviceName: data['serviceName'] as String?,
      queueNumber: data['queueNumber'] as String? ?? data['ticketNumber'] as String? ?? 'A001',
      phoneNumber: data['phoneNumber'] as String?,
      counterNumber: data['counterNumber'] as String?,
      cancellationReason: data['cancellationReason'] as String? ?? 'Cancelled',
      cancelledBy: data['cancelledBy'] as String?,
      cancelledAt: (data['cancelledAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      originalCreatedAt: (data['originalCreatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      originalCalledAt: (data['originalCalledAt'] as Timestamp?)?.toDate(),
      originalStatus: data['originalStatus'] as String? ?? 'waiting',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'originalTicketId': originalTicketId,
      'clientId': userId,
      'userId': userId,
      'organizationId': organizationId,
      'organizationName': organizationName,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'queueNumber': queueNumber,
      'ticketNumber': queueNumber,
      'phoneNumber': phoneNumber,
      'counterNumber': counterNumber,
      'cancellationReason': cancellationReason,
      'cancelledBy': cancelledBy,
      'cancelledAt': Timestamp.fromDate(cancelledAt),
      'originalCreatedAt': Timestamp.fromDate(originalCreatedAt),
      'originalCalledAt': originalCalledAt != null ? Timestamp.fromDate(originalCalledAt!) : null,
      'originalStatus': originalStatus,
    };
  }
}
