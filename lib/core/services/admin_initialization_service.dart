import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../constants/firebase_constants.dart';
import '../../shared/enums/user_role.dart';

class AdminInitializationService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AdminInitializationService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> initializeDefaultSuperAdmin() async {
    const superAdminEmail = 'christianregnantee@gmail.com';

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        // Do not perform unauthenticated queries or sign-in/sign-out cycles on launch
        return;
      }

      final currentEmail = currentUser.email?.toLowerCase();
      if (currentEmail == superAdminEmail) {
        // Ensure profile document in Firestore exists for active super admin
        await _firestore
            .collection(FirebaseConstants.usersCollection)
            .doc(currentUser.uid)
            .set({
          'id': currentUser.uid,
          'email': superAdminEmail,
          'fullName': 'Super Admin',
          'role': UserRole.superAdmin.value,
          'organizationId': null,
          'serviceIds': null,
          'isActive': true,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ AdminInitializationService non-critical info: $e');
      }
    }
  }
}
