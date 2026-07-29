import '../../../tickets/domain/entities/ticket_entity.dart';

abstract class StaffRepository {
  Stream<List<TicketEntity>> streamWaitingQueue(String serviceId);
  Stream<TicketEntity?> streamCurrentlyServing(String serviceId);
  Future<TicketEntity?> callNextTicket({
    required String organizationId,
    required String serviceId,
    required String staffId,
    required String counterNumber,
  });
  Future<TicketEntity?> callSpecificTicket({
    required String ticketId,
    required String staffId,
    required String counterNumber,
  });
  Future<void> completeCurrentTicket(String ticketId);
  Future<void> skipCurrentTicket(String ticketId);
  Future<void> cancelCurrentTicket(String ticketId, {required String staffId});
  Future<void> transferTicket(String ticketId, String newServiceId, String newServiceName);
}
