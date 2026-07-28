import 'package:equatable/equatable.dart';
import '../../domain/entities/ticket_entity.dart';
import '../../domain/entities/cancelled_ticket_entity.dart';

abstract class TicketState extends Equatable {
  const TicketState();

  @override
  List<Object?> get props => [];
}

class TicketInitialState extends TicketState {}

class TicketLoadingState extends TicketState {}

class TicketActiveState extends TicketState {
  final TicketEntity? activeTicket;
  final List<TicketEntity> historyTickets;
  final List<CancelledTicketEntity> cancelledTickets;

  const TicketActiveState({
    this.activeTicket,
    this.historyTickets = const [],
    this.cancelledTickets = const [],
  });

  TicketActiveState copyWith({
    TicketEntity? activeTicket,
    bool clearActiveTicket = false,
    List<TicketEntity>? historyTickets,
    List<CancelledTicketEntity>? cancelledTickets,
  }) {
    return TicketActiveState(
      activeTicket: clearActiveTicket ? null : (activeTicket ?? this.activeTicket),
      historyTickets: historyTickets ?? this.historyTickets,
      cancelledTickets: cancelledTickets ?? this.cancelledTickets,
    );
  }

  @override
  List<Object?> get props => [activeTicket, historyTickets, cancelledTickets];
}

class TicketSuccessState extends TicketState {
  final String message;

  const TicketSuccessState(this.message);

  @override
  List<Object?> get props => [message];
}

class TicketFailureState extends TicketState {
  final String message;

  const TicketFailureState(this.message);

  @override
  List<Object?> get props => [message];
}
