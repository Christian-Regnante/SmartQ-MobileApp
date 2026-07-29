import 'package:equatable/equatable.dart';

class CancelledTicketEntity extends Equatable {
  final String id;
  final String originalTicketId;
  final String userId;
  final String organizationId;
  final String? organizationName;
  final String serviceId;
  final String? serviceName;
  final String queueNumber;
  final String? phoneNumber;
  final String? counterNumber;
  final String? cancellationReason;
  final String? cancelledBy;
  final DateTime cancelledAt;
  final DateTime originalCreatedAt;
  final DateTime? originalCalledAt;
  final String originalStatus;

  const CancelledTicketEntity({
    required this.id,
    required this.originalTicketId,
    required this.userId,
    required this.organizationId,
    this.organizationName,
    required this.serviceId,
    this.serviceName,
    required this.queueNumber,
    this.phoneNumber,
    this.counterNumber,
    this.cancellationReason,
    this.cancelledBy,
    required this.cancelledAt,
    required this.originalCreatedAt,
    this.originalCalledAt,
    required this.originalStatus,
  });

  @override
  List<Object?> get props => [
        id,
        originalTicketId,
        userId,
        organizationId,
        organizationName,
        serviceId,
        serviceName,
        queueNumber,
        phoneNumber,
        counterNumber,
        cancellationReason,
        cancelledBy,
        cancelledAt,
        originalCreatedAt,
        originalCalledAt,
        originalStatus,
      ];
}
