import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../tickets/domain/entities/ticket_entity.dart';
import '../../domain/repositories/staff_repository.dart';
import '../datasources/staff_remote_data_source.dart';

class StaffRepositoryImpl implements StaffRepository {
  final StaffRemoteDataSource remoteDataSource;

  StaffRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<TicketEntity>> streamWaitingQueue(String serviceId) {
    return remoteDataSource.streamWaitingQueue(serviceId);
  }

  @override
  Stream<TicketEntity?> streamCurrentlyServing(String serviceId) {
    return remoteDataSource.streamCurrentlyServing(serviceId);
  }

  @override
  Future<TicketEntity?> callNextTicket({
    required String organizationId,
    required String serviceId,
    required String staffId,
    required String counterNumber,
  }) async {
    try {
      return await remoteDataSource.callNextTicket(
        organizationId: organizationId,
        serviceId: serviceId,
        staffId: staffId,
        counterNumber: counterNumber,
      );
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw const ServerFailure('Failed to call next ticket');
    }
  }

  @override
  Future<TicketEntity?> callSpecificTicket({
    required String ticketId,
    required String staffId,
    required String counterNumber,
  }) async {
    try {
      return await remoteDataSource.callSpecificTicket(
        ticketId: ticketId,
        staffId: staffId,
        counterNumber: counterNumber,
      );
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw const ServerFailure('Failed to call ticket');
    }
  }

  @override
  Future<void> completeCurrentTicket(String ticketId) async {
    try {
      await remoteDataSource.completeCurrentTicket(ticketId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw const ServerFailure('Failed to complete ticket');
    }
  }

  @override
  Future<void> skipCurrentTicket(String ticketId) async {
    try {
      await remoteDataSource.skipCurrentTicket(ticketId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw const ServerFailure('Failed to skip ticket');
    }
  }

  @override
  Future<void> cancelCurrentTicket(String ticketId, {required String staffId}) async {
    try {
      await remoteDataSource.cancelCurrentTicket(ticketId, staffId: staffId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw const ServerFailure('Failed to cancel ticket');
    }
  }

  @override
  Future<void> transferTicket(String ticketId, String newServiceId, String newServiceName) async {
    try {
      await remoteDataSource.transferTicket(ticketId, newServiceId, newServiceName);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw const ServerFailure('Failed to transfer ticket');
    }
  }
}
