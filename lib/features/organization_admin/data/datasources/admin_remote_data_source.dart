import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/user_provisioning_service.dart';
import '../../../../shared/enums/user_role.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../services/data/models/service_model.dart';

abstract class AdminRemoteDataSource {
  Future<List<ServiceModel>> getOrganizationServices(String organizationId);
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
  Future<void> deleteService(String organizationId, String serviceId);
  Future<List<UserModel>> getOrganizationStaff(String organizationId);
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

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final FirebaseFirestore _firestore;
  final UserProvisioningService _provisioningService;

  AdminRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
    UserProvisioningService? provisioningService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _provisioningService = provisioningService ?? UserProvisioningService(firestore: firestore);

  @override
  Future<List<ServiceModel>> getOrganizationServices(String organizationId) async {
    try {
      final snapshot = await _firestore
          .collection('services')
          .where('organizationId', isEqualTo: organizationId)
          .get();

      final services = <ServiceModel>[];
      for (final doc in snapshot.docs) {
        final service = ServiceModel.fromFirestore(doc, organizationId);

        // Compute real active waiting queue count for each service desk
        int realQueueCount = 0;
        try {
          final ticketsSnap = await _firestore
              .collection(FirebaseConstants.ticketsCollection)
              .where('serviceId', isEqualTo: doc.id)
              .where('status', isEqualTo: 'waiting')
              .get();
          realQueueCount = ticketsSnap.docs.length;
        } catch (_) {}

        services.add(
          ServiceModel(
            id: service.id,
            organizationId: service.organizationId,
            name: service.name,
            description: service.description,
            counterNumber: service.counterNumber,
            averageServiceTimeMinutes: service.averageServiceTimeMinutes,
            isActive: service.isActive,
            currentQueueCount: realQueueCount,
          ),
        );
      }

      return services;
    } catch (e) {
      throw ServerException('Failed to fetch organization services: ${e.toString()}');
    }
  }

  @override
  Future<void> createService({
    required String organizationId,
    required String name,
    required String description,
    required String counterNumber,
    required int averageServiceTimeMinutes,
  }) async {
    try {
      final docRef = _firestore.collection('services').doc();

      final model = ServiceModel(
        id: docRef.id,
        organizationId: organizationId,
        name: name,
        description: description,
        counterNumber: counterNumber,
        averageServiceTimeMinutes: averageServiceTimeMinutes,
        isActive: true,
        currentQueueCount: 0,
      );

      await docRef.set(model.toFirestore());
    } catch (e) {
      throw ServerException('Failed to create service in Firestore: ${e.toString()}');
    }
  }

  @override
  Future<void> updateService({
    required String serviceId,
    required String name,
    required String description,
    required String counterNumber,
    required int averageServiceTimeMinutes,
    required bool isActive,
  }) async {
    try {
      await _firestore.collection('services').doc(serviceId).update({
        'name': name,
        'description': description,
        'counterNumber': counterNumber,
        'averageServiceTimeMinutes': averageServiceTimeMinutes,
        'waitingTime': averageServiceTimeMinutes,
        'averageServiceTime': averageServiceTimeMinutes,
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException('Failed to update service: ${e.toString()}');
    }
  }

  @override
  Future<void> toggleServiceStatus(String organizationId, String serviceId, bool isActive) async {
    try {
      await _firestore
          .collection('services')
          .doc(serviceId)
          .update({'isActive': isActive});
    } catch (e) {
      throw ServerException('Failed to update service status: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteService(String organizationId, String serviceId) async {
    try {
      await _firestore
          .collection('services')
          .doc(serviceId)
          .delete();

      // Clean up staff assignments if staff is assigned to deleted service
      final staffQuery = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .where('serviceId', isEqualTo: serviceId)
          .get();

      for (final doc in staffQuery.docs) {
        await _firestore.collection(FirebaseConstants.usersCollection).doc(doc.id).update({
          'serviceId': null,
          'serviceIds': FieldValue.arrayRemove([serviceId]),
        });
      }
    } catch (e) {
      throw ServerException('Failed to delete service from Firestore: ${e.toString()}');
    }
  }

  @override
  Future<List<UserModel>> getOrganizationStaff(String organizationId) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .where('role', isEqualTo: UserRole.staff.value)
          .where('organizationId', isEqualTo: organizationId)
          .get();

      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException('Failed to fetch staff: ${e.toString()}');
    }
  }

  @override
  Future<void> provisionStaffUser({
    required String email,
    required String password,
    required String fullName,
    required String organizationId,
    required String serviceId,
  }) async {
    try {
      await _provisioningService.createSecondaryUser(
        email: email,
        password: password,
        fullName: fullName,
        role: UserRole.staff,
        organizationId: organizationId,
        serviceId: serviceId,
        serviceIds: [serviceId],
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to provision staff: ${e.toString()}');
    }
  }

  @override
  Future<void> updateStaffUser({
    required String staffId,
    required String fullName,
    required String email,
    required String serviceId,
    required bool isActive,
  }) async {
    try {
      await _firestore.collection(FirebaseConstants.usersCollection).doc(staffId).update({
        'fullName': fullName,
        'email': email,
        'serviceId': serviceId,
        'serviceIds': [serviceId],
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException('Failed to update staff member: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteStaffUser(String staffId) async {
    try {
      await _firestore.collection(FirebaseConstants.usersCollection).doc(staffId).delete();
    } catch (e) {
      throw ServerException('Failed to delete staff member: ${e.toString()}');
    }
  }
}
