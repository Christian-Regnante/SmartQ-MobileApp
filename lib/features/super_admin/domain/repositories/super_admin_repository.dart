import '../../../auth/domain/entities/user_entity.dart';
import '../../../organizations/domain/entities/organization_entity.dart';

abstract class SuperAdminRepository {
  Future<List<OrganizationEntity>> getAllOrganizations();
  Future<void> createOrganization({
    required String name,
    required String description,
    required String location,
    required String address,
    required String phoneNumber,
    required String email,
  });
  Future<void> updateOrganization({
    required String id,
    required String name,
    required String description,
    required String location,
    required String address,
    required String phoneNumber,
    required String email,
    required bool isActive,
  });
  Future<void> deleteOrganization(String organizationId);
  Future<void> toggleOrganizationStatus(String organizationId, bool isActive);
  Future<List<UserEntity>> getOrgAdmins();
  Future<void> provisionOrgAdmin({
    required String email,
    required String password,
    required String fullName,
    required String organizationId,
  });
  Future<void> updateOrgAdmin({
    required String adminId,
    required String fullName,
    required String email,
    String? organizationId,
    required bool isActive,
  });
  Future<void> deleteOrgAdmin({
    required String adminId,
    String? organizationId,
  });
  Future<List<Map<String, dynamic>>> getSystemAuditLogs();
}
