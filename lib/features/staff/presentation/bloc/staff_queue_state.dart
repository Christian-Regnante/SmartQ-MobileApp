import 'package:equatable/equatable.dart';
import '../../../tickets/domain/entities/ticket_entity.dart';

abstract class StaffQueueState extends Equatable {
  const StaffQueueState();

  @override
  List<Object?> get props => [];
}

class StaffQueueInitialState extends StaffQueueState {}

class StaffQueueLoadingState extends StaffQueueState {}

class StaffQueueActiveState extends StaffQueueState {
  final TicketEntity? currentlyServing;
  final List<TicketEntity> waitingQueue;
  final bool isCounterOpen;

  const StaffQueueActiveState({
    this.currentlyServing,
    this.waitingQueue = const [],
    this.isCounterOpen = true,
  });

  StaffQueueActiveState copyWith({
    TicketEntity? currentlyServing,
    List<TicketEntity>? waitingQueue,
    bool? isCounterOpen,
  }) {
    return StaffQueueActiveState(
      currentlyServing: currentlyServing ?? this.currentlyServing,
      waitingQueue: waitingQueue ?? this.waitingQueue,
      isCounterOpen: isCounterOpen ?? this.isCounterOpen,
    );
  }

  @override
  List<Object?> get props => [currentlyServing, waitingQueue, isCounterOpen];
}

class StaffQueueFailureState extends StaffQueueState {
  final String message;
  const StaffQueueFailureState(this.message);

  @override
  List<Object?> get props => [message];
}
