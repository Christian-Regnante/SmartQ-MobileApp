import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/repositories/service_repository.dart';

abstract class ServiceState extends Equatable {
  const ServiceState();

  @override
  List<Object?> get props => [];
}

class ServiceInitial extends ServiceState {}

class ServiceLoading extends ServiceState {}

class ServiceLoaded extends ServiceState {
  final List<ServiceEntity> services;
  final String organizationId;

  const ServiceLoaded({required this.services, required this.organizationId});

  @override
  List<Object?> get props => [services, organizationId];
}

class ServiceEmpty extends ServiceState {}

class ServiceError extends ServiceState {
  final String message;

  const ServiceError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ServiceCubit extends Cubit<ServiceState> {
  final ServiceRepository repository;

  ServiceCubit({required this.repository}) : super(ServiceInitial());

  Future<void> loadServices(String organizationId) async {
    if (isClosed) return;
    emit(ServiceLoading());
    try {
      final services = await repository.getServicesForOrganization(organizationId);
      if (isClosed) return;
      if (services.isEmpty) {
        emit(ServiceEmpty());
      } else {
        emit(ServiceLoaded(services: services, organizationId: organizationId));
      }
    } catch (e) {
      if (isClosed) return;
      emit(ServiceError(message: e.toString()));
    }
  }
}
