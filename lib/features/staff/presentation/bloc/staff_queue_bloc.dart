import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../../tickets/domain/entities/ticket_entity.dart';
import '../../domain/repositories/staff_repository.dart';
import 'staff_queue_event.dart';
import 'staff_queue_state.dart';

class StaffQueueBloc extends Bloc<StaffQueueEvent, StaffQueueState> {
  final StaffRepository staffRepository;
  StreamSubscription? _queueSubscription;
  StreamSubscription? _servingSubscription;

  TicketEntity? _currentServingTicket;
  List<TicketEntity> _currentWaitingQueue = [];

  StaffQueueBloc({required this.staffRepository}) : super(StaffQueueInitialState()) {
    on<InitStaffQueueEvent>(_onInitStaffQueue);
    on<WaitingQueueUpdatedEvent>(_onWaitingQueueUpdated);
    on<CurrentlyServingUpdatedEvent>(_onCurrentlyServingUpdated);
    on<CallNextTicketSubmittedEvent>(_onCallNextTicketSubmitted);
    on<CallSpecificTicketSubmittedEvent>(_onCallSpecificTicketSubmitted);
    on<CompleteTicketSubmittedEvent>(_onCompleteTicketSubmitted);
    on<SkipTicketSubmittedEvent>(_onSkipTicketSubmitted);
    on<StaffCancelTicketSubmittedEvent>(_onStaffCancelTicketSubmitted);
    on<TransferTicketSubmittedEvent>(_onTransferTicketSubmitted);
  }

  void _onInitStaffQueue(
    InitStaffQueueEvent event,
    Emitter<StaffQueueState> emit,
  ) {
    _queueSubscription?.cancel();
    _servingSubscription?.cancel();

    _queueSubscription = staffRepository
        .streamWaitingQueue(event.serviceId)
        .listen(
      (queue) {
        add(WaitingQueueUpdatedEvent(queue));
      },
      onError: (error) {
        // Prevent unhandled stream error
      },
    );

    _servingSubscription = staffRepository
        .streamCurrentlyServing(event.serviceId)
        .listen(
      (ticket) {
        add(CurrentlyServingUpdatedEvent(ticket));
      },
      onError: (error) {
        // Prevent unhandled stream error
      },
    );
  }

  void _onWaitingQueueUpdated(
    WaitingQueueUpdatedEvent event,
    Emitter<StaffQueueState> emit,
  ) {
    _currentWaitingQueue = event.queue;
    emit(StaffQueueActiveState(
      currentlyServing: _currentServingTicket,
      waitingQueue: _currentWaitingQueue,
    ));
  }

  void _onCurrentlyServingUpdated(
    CurrentlyServingUpdatedEvent event,
    Emitter<StaffQueueState> emit,
  ) {
    _currentServingTicket = event.ticket;
    emit(StaffQueueActiveState(
      currentlyServing: _currentServingTicket,
      waitingQueue: _currentWaitingQueue,
    ));
  }

  Future<void> _onCallNextTicketSubmitted(
    CallNextTicketSubmittedEvent event,
    Emitter<StaffQueueState> emit,
  ) async {
    try {
      await staffRepository.callNextTicket(
        organizationId: event.organizationId,
        serviceId: event.serviceId,
        staffId: event.staffId,
        counterNumber: event.counterNumber,
      );
    } on Failure catch (e) {
      emit(StaffQueueFailureState(e.message));
    } catch (e) {
      emit(StaffQueueFailureState(e.toString()));
    }
  }

  Future<void> _onCallSpecificTicketSubmitted(
    CallSpecificTicketSubmittedEvent event,
    Emitter<StaffQueueState> emit,
  ) async {
    try {
      await staffRepository.callSpecificTicket(
        ticketId: event.ticketId,
        staffId: event.staffId,
        counterNumber: event.counterNumber,
      );
    } on Failure catch (e) {
      emit(StaffQueueFailureState(e.message));
    } catch (e) {
      emit(StaffQueueFailureState(e.toString()));
    }
  }

  Future<void> _onCompleteTicketSubmitted(
    CompleteTicketSubmittedEvent event,
    Emitter<StaffQueueState> emit,
  ) async {
    try {
      await staffRepository.completeCurrentTicket(event.ticketId);
    } on Failure catch (e) {
      emit(StaffQueueFailureState(e.message));
    } catch (e) {
      emit(StaffQueueFailureState(e.toString()));
    }
  }

  Future<void> _onSkipTicketSubmitted(
    SkipTicketSubmittedEvent event,
    Emitter<StaffQueueState> emit,
  ) async {
    try {
      await staffRepository.skipCurrentTicket(event.ticketId);
    } on Failure catch (e) {
      emit(StaffQueueFailureState(e.message));
    } catch (e) {
      emit(StaffQueueFailureState(e.toString()));
    }
  }

  Future<void> _onStaffCancelTicketSubmitted(
    StaffCancelTicketSubmittedEvent event,
    Emitter<StaffQueueState> emit,
  ) async {
    try {
      await staffRepository.cancelCurrentTicket(event.ticketId, staffId: event.staffId);
    } on Failure catch (e) {
      emit(StaffQueueFailureState(e.message));
    } catch (e) {
      emit(StaffQueueFailureState(e.toString()));
    }
  }

  Future<void> _onTransferTicketSubmitted(
    TransferTicketSubmittedEvent event,
    Emitter<StaffQueueState> emit,
  ) async {
    try {
      await staffRepository.transferTicket(
        event.ticketId,
        event.newServiceId,
        event.newServiceName,
      );
    } on Failure catch (e) {
      emit(StaffQueueFailureState(e.message));
    } catch (e) {
      emit(StaffQueueFailureState(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _queueSubscription?.cancel();
    _servingSubscription?.cancel();
    return super.close();
  }
}
