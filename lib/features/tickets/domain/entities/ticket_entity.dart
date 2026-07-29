import 'package:equatable/equatable.dart';
import '../../../../shared/enums/ticket_status.dart';

class TicketEntity extends Equatable {
  final String id;
  final String ticketNumber;
  final String userId;
  final String organizationId;
  final String? organizationName;
  final String serviceId;
  final String? serviceName;
  final String? phoneNumber;
  final TicketStatus status;
  final int position;
  final int estimatedWaitMinutes;
  final String? counterNumber;
  final DateTime createdAt;
  final DateTime? calledAt;
  final DateTime? servedAt;
  final DateTime? completedAt;

  const TicketEntity({
    required this.id,
    required this.ticketNumber,
    required this.userId,
    required this.organizationId,
    this.organizationName,
    required this.serviceId,
    this.serviceName,
    this.phoneNumber,
    required this.status,
    required this.position,
    required this.estimatedWaitMinutes,
    this.counterNumber,
    required this.createdAt,
    this.calledAt,
    this.servedAt,
    this.completedAt,
  });

  @override
  List<Object?> get props => [
        id,
        ticketNumber,
        userId,
        organizationId,
        organizationName,
        serviceId,
        serviceName,
        phoneNumber,
        status,
        position,
        estimatedWaitMinutes,
        counterNumber,
        createdAt,
        calledAt,
        servedAt,
        completedAt,
      ];
}
