import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../organizations/domain/entities/organization_entity.dart';
import '../../domain/repositories/super_admin_repository.dart';
import '../datasources/super_admin_remote_data_source.dart';

class SuperAdminRepositoryImpl implements SuperAdminRepository {
  final SuperAdminRemoteDataSource remoteDataSource;

  SuperAdminRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<OrganizationEntity>> getAllOrganizations() async {
    try {
      return await remoteDataSource.getAllOrganizations();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw const ServerFailure('Failed to fetch organizations');
    }
  }

  @override
  Future<void> createOrganization({
    required String name,
    required String description,
    required String location,
    required String address,
    required String phoneNumber,
    required String email,
  }) async {
    try {
      await remoteDataSource.createOrganization(
        name: name,
        description: description,
        location: location,
        address: address,
        phoneNumber: phoneNumber,
        email: email,
      );
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw const ServerFailure('Failed to create organization');
    }
  }

  @override
  Future<void> updateOrganization({
    required String id,
    required String name,
    required String description,
    required String location,
    required String address,
    required String phoneNumber,
    required String email,
    required bool isActive,
  }) async {
    try {
      await remoteDataSource.updateOrganization(
        id: id,
        name: name,
        description: description,
        location: location,
        address: address,
        phoneNumber: phoneNumber,
        email: email,
        isActive: isActive,
      );
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw const ServerFailure('Failed to update organization');
    }
  }

  @override
  Future<void> deleteOrganization(String organizationId) async {
    try {
      await remoteDataSource.deleteOrganization(organizationId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw const ServerFailure('Failed to delete organization');
    }
  }

  @override
  Future<void> toggleOrganizationStatus(String organizationId, bool isActive) async {
    try {
      await remoteDataSource.toggleOrganizationStatus(organizationId, isActive);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw const ServerFailure('Failed to update organization status');
    }
  }

  @override
  Future<List<UserEntity>> getOrgAdmins() async {
    try {
      return await remoteDataSource.getOrgAdmins();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw const ServerFailure('Failed to fetch org admins');
    }
  }

  @override
  Future<void> provisionOrgAdmin({
    required String email,
    required String password,
    required String fullName,
    required String organizationId,
  }) async {
    try {
      await remoteDataSource.provisionOrgAdmin(
        email: email,
        password: password,
        fullName: fullName,
        organizationId: organizationId,
      );
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw const ServerFailure('Failed to provision org admin');
    }
  }

  @override
  Future<void> updateOrgAdmin({
    required String adminId,
    required String fullName,
    required String email,
    String? organizationId,
    required bool isActive,
  }) async {
    try {
      await remoteDataSource.updateOrgAdmin(
        adminId: adminId,
        fullName: fullName,
        email: email,
        organizationId: organizationId,
        isActive: isActive,
      );
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw const ServerFailure('Failed to update org admin');
    }
  }

  @override
  Future<void> deleteOrgAdmin({
    required String adminId,
    String? organizationId,
  }) async {
    try {
      await remoteDataSource.deleteOrgAdmin(adminId: adminId, organizationId: organizationId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw const ServerFailure('Failed to delete org admin');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getSystemAuditLogs() async {
    try {
      return await remoteDataSource.getSystemAuditLogs();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw const ServerFailure('Failed to fetch audit logs');
    }
  }
}
