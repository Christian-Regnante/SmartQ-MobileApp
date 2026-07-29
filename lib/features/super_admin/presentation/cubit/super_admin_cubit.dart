import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../organizations/domain/entities/organization_entity.dart';
import '../../domain/entities/national_analytics_entity.dart';
import '../../domain/repositories/super_admin_repository.dart';

abstract class SuperAdminState extends Equatable {
  const SuperAdminState();

  @override
  List<Object?> get props => [];
}

class SuperAdminInitialState extends SuperAdminState {}

class SuperAdminLoadingState extends SuperAdminState {}

class SuperAdminLoadedState extends SuperAdminState {
  final List<OrganizationEntity> organizations;
  final List<UserEntity> orgAdmins;
  final List<Map<String, dynamic>> logs;
  final NationalAnalyticsEntity analytics;

  const SuperAdminLoadedState({
    required this.organizations,
    required this.orgAdmins,
    required this.logs,
    required this.analytics,
  });

  @override
  List<Object?> get props => [organizations, orgAdmins, logs, analytics];
}

class SuperAdminErrorState extends SuperAdminState {
  final String message;
  const SuperAdminErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

class SuperAdminCubit extends Cubit<SuperAdminState> {
  final SuperAdminRepository repository;

  SuperAdminCubit({required this.repository}) : super(SuperAdminInitialState());

  Future<void> loadMasterDashboard() async {
    if (isClosed) return;
    emit(SuperAdminLoadingState());
    try {
      final orgs = await repository.getAllOrganizations();
      final admins = await repository.getOrgAdmins();
      final logs = await repository.getSystemAuditLogs();
      final analytics = await repository.getNationalAnalytics();
      if (isClosed) return;
      emit(SuperAdminLoadedState(
        organizations: orgs,
        orgAdmins: admins,
        logs: logs,
        analytics: analytics,
      ));
    } catch (e) {
      if (isClosed) return;
      final msg = e is Failure ? e.message : e.toString();
      emit(SuperAdminErrorState(msg));
    }
  }

  Future<void> addOrganization({
    required String name,
    required String description,
    required String location,
    required String address,
    required String phoneNumber,
    required String email,
    String sector = 'Other',
  }) async {
    try {
      await repository.createOrganization(
        name: name,
        description: description,
        location: location,
        address: address,
        phoneNumber: phoneNumber,
        email: email,
        sector: sector,
      );
      if (!isClosed) {
        loadMasterDashboard();
      }
    } catch (e) {
      if (isClosed) return;
      final msg = e is Failure ? e.message : e.toString();
      emit(SuperAdminErrorState(msg));
    }
  }

  Future<void> updateOrganization({
    required String id,
    required String name,
    required String description,
    required String location,
    required String address,
    required String phoneNumber,
    required String email,
    required bool isActive,
    String sector = 'Other',
  }) async {
    try {
      await repository.updateOrganization(
        id: id,
        name: name,
        description: description,
        location: location,
        address: address,
        phoneNumber: phoneNumber,
        email: email,
        isActive: isActive,
        sector: sector,
      );
      if (!isClosed) {
        loadMasterDashboard();
      }
    } catch (e) {
      if (isClosed) return;
      final msg = e is Failure ? e.message : e.toString();
      emit(SuperAdminErrorState(msg));
    }
  }

  Future<void> deleteOrganization(String organizationId) async {
    try {
      await repository.deleteOrganization(organizationId);
      if (!isClosed) {
        loadMasterDashboard();
      }
    } catch (e) {
      if (isClosed) return;
      final msg = e is Failure ? e.message : e.toString();
      emit(SuperAdminErrorState(msg));
    }
  }

  Future<void> toggleOrganizationStatus(String organizationId, bool isActive) async {
    try {
      await repository.toggleOrganizationStatus(organizationId, isActive);
      if (!isClosed) {
        loadMasterDashboard();
      }
    } catch (e) {
      if (isClosed) return;
      final msg = e is Failure ? e.message : e.toString();
      emit(SuperAdminErrorState(msg));
    }
  }

  Future<void> provisionAdmin({
    required String email,
    required String password,
    required String fullName,
    required String organizationId,
  }) async {
    try {
      await repository.provisionOrgAdmin(
        email: email,
        password: password,
        fullName: fullName,
        organizationId: organizationId,
      );
      if (!isClosed) {
        loadMasterDashboard();
      }
    } catch (e) {
      if (isClosed) return;
      final msg = e is Failure ? e.message : e.toString();
      emit(SuperAdminErrorState(msg));
    }
  }

  Future<void> updateAdmin({
    required String adminId,
    required String fullName,
    required String email,
    String? organizationId,
    required bool isActive,
  }) async {
    try {
      await repository.updateOrgAdmin(
        adminId: adminId,
        fullName: fullName,
        email: email,
        organizationId: organizationId,
        isActive: isActive,
      );
      if (!isClosed) {
        loadMasterDashboard();
      }
    } catch (e) {
      if (isClosed) return;
      final msg = e is Failure ? e.message : e.toString();
      emit(SuperAdminErrorState(msg));
    }
  }

  Future<void> deleteAdmin({
    required String adminId,
    String? organizationId,
  }) async {
    try {
      await repository.deleteOrgAdmin(adminId: adminId, organizationId: organizationId);
      if (!isClosed) {
        loadMasterDashboard();
      }
    } catch (e) {
      if (isClosed) return;
      final msg = e is Failure ? e.message : e.toString();
      emit(SuperAdminErrorState(msg));
    }
  }
}
