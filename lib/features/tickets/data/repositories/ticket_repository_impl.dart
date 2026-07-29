import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/ticket_entity.dart';
import '../../domain/entities/cancelled_ticket_entity.dart';
import '../../domain/repositories/ticket_repository.dart';
import '../datasources/ticket_remote_data_source.dart';

class TicketRepositoryImpl implements TicketRepository {
  final TicketRemoteDataSource remoteDataSource;

  TicketRepositoryImpl({required this.remoteDataSource});

  @override
  Future<TicketEntity> joinQueue({
    required String organizationId,
    required String serviceId,
    required String userId,
    required String phoneNumber,
  }) async {
    try {
      return await remoteDataSource.joinQueue(
        organizationId: organizationId,
        serviceId: serviceId,
        userId: userId,
        phoneNumber: phoneNumber,
      );
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw const ServerFailure('Failed to join queue');
    }
  }

  @override
  Stream<TicketEntity?> streamActiveTicket(String userId) {
    return remoteDataSource.streamActiveTicket(userId);
  }

  @override
  Stream<List<TicketEntity>> streamTicketHistory(String userId) {
    return remoteDataSource.streamTicketHistory(userId);
  }

  @override
  Stream<List<CancelledTicketEntity>> streamUserCancelledTickets(String userId) {
    return remoteDataSource.streamUserCancelledTickets(userId);
  }

  @override
  Future<void> cancelTicket(
    String ticketId, {
    String? userId,
    String? cancelledBy,
    String? cancellationReason,
  }) async {
    try {
      await remoteDataSource.cancelTicket(
        ticketId,
        userId: userId,
        cancelledBy: cancelledBy,
        cancellationReason: cancellationReason,
      );
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw const ServerFailure('Failed to cancel ticket');
    }
  }
}
