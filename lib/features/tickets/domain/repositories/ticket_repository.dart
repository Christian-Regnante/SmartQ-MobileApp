import '../entities/ticket_entity.dart';
import '../entities/cancelled_ticket_entity.dart';

abstract class TicketRepository {
  Future<TicketEntity> joinQueue({
    required String organizationId,
    required String serviceId,
    required String userId,
    required String phoneNumber,
  });

  Stream<TicketEntity?> streamActiveTicket(String userId);

  Stream<List<TicketEntity>> streamTicketHistory(String userId);

  Stream<List<CancelledTicketEntity>> streamUserCancelledTickets(String userId);

  Future<void> cancelTicket(
    String ticketId, {
    String? userId,
    String? cancelledBy,
    String? cancellationReason,
  });
}
