import 'package:flutter_test/flutter_test.dart';
import 'package:smartq_mobile_app/shared/enums/user_role.dart';
import 'package:smartq_mobile_app/shared/enums/ticket_status.dart';
import 'package:smartq_mobile_app/features/tickets/data/models/ticket_model.dart';
import 'package:smartq_mobile_app/features/tickets/data/models/cancelled_ticket_model.dart';

void main() {
  group('UserRole Enum Unit Tests', () {
    test('1. Should parse super_admin string to UserRole.superAdmin', () {
      expect(UserRole.fromString('super_admin'), UserRole.superAdmin);
      expect(UserRole.fromString('superadmin'), UserRole.superAdmin);
      expect(UserRole.fromString('SUPER_ADMIN'), UserRole.superAdmin);
    });

    test('2. Should parse org_admin string to UserRole.orgAdmin', () {
      expect(UserRole.fromString('org_admin'), UserRole.orgAdmin);
      expect(UserRole.fromString('orgadmin'), UserRole.orgAdmin);
    });

    test('3. Should parse staff string to UserRole.staff', () {
      expect(UserRole.fromString('staff'), UserRole.staff);
    });

    test('4. Should default invalid or null strings to UserRole.client', () {
      expect(UserRole.fromString('invalid_role'), UserRole.client);
      expect(UserRole.fromString(null), UserRole.client);
    });
  });

  group('TicketStatus Enum Unit Tests', () {
    test('5. Should convert string values to correct TicketStatus', () {
      expect(TicketStatus.fromString('waiting'), TicketStatus.waiting);
      expect(TicketStatus.fromString('serving'), TicketStatus.serving);
      expect(TicketStatus.fromString('done'), TicketStatus.done);
      expect(TicketStatus.fromString('cancelled'), TicketStatus.cancelled);
    });
  });

  group('TicketModel Serialization Unit Tests', () {
    test('6. Should serialize TicketModel to Firestore map correctly', () {
      final now = DateTime.now();
      final model = TicketModel(
        id: 't123',
        ticketNumber: 'T001',
        userId: 'u456',
        organizationId: 'org1',
        organizationName: 'King Faisal Hospital',
        serviceId: 's1',
        serviceName: 'Dental',
        phoneNumber: '+250788123456',
        status: TicketStatus.waiting,
        position: 1,
        estimatedWaitMinutes: 10,
        createdAt: now,
      );

      final map = model.toFirestore();
      expect(map['ticketNumber'], equals('T001'));
      expect(map['userId'], equals('u456'));
      expect(map['organizationName'], equals('King Faisal Hospital'));
      expect(map['status'], equals('waiting'));
    });
  });

  group('CancelledTicketModel Unit Tests', () {
    test('7. Should create CancelledTicketModel with correct fields', () {
      final now = DateTime.now();
      final model = CancelledTicketModel(
        id: 'c123',
        originalTicketId: 't123',
        userId: 'u456',
        organizationId: 'org1',
        organizationName: 'Bank of Kigali',
        serviceId: 's2',
        serviceName: 'Teller',
        queueNumber: 'B005',
        phoneNumber: '+250788999888',
        cancellationReason: 'Client had to leave',
        cancelledBy: 'u456',
        cancelledAt: now,
        originalCreatedAt: now,
        originalStatus: 'waiting',
      );

      final map = model.toFirestore();
      expect(map['originalTicketId'], equals('t123'));
      expect(map['cancellationReason'], equals('Client had to leave'));
      expect(map['queueNumber'], equals('B005'));
    });
  });
}
