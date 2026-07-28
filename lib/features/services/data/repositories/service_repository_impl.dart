import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/repositories/service_repository.dart';
import '../datasources/service_remote_data_source.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  final ServiceRemoteDataSource remoteDataSource;

  ServiceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ServiceEntity>> getServicesForOrganization(String organizationId) async {
    try {
      return await remoteDataSource.getServicesForOrganization(organizationId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw const ServerFailure('Failed to load services for organization');
    }
  }

  @override
  Future<ServiceEntity?> getServiceById(String organizationId, String serviceId) async {
    try {
      return await remoteDataSource.getServiceById(organizationId, serviceId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw const ServerFailure('Failed to load service details');
    }
  }
}
