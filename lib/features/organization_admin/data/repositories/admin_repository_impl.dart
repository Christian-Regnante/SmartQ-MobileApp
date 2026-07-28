import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../services/domain/entities/service_entity.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_data_source.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ServiceEntity>> getOrganizationServices(String organizationId) async {
    try {
      return await remoteDataSource.getOrganizationServices(organizationId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw const ServerFailure('Failed to load organization services');
    }
  }

  @override
  Future<void> createService({
    required String organizationId,
    required String name,
    required String description,
    required String counterNumber,
    required int averageServiceTimeMinutes,
  }) async {
    try {
      await remoteDataSource.createService(
        organizationId: organizationId,
        name: name,
        description: description,
        counterNumber: counterNumber,
        averageServiceTimeMinutes: averageServiceTimeMinutes,
      );
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw const ServerFailure('Failed to create service');
    }
  }

  @override
  Future<void> updateService({
    required String serviceId,
    required String name,
    required String description,
    required String counterNumber,
    required int averageServiceTimeMinutes,
    required bool isActive,
  }) async {
    try {
      await remoteDataSource.updateService(
        serviceId: serviceId,
        name: name,
        description: description,
        counterNumber: counterNumber,
        averageServiceTimeMinutes: averageServiceTimeMinutes,
        isActive: isActive,
      );
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw const ServerFailure('Failed to update service');
    }
  }

  @override
  Future<void> toggleServiceStatus(String organizationId, String serviceId, bool isActive) async {
    try {
      await remoteDataSource.toggleServiceStatus(organizationId, serviceId, isActive);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw const ServerFailure('Failed to toggle service status');
    }
  }

  @override
  Future<void> deleteService({required String organizationId, required String serviceId}) async {
    try {
      await remoteDataSource.deleteService(organizationId, serviceId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw const ServerFailure('Failed to delete service from Firestore');
    }
  }

  @override
  Future<List<UserEntity>> getOrganizationStaff(String organizationId) async {
    try {
      return await remoteDataSource.getOrganizationStaff(organizationId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw const ServerFailure('Failed to load staff list');
    }
  }

  @override
  Future<void> provisionStaffUser({
    required String email,
    required String password,
    required String fullName,
    required String organizationId,
    required String serviceId,
  }) async {
    try {
      await remoteDataSource.provisionStaffUser(
        email: email,
        password: password,
        fullName: fullName,
        organizationId: organizationId,
        serviceId: serviceId,
      );
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw const ServerFailure('Failed to provision staff account');
    }
  }

  @override
  Future<void> updateStaffUser({
    required String staffId,
    required String fullName,
    required String email,
    required String serviceId,
    required bool isActive,
  }) async {
    try {
      await remoteDataSource.updateStaffUser(
        staffId: staffId,
        fullName: fullName,
        email: email,
        serviceId: serviceId,
        isActive: isActive,
      );
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw const ServerFailure('Failed to update staff member');
    }
  }

  @override
  Future<void> deleteStaffUser(String staffId) async {
    try {
      await remoteDataSource.deleteStaffUser(staffId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw const ServerFailure('Failed to delete staff member');
    }
  }
}
