import '../entities/organization_entity.dart';

abstract class OrganizationRepository {
  Future<List<OrganizationEntity>> getActiveOrganizations({String? searchQuery});
  Future<OrganizationEntity?> getOrganizationById(String id);
}
