import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/ticket_entity.dart';
import '../../../../shared/enums/ticket_status.dart';

class TicketModel extends TicketEntity {
  const TicketModel({
    required super.id,
    required super.ticketNumber,
    required super.userId,
    required super.organizationId,
    super.organizationName,
    required super.serviceId,
    super.serviceName,
    super.phoneNumber,
    required super.status,
    required super.position,
    required super.estimatedWaitMinutes,
    super.counterNumber,
    required super.createdAt,
    super.calledAt,
    super.servedAt,
    super.completedAt,
  });

  factory TicketModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return TicketModel(
      id: doc.id,
      ticketNumber: data['ticketNumber'] as String? ?? 'A001',
      userId: data['userId'] as String? ?? '',
      organizationId: data['organizationId'] as String? ?? '',
      organizationName: data['organizationName'] as String?,
      serviceId: data['serviceId'] as String? ?? '',
      serviceName: data['serviceName'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
      status: TicketStatus.fromString(data['status'] as String?),
      position: (data['position'] as num?)?.toInt() ?? 0,
      estimatedWaitMinutes: (data['estimatedWaitTime'] as num?)?.toInt() ?? 0,
      counterNumber: data['counterNumber'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      calledAt: (data['calledAt'] as Timestamp?)?.toDate(),
      servedAt: (data['servedAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ticketNumber': ticketNumber,
      'userId': userId,
      'organizationId': organizationId,
      'organizationName': organizationName,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'phoneNumber': phoneNumber,
      'status': status.value,
      'position': position,
      'estimatedWaitTime': estimatedWaitMinutes,
      'counterNumber': counterNumber,
      'createdAt': Timestamp.fromDate(createdAt),
      'calledAt': calledAt != null ? Timestamp.fromDate(calledAt!) : null,
      'servedAt': servedAt != null ? Timestamp.fromDate(servedAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
