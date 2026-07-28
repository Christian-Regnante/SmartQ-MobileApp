import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/user_provisioning_service.dart';
import '../../../../shared/enums/user_role.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../organizations/data/models/organization_model.dart';

abstract class SuperAdminRemoteDataSource {
  Future<List<OrganizationModel>> getAllOrganizations();
  Future<void> createOrganization({
    required String name,
    required String description,
    required String location,
    required String address,
    required String phoneNumber,
    required String email,
  });
  Future<void> updateOrganization({
    required String id,
    required String name,
    required String description,
    required String location,
    required String address,
    required String phoneNumber,
    required String email,
    required bool isActive,
  });
  Future<void> deleteOrganization(String organizationId);
  Future<void> toggleOrganizationStatus(String organizationId, bool isActive);
  Future<List<UserModel>> getOrgAdmins();
  Future<void> provisionOrgAdmin({
    required String email,
    required String password,
    required String fullName,
    required String organizationId,
  });
  Future<void> updateOrgAdmin({
    required String adminId,
    required String fullName,
    required String email,
    String? organizationId,
    required bool isActive,
  });
  Future<void> deleteOrgAdmin({
    required String adminId,
    String? organizationId,
  });
  Future<List<Map<String, dynamic>>> getSystemAuditLogs();
}

class SuperAdminRemoteDataSourceImpl implements SuperAdminRemoteDataSource {
  final FirebaseFirestore _firestore;
  final UserProvisioningService _provisioningService;

  SuperAdminRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
    UserProvisioningService? provisioningService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _provisioningService = provisioningService ?? UserProvisioningService(firestore: firestore);

