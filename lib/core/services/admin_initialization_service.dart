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
    const superAdminPassword = 'Superadmin123';

    try {
      User? user;

      // Step 1: Authenticate or create Super Admin in Firebase Auth FIRST
      try {
        final credential = await _auth.createUserWithEmailAndPassword(
          email: superAdminEmail,
          password: superAdminPassword,
        );
        user = credential.user;
        if (kDebugMode) {
          print('✅ Created Super Admin account in Firebase Auth: $superAdminEmail');
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          try {
            final credential = await _auth.signInWithEmailAndPassword(
              email: superAdminEmail,
              password: superAdminPassword,
            );
            user = credential.user;
            if (kDebugMode) {
              print('✅ Signed in as existing Super Admin in Firebase Auth: $superAdminEmail');
            }
          } catch (signInErr) {
            if (kDebugMode) {
              print('⚠️ Super Admin email exists in Firebase Auth but sign in failed: $signInErr');
            }
          }
        } else {
          if (kDebugMode) {
            print('⚠️ Firebase Auth creation error: ${e.message}');
          }
        }
      }

      if (user == null) {
        if (kDebugMode) {
          print('⚠️ Could not obtain Super Admin Firebase Auth user object.');
        }
        return;
      }

      // Step 2: Now that Firebase Auth is active, write the Firestore profile safely
      final uid = user.uid;

      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(uid)
          .set({
        'id': uid,
        'email': superAdminEmail,
        'fullName': 'Super Admin',
        'role': UserRole.superAdmin.value,
        'organizationId': null,
        'serviceIds': null,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Step 3: Write audit log entry
      try {
        await _firestore.collection(FirebaseConstants.adminLogsCollection).add({
          'action': 'SUPER_ADMIN_INITIALIZED',
          'details': 'Initialized default Super Admin profile: $superAdminEmail',
          'timestamp': FieldValue.serverTimestamp(),
        });
      } catch (_) {}

      if (kDebugMode) {
        print('🚀 Super Admin profile document successfully created/updated in Firestore (/users/$uid)!');
      }

      // Step 4: Sign out cleanly so user starts on unified login screen
      await _auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error in AdminInitializationService: $e');
      }
    }
  }
}
