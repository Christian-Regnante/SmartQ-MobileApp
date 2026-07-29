import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../shared/enums/user_role.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Stream<User?> get authStateChanges;
  Future<UserModel> loginWithEmailAndPassword(String email, String password);
  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  });
  Future<UserModel> signInWithGoogle();
  Future<void> logout();
  Future<void> sendPasswordResetEmail(String email);
  Future<UserModel?> getUserProfile(String uid);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSourceImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  Future<UserModel> loginWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) throw const AuthException('User credentials not found');

      final cleanEmail = (user.email ?? email).trim().toLowerCase();
      final isSuperAdminEmail = cleanEmail == 'christianregnantee@gmail.com';

      var profile = await getUserProfile(user.uid);

      if (profile != null) {
        if (isSuperAdminEmail && profile.role != UserRole.superAdmin) {
          profile = UserModel(
            id: profile.id,
            email: profile.email,
            fullName: profile.fullName.isNotEmpty ? profile.fullName : 'Super Admin',
            phoneNumber: profile.phoneNumber,
            role: UserRole.superAdmin,
            organizationId: profile.organizationId,
            serviceId: profile.serviceId,
            serviceIds: profile.serviceIds,
            photoUrl: profile.photoUrl,
            isActive: profile.isActive,
            createdAt: profile.createdAt,
          );
          await _firestore
              .collection(FirebaseConstants.usersCollection)
              .doc(user.uid)
              .set(profile.toFirestore(), SetOptions(merge: true));
        }
        return profile;
      }

      // Fallback if profile document missing
      final role = isSuperAdminEmail ? UserRole.superAdmin : UserRole.client;
      final newModel = UserModel(
        id: user.uid,
        email: user.email ?? email,
        fullName: role == UserRole.superAdmin ? 'Super Admin' : (user.displayName ?? 'Client User'),
        role: role,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid)
          .set(newModel.toFirestore(), SetOptions(merge: true));

      return newModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Login failed');
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) throw const AuthException('Registration failed');

      final cleanEmail = email.trim().toLowerCase();
      final role = cleanEmail == 'christianregnantee@gmail.com' ? UserRole.superAdmin : UserRole.client;

      final userModel = UserModel(
        id: user.uid,
        email: email,
        fullName: fullName,
        phoneNumber: phoneNumber,
        role: role,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid)
          .set(userModel.toFirestore(), SetOptions(merge: true));

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Registration failed');
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  /// Google often returns "First Last" — greetings only need the first token.
  String _firstNameFrom(String? raw, {String fallback = 'User'}) {
    final trimmed = (raw ?? '').trim();
    if (trimmed.isEmpty) return fallback;
    return trimmed.split(RegExp(r'\s+')).first;
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw const AuthException('Google Sign-In cancelled');

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) throw const AuthException('Google Auth failed');

      final cleanEmail = (user.email ?? '').trim().toLowerCase();
      final isSuperAdminEmail = cleanEmail == 'christianregnantee@gmail.com';
      final firstName = _firstNameFrom(
        user.displayName ?? googleUser.displayName,
        fallback: isSuperAdminEmail ? 'Super Admin' : 'User',
      );

      final existingProfile = await getUserProfile(user.uid);
      if (existingProfile != null) {
        final needsNameTrim = existingProfile.fullName.trim().contains(RegExp(r'\s'));
        final needsSuperAdmin =
            isSuperAdminEmail && existingProfile.role != UserRole.superAdmin;

        if (needsNameTrim || needsSuperAdmin) {
          final updated = UserModel(
            id: existingProfile.id,
            email: existingProfile.email,
            fullName: needsNameTrim
                ? _firstNameFrom(existingProfile.fullName, fallback: firstName)
                : existingProfile.fullName,
            phoneNumber: existingProfile.phoneNumber,
            role: needsSuperAdmin ? UserRole.superAdmin : existingProfile.role,
            organizationId: existingProfile.organizationId,
            serviceId: existingProfile.serviceId,
            serviceIds: existingProfile.serviceIds,
            photoUrl: existingProfile.photoUrl,
            isActive: existingProfile.isActive,
            createdAt: existingProfile.createdAt,
          );
          await _firestore
              .collection(FirebaseConstants.usersCollection)
              .doc(user.uid)
              .set(updated.toFirestore(), SetOptions(merge: true));
          return updated;
        }
        return existingProfile;
      }

      final role = isSuperAdminEmail ? UserRole.superAdmin : UserRole.client;
      final newModel = UserModel(
        id: user.uid,
        email: user.email ?? '',
        fullName: firstName,
        photoUrl: user.photoURL,
        role: role,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid)
          .set(newModel.toFirestore(), SetOptions(merge: true));

      return newModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Google Sign-In failed');
    } on PlatformException catch (e) {
      final errStr = e.toString();
      if (errStr.contains('DEVELOPER_ERROR') || e.code == '10') {
        throw const AuthException('Google Sign-In requires SHA-1 fingerprint configuration in Firebase Console for Android. Please use Email Sign-In.');
      }
      if (errStr.contains('popup_closed') || errStr.contains('canceled') || e.code == 'sign_in_canceled') {
        throw const AuthException('Google Sign-In was cancelled.');
      }
      throw AuthException('Google Sign-In error: ${e.message}');
    } catch (e) {
      final errStr = e.toString();
      if (errStr.contains('popup_closed') || errStr.contains('canceled') || errStr.contains('DEVELOPER_ERROR')) {
        throw const AuthException('Google Sign-In failed or cancelled. Please use Email Sign-In.');
      }
      throw AuthException('Google Sign-In error: $errStr');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Failed to send password reset email');
    }
  }

  @override
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(uid)
          .get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }

      // Fallback: search by current Firebase Auth email if doc by uid missing
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null && currentUser.email != null && currentUser.email!.isNotEmpty) {
        final snap = await _firestore
            .collection(FirebaseConstants.usersCollection)
            .where('email', isEqualTo: currentUser.email)
            .get();

        if (snap.docs.isNotEmpty) {
          return UserModel.fromFirestore(snap.docs.first);
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}
