import 'package:equatable/equatable.dart';
import '../../domain/entities/ticket_entity.dart';
import '../../domain/entities/cancelled_ticket_entity.dart';

abstract class TicketEvent extends Equatable {
  const TicketEvent();

  @override
  List<Object?> get props => [];
}

class JoinQueueSubmittedEvent extends TicketEvent {
  final String organizationId;
  final String serviceId;
  final String userId;
  final String phoneNumber;

  const JoinQueueSubmittedEvent({
    required this.organizationId,
    required this.serviceId,
    required this.userId,
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [organizationId, serviceId, userId, phoneNumber];
}

class StreamActiveTicketEvent extends TicketEvent {
  final String userId;

  const StreamActiveTicketEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class ActiveTicketUpdatedEvent extends TicketEvent {
  final TicketEntity? activeTicket;

  const ActiveTicketUpdatedEvent(this.activeTicket);

  @override
  List<Object?> get props => [activeTicket];
}

class TicketHistoryUpdatedEvent extends TicketEvent {
  final List<TicketEntity> historyTickets;

  const TicketHistoryUpdatedEvent(this.historyTickets);

  @override
  List<Object?> get props => [historyTickets];
}

class UserCancelledTicketsUpdatedEvent extends TicketEvent {
  final List<CancelledTicketEntity> cancelledTickets;

  const UserCancelledTicketsUpdatedEvent(this.cancelledTickets);

  @override
  List<Object?> get props => [cancelledTickets];
}

class CancelTicketSubmittedEvent extends TicketEvent {
  final String ticketId;
  final String? userId;
  final String? cancellationReason;

  const CancelTicketSubmittedEvent({
    required this.ticketId,
    this.userId,
    this.cancellationReason,
  });

  @override
  List<Object?> get props => [ticketId, userId, cancellationReason];
}
