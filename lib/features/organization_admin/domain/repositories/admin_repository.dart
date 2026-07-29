import '../../../auth/domain/entities/user_entity.dart';
import '../../../services/domain/entities/service_entity.dart';

abstract class AdminRepository {
  Future<List<ServiceEntity>> getOrganizationServices(String organizationId);
  Future<void> createService({
    required String organizationId,
    required String name,
    required String description,
    required String counterNumber,
    required int averageServiceTimeMinutes,
  });
  Future<void> updateService({
    required String serviceId,
    required String name,
    required String description,
    required String counterNumber,
    required int averageServiceTimeMinutes,
    required bool isActive,
  });
  Future<void> toggleServiceStatus(String organizationId, String serviceId, bool isActive);
  Future<void> deleteService({required String organizationId, required String serviceId});
  Future<List<UserEntity>> getOrganizationStaff(String organizationId);
  Future<void> provisionStaffUser({
    required String email,
    required String password,
    required String fullName,
    required String organizationId,
    required String serviceId,
  });
  Future<void> updateStaffUser({
    required String staffId,
    required String fullName,
    required String email,
    required String serviceId,
    required bool isActive,
  });
  Future<void> deleteStaffUser(String staffId);
}
