import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/firebase_constants.dart';
import '../errors/exceptions.dart';
import '../../shared/enums/user_role.dart';
import '../../features/auth/data/models/user_model.dart';

class UserProvisioningService {
  final FirebaseFirestore _firestore;

  UserProvisioningService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Creates a Firebase Auth user account and matching Firestore `/users/{uid}` document
  /// using a secondary FirebaseApp instance so the active admin session is not signed out.
  Future<UserModel> createSecondaryUser({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? organizationId,
    String? serviceId,
    List<String>? serviceIds,
  }) async {
    FirebaseApp? secondaryApp;
    try {
      const secondaryAppName = 'SecondaryUserProvisioningApp';
      try {
        secondaryApp = Firebase.app(secondaryAppName);
      } catch (_) {
        secondaryApp = await Firebase.initializeApp(
          name: secondaryAppName,
          options: Firebase.app().options,
        );
      }

      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const ServerException('Failed to create secondary user in Firebase Auth.');
      }

      final uid = user.uid;

      final effectiveServiceId = serviceId ?? (serviceIds?.isNotEmpty == true ? serviceIds!.first : null);
      final effectiveServiceIds = serviceIds ?? (effectiveServiceId != null ? [effectiveServiceId] : null);

      final userModel = UserModel(
        id: uid,
        email: email,
        fullName: fullName,
        role: role,
        organizationId: organizationId,
        serviceId: effectiveServiceId,
        serviceIds: effectiveServiceIds,
        isActive: true,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(uid)
          .set(userModel.toFirestore());

      await secondaryAuth.signOut();

      return userModel;
    } on FirebaseAuthException catch (e) {
      String msg;
      switch (e.code) {
        case 'email-already-in-use':
          msg = 'An account with this email address ($email) already exists in Firebase Auth. Please use a different email or select an existing account.';
          break;
        case 'invalid-email':
          msg = 'The email address ($email) is invalid.';
          break;
        case 'weak-password':
          msg = 'The password provided is too weak. Please use at least 6 characters.';
          break;
        default:
          msg = e.message ?? 'Failed to create user account in Firebase Auth (${e.code}).';
      }
      throw ServerException(msg);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to provision user: ${e.toString()}');
    }
  }
}
