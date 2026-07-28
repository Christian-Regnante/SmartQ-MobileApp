import '../entities/service_entity.dart';

abstract class ServiceRepository {
  Future<List<ServiceEntity>> getServicesForOrganization(String organizationId);
  Future<ServiceEntity?> getServiceById(String organizationId, String serviceId);
}
