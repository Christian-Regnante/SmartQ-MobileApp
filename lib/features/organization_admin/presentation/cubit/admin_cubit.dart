import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../services/domain/entities/service_entity.dart';
import '../../domain/repositories/admin_repository.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitialState extends AdminState {}

class AdminLoadingState extends AdminState {}

class AdminLoadedState extends AdminState {
  final List<ServiceEntity> services;
  final List<UserEntity> staffMembers;

  const AdminLoadedState({
    required this.services,
    required this.staffMembers,
  });

  @override
  List<Object?> get props => [services, staffMembers];
}

class AdminErrorState extends AdminState {
  final String message;
  const AdminErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminCubit extends Cubit<AdminState> {
  final AdminRepository repository;

  AdminCubit({required this.repository}) : super(AdminInitialState());

  Future<void> loadDashboard(String organizationId) async {
    if (isClosed) return;
    emit(AdminLoadingState());
    try {
      final services = await repository.getOrganizationServices(organizationId);
      final staff = await repository.getOrganizationStaff(organizationId);
      if (isClosed) return;
      emit(AdminLoadedState(services: services, staffMembers: staff));
    } catch (e) {
      if (isClosed) return;
      final msg = e is Failure ? e.message : e.toString();
      emit(AdminErrorState(msg));
    }
  }

  Future<void> addService({
    required String organizationId,
    required String name,
    required String description,
    required String counterNumber,
    required int averageServiceTimeMinutes,
  }) async {
    try {
      await repository.createService(
        organizationId: organizationId,
        name: name,
        description: description,
        counterNumber: counterNumber,
        averageServiceTimeMinutes: averageServiceTimeMinutes,
      );
      if (!isClosed) {
        loadDashboard(organizationId);
      }
    } catch (e) {
      if (isClosed) return;
      final msg = e is Failure ? e.message : e.toString();
      emit(AdminErrorState(msg));
    }
  }

  Future<void> updateService({
    required String organizationId,
    required String serviceId,
    required String name,
    required String description,
    required String counterNumber,
    required int averageServiceTimeMinutes,
    required bool isActive,
  }) async {
    try {
      await repository.updateService(
        serviceId: serviceId,
        name: name,
        description: description,
        counterNumber: counterNumber,
        averageServiceTimeMinutes: averageServiceTimeMinutes,
        isActive: isActive,
      );
      if (!isClosed) {
        loadDashboard(organizationId);
      }
    } catch (e) {
      if (isClosed) return;
      final msg = e is Failure ? e.message : e.toString();
      emit(AdminErrorState(msg));
    }
  }

  Future<void> deleteService({
    required String organizationId,
    required String serviceId,
  }) async {
    try {
      await repository.deleteService(
        organizationId: organizationId,
        serviceId: serviceId,
      );
      if (!isClosed) {
        loadDashboard(organizationId);
      }
    } catch (e) {
      if (isClosed) return;
      final msg = e is Failure ? e.message : e.toString();
      emit(AdminErrorState(msg));
    }
  }

  Future<void> provisionStaff({
    required String email,
    required String password,
    required String fullName,
    required String organizationId,
    required String serviceId,
  }) async {
    try {
      await repository.provisionStaffUser(
        email: email,
        password: password,
        fullName: fullName,
        organizationId: organizationId,
        serviceId: serviceId,
      );
      if (!isClosed) {
        loadDashboard(organizationId);
      }
    } catch (e) {
      if (isClosed) return;
      final msg = e is Failure ? e.message : e.toString();
      emit(AdminErrorState(msg));
    }
  }

  Future<void> updateStaff({
    required String organizationId,
    required String staffId,
    required String fullName,
    required String email,
    required String serviceId,
    required bool isActive,
  }) async {
    try {
      await repository.updateStaffUser(
        staffId: staffId,
        fullName: fullName,
        email: email,
        serviceId: serviceId,
        isActive: isActive,
      );
      if (!isClosed) {
        loadDashboard(organizationId);
      }
    } catch (e) {
      if (isClosed) return;
      final msg = e is Failure ? e.message : e.toString();
      emit(AdminErrorState(msg));
    }
  }

  Future<void> deleteStaff({
    required String organizationId,
    required String staffId,
  }) async {
    try {
      await repository.deleteStaffUser(staffId);
      if (!isClosed) {
        loadDashboard(organizationId);
      }
    } catch (e) {
      if (isClosed) return;
      final msg = e is Failure ? e.message : e.toString();
      emit(AdminErrorState(msg));
    }
  }
}
