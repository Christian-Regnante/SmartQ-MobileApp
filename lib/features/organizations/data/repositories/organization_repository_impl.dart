import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/organization_entity.dart';
import '../../domain/repositories/organization_repository.dart';
import '../datasources/organization_remote_data_source.dart';

class OrganizationRepositoryImpl implements OrganizationRepository {
  final OrganizationRemoteDataSource remoteDataSource;

  OrganizationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<OrganizationEntity>> getActiveOrganizations({String? searchQuery}) async {
    try {
      return await remoteDataSource.getActiveOrganizations(searchQuery: searchQuery);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw const ServerFailure('Failed to load active organizations');
    }
  }

  @override
  Future<OrganizationEntity?> getOrganizationById(String id) async {
    try {
      return await remoteDataSource.getOrganizationById(id);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw const ServerFailure('Failed to load organization details');
    }
  }
}
