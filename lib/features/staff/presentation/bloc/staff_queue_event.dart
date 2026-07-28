import 'package:equatable/equatable.dart';
import '../../../tickets/domain/entities/ticket_entity.dart';

abstract class StaffQueueEvent extends Equatable {
  const StaffQueueEvent();

  @override
  List<Object?> get props => [];
}

class InitStaffQueueEvent extends StaffQueueEvent {
  final String serviceId;
  final String counterNumber;

  const InitStaffQueueEvent({
    required this.serviceId,
    required this.counterNumber,
  });

  @override
  List<Object?> get props => [serviceId, counterNumber];
}

class WaitingQueueUpdatedEvent extends StaffQueueEvent {
  final List<TicketEntity> queue;
  const WaitingQueueUpdatedEvent(this.queue);

  @override
  List<Object?> get props => [queue];
}

class CurrentlyServingUpdatedEvent extends StaffQueueEvent {
  final TicketEntity? ticket;
  const CurrentlyServingUpdatedEvent(this.ticket);

  @override
  List<Object?> get props => [ticket];
}

class CallNextTicketSubmittedEvent extends StaffQueueEvent {
  final String organizationId;
  final String serviceId;
  final String staffId;
  final String counterNumber;

  const CallNextTicketSubmittedEvent({
    required this.organizationId,
    required this.serviceId,
    required this.staffId,
    required this.counterNumber,
  });

  @override
  List<Object?> get props => [organizationId, serviceId, staffId, counterNumber];
}

class CallSpecificTicketSubmittedEvent extends StaffQueueEvent {
  final String ticketId;
  final String staffId;
  final String counterNumber;

  const CallSpecificTicketSubmittedEvent({
    required this.ticketId,
    required this.staffId,
    required this.counterNumber,
  });

  @override
  List<Object?> get props => [ticketId, staffId, counterNumber];
}

class CompleteTicketSubmittedEvent extends StaffQueueEvent {
  final String ticketId;
  const CompleteTicketSubmittedEvent(this.ticketId);

  @override
  List<Object?> get props => [ticketId];
}

class SkipTicketSubmittedEvent extends StaffQueueEvent {
  final String ticketId;
  const SkipTicketSubmittedEvent(this.ticketId);

  @override
  List<Object?> get props => [ticketId];
}

class StaffCancelTicketSubmittedEvent extends StaffQueueEvent {
  final String ticketId;
  final String staffId;
  const StaffCancelTicketSubmittedEvent({required this.ticketId, required this.staffId});

  @override
  List<Object?> get props => [ticketId, staffId];
}

class TransferTicketSubmittedEvent extends StaffQueueEvent {
  final String ticketId;
  final String newServiceId;
  final String newServiceName;

  const TransferTicketSubmittedEvent({
    required this.ticketId,
    required this.newServiceId,
    required this.newServiceName,
  });

  @override
  List<Object?> get props => [ticketId, newServiceId, newServiceName];
}