  @override
  Future<List<OrganizationModel>> getAllOrganizations() async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConstants.organizationsCollection)
          .get();

      final orgs = <OrganizationModel>[];

      for (final doc in snapshot.docs) {
        final baseOrg = OrganizationModel.fromFirestore(doc);

        // Compute real service count from /services
        int realServiceCount = 0;
        try {
          final servicesSnap = await _firestore
              .collection('services')
              .where('organizationId', isEqualTo: doc.id)
              .get();
          realServiceCount = servicesSnap.docs.length;
        } catch (_) {}

        // Compute real staff count from /users where role == 'staff'
        int realStaffCount = 0;
        try {
          final staffSnap = await _firestore
              .collection(FirebaseConstants.usersCollection)
              .where('role', isEqualTo: UserRole.staff.value)
              .where('organizationId', isEqualTo: doc.id)
              .get();
          realStaffCount = staffSnap.docs.length;
        } catch (_) {}

        // Resolve real assigned admin name
        String? realAdminName;
        try {
          if (baseOrg.adminId != null && baseOrg.adminId!.isNotEmpty) {
            final adminDoc = await _firestore.collection(FirebaseConstants.usersCollection).doc(baseOrg.adminId).get();
            if (adminDoc.exists) {
              realAdminName = adminDoc.data()?['fullName'] as String?;
            }
          }
          if (realAdminName == null) {
            final adminQuery = await _firestore
                .collection(FirebaseConstants.usersCollection)
                .where('role', isEqualTo: UserRole.orgAdmin.value)
                .where('organizationId', isEqualTo: doc.id)
                .limit(1)
                .get();
            if (adminQuery.docs.isNotEmpty) {
              realAdminName = adminQuery.docs.first.data()['fullName'] as String?;
            }
          }
        } catch (_) {}

        orgs.add(
          baseOrg.copyWith(
            serviceCount: realServiceCount,
            staffCount: realStaffCount,
            adminName: realAdminName ?? 'Unassigned',
          ),
        );
      }

      return orgs;
    } catch (e) {
      throw ServerException('Failed to fetch organizations: ${e.toString()}');
    }
  }

  @override
  Future<void> createOrganization({
    required String name,
    required String description,
    required String location,
    required String address,
    required String phoneNumber,
    required String email,
  }) async {
    try {
      final docRef = _firestore
          .collection(FirebaseConstants.organizationsCollection)
          .doc();

      final model = OrganizationModel(
        id: docRef.id,
        name: name,
        description: description,
        location: location,
        address: address,
        phoneNumber: phoneNumber,
        email: email,
        isActive: true,
        serviceCount: 0,
        staffCount: 0,
        createdAt: DateTime.now(),
      );

      await docRef.set(model.toFirestore());
      await _logActivity('CREATE_ORGANIZATION', 'Registered organization: $name (ID: ${docRef.id})');
    } catch (e) {
      throw ServerException('Failed to create organization: ${e.toString()}');
    }
  }

  @override
  Future<void> updateOrganization({
    required String id,
    required String name,
    required String description,
    required String location,
    required String address,
    required String phoneNumber,
    required String email,
    required bool isActive,
  }) async {
    try {
      await _firestore
          .collection(FirebaseConstants.organizationsCollection)
          .doc(id)
          .update({
        'name': name,
        'description': description,
        'location': location,
        'address': address,
        'phoneNumber': phoneNumber,
        'email': email,
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _logActivity('UPDATE_ORGANIZATION', 'Updated organization: $name (ID: $id)');
    } catch (e) {
      throw ServerException('Failed to update organization: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteOrganization(String organizationId) async {
    try {
      await _firestore
          .collection(FirebaseConstants.organizationsCollection)
          .doc(organizationId)
          .delete();

      await _logActivity('DELETE_ORGANIZATION', 'Deleted organization ID: $organizationId');
    } catch (e) {
      throw ServerException('Failed to delete organization: ${e.toString()}');
    }
  }

  @override
  Future<void> toggleOrganizationStatus(String organizationId, bool isActive) async {
    try {
      await _firestore
          .collection(FirebaseConstants.organizationsCollection)
          .doc(organizationId)
          .update({'isActive': isActive});

      await _logActivity('TOGGLE_ORGANIZATION_STATUS', 'Organization $organizationId isActive set to $isActive');
    } catch (e) {
      throw ServerException('Failed to update organization status: ${e.toString()}');
    }
  }

  @override
  Future<List<UserModel>> getOrgAdmins() async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .where('role', isEqualTo: UserRole.orgAdmin.value)
          .get();

      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException('Failed to fetch org admins: ${e.toString()}');
    }
  }

  @override
  Future<void> provisionOrgAdmin({
    required String email,
    required String password,
    required String fullName,
    required String organizationId,
  }) async {
    try {
      final existingAdminQuery = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .where('role', isEqualTo: UserRole.orgAdmin.value)
          .where('organizationId', isEqualTo: organizationId)
          .get();

      if (existingAdminQuery.docs.isNotEmpty) {
        throw const ServerException(
          'This organization already has an assigned administrator. Each organization can only have one Organization Admin.',
        );
      }

      final userModel = await _provisioningService.createSecondaryUser(
        email: email,
        password: password,
        fullName: fullName,
        role: UserRole.orgAdmin,
        organizationId: organizationId,
      );

      await _firestore
          .collection(FirebaseConstants.organizationsCollection)
          .doc(organizationId)
          .update({'adminId': userModel.id});

      await _logActivity('PROVISION_ORG_ADMIN', 'Provisioned Org Admin: $email for Org ID: $organizationId');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to provision org admin: ${e.toString()}');
    }
  }

  @override
  Future<void> updateOrgAdmin({
    required String adminId,
    required String fullName,
    required String email,
    String? organizationId,
    required bool isActive,
  }) async {
    try {
      if (organizationId != null && organizationId.isNotEmpty) {
        final existingAdminQuery = await _firestore
            .collection(FirebaseConstants.usersCollection)
            .where('role', isEqualTo: UserRole.orgAdmin.value)
            .where('organizationId', isEqualTo: organizationId)
            .get();

        for (final doc in existingAdminQuery.docs) {
          if (doc.id != adminId) {
            throw const ServerException(
              'Target organization already has an assigned administrator. Enforcing 1:1 Org-Admin rule.',
            );
          }
        }
      }

      final currentAdminDoc = await _firestore.collection(FirebaseConstants.usersCollection).doc(adminId).get();
      final oldOrgId = currentAdminDoc.data()?['organizationId'] as String?;

      if (oldOrgId != null && oldOrgId != organizationId) {
        await _firestore.collection(FirebaseConstants.organizationsCollection).doc(oldOrgId).update({'adminId': null});
      }

      await _firestore.collection(FirebaseConstants.usersCollection).doc(adminId).update({
        'fullName': fullName,
        'email': email,
        'organizationId': organizationId,
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (organizationId != null && organizationId.isNotEmpty) {
        await _firestore.collection(FirebaseConstants.organizationsCollection).doc(organizationId).update({'adminId': adminId});
      }

      await _logActivity('UPDATE_ORG_ADMIN', 'Updated Org Admin: $email (ID: $adminId)');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to update org admin: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteOrgAdmin({
    required String adminId,
    String? organizationId,
  }) async {
    try {
      await _firestore.collection(FirebaseConstants.usersCollection).doc(adminId).delete();

      if (organizationId != null && organizationId.isNotEmpty) {
        await _firestore.collection(FirebaseConstants.organizationsCollection).doc(organizationId).update({'adminId': null});
      }

      await _logActivity('DELETE_ORG_ADMIN', 'Deleted Org Admin ID: $adminId');
    } catch (e) {
      throw ServerException('Failed to delete org admin: ${e.toString()}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getSystemAuditLogs() async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConstants.adminLogsCollection)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'action': data['action'] as String? ?? 'EVENT',
          'details': data['details'] as String? ?? '',
          'timestamp': (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
        };
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _logActivity(String action, String details) async {
    try {
      await _firestore.collection(FirebaseConstants.adminLogsCollection).add({
        'action': action,
        'details': details,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }
}
