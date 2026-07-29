import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/ticket_entity.dart';
import '../../domain/entities/cancelled_ticket_entity.dart';
import '../../domain/repositories/ticket_repository.dart';
import 'ticket_event.dart';
import 'ticket_state.dart';

class TicketBloc extends Bloc<TicketEvent, TicketState> {
  final TicketRepository ticketRepository;
  StreamSubscription<TicketEntity?>? _activeTicketSubscription;
  StreamSubscription<List<TicketEntity>>? _historySubscription;
  StreamSubscription<List<CancelledTicketEntity>>? _cancelledSubscription;

  TicketEntity? _currentActiveTicket;
  List<TicketEntity> _currentHistoryTickets = [];
  List<CancelledTicketEntity> _currentCancelledTickets = [];

  TicketBloc({required this.ticketRepository}) : super(TicketInitialState()) {
    on<JoinQueueSubmittedEvent>(_onJoinQueueSubmitted);
    on<StreamActiveTicketEvent>(_onStreamActiveTicket);
    on<ActiveTicketUpdatedEvent>(_onActiveTicketUpdated);
    on<TicketHistoryUpdatedEvent>(_onTicketHistoryUpdated);
    on<UserCancelledTicketsUpdatedEvent>(_onUserCancelledTicketsUpdated);
    on<CancelTicketSubmittedEvent>(_onCancelTicketSubmitted);
  }

  Future<void> _onJoinQueueSubmitted(
    JoinQueueSubmittedEvent event,
    Emitter<TicketState> emit,
  ) async {
    emit(TicketLoadingState());
    try {
      final ticket = await ticketRepository.joinQueue(
        organizationId: event.organizationId,
        serviceId: event.serviceId,
        userId: event.userId,
        phoneNumber: event.phoneNumber,
      );

      _currentActiveTicket = ticket;
      emit(TicketActiveState(
        activeTicket: _currentActiveTicket,
        historyTickets: _currentHistoryTickets,
        cancelledTickets: _currentCancelledTickets,
      ));
    } on Failure catch (e) {
      emit(TicketFailureState(e.message));
    } catch (e) {
      emit(TicketFailureState(e.toString()));
    }
  }

  void _onStreamActiveTicket(
    StreamActiveTicketEvent event,
    Emitter<TicketState> emit,
  ) {
    _activeTicketSubscription?.cancel();
    _historySubscription?.cancel();
    _cancelledSubscription?.cancel();

    _activeTicketSubscription = ticketRepository
        .streamActiveTicket(event.userId)
        .listen(
      (activeTicket) {
        add(ActiveTicketUpdatedEvent(activeTicket));
      },
      onError: (_) {},
    );

    _historySubscription = ticketRepository
        .streamTicketHistory(event.userId)
        .listen(
      (history) {
        add(TicketHistoryUpdatedEvent(history));
      },
      onError: (_) {},
    );

    _cancelledSubscription = ticketRepository
        .streamUserCancelledTickets(event.userId)
        .listen(
      (cancelledList) {
        add(UserCancelledTicketsUpdatedEvent(cancelledList));
      },
      onError: (_) {},
    );
  }

  void _onActiveTicketUpdated(
    ActiveTicketUpdatedEvent event,
    Emitter<TicketState> emit,
  ) {
    _currentActiveTicket = event.activeTicket;
    emit(TicketActiveState(
      activeTicket: _currentActiveTicket,
      historyTickets: _currentHistoryTickets,
      cancelledTickets: _currentCancelledTickets,
    ));
  }

  void _onTicketHistoryUpdated(
    TicketHistoryUpdatedEvent event,
    Emitter<TicketState> emit,
  ) {
    _currentHistoryTickets = event.historyTickets;
    emit(TicketActiveState(
      activeTicket: _currentActiveTicket,
      historyTickets: _currentHistoryTickets,
      cancelledTickets: _currentCancelledTickets,
    ));
  }

  void _onUserCancelledTicketsUpdated(
    UserCancelledTicketsUpdatedEvent event,
    Emitter<TicketState> emit,
  ) {
    _currentCancelledTickets = event.cancelledTickets;
    emit(TicketActiveState(
      activeTicket: _currentActiveTicket,
      historyTickets: _currentHistoryTickets,
      cancelledTickets: _currentCancelledTickets,
    ));
  }

  Future<void> _onCancelTicketSubmitted(
    CancelTicketSubmittedEvent event,
    Emitter<TicketState> emit,
  ) async {
    emit(TicketLoadingState());
    try {
      await ticketRepository.cancelTicket(
        event.ticketId,
        userId: event.userId,
        cancellationReason: event.cancellationReason ?? 'Cancelled by user',
      );
      _currentActiveTicket = null;
      emit(TicketActiveState(
        activeTicket: null,
        historyTickets: _currentHistoryTickets,
        cancelledTickets: _currentCancelledTickets,
      ));
    } on Failure catch (e) {
      emit(TicketFailureState(e.message));
    } catch (e) {
      emit(TicketFailureState(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _activeTicketSubscription?.cancel();
    _historySubscription?.cancel();
    _cancelledSubscription?.cancel();
    return super.close();
  }
}
