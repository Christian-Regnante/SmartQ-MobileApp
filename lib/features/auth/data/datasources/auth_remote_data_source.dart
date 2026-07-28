import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

      final profile = await getUserProfile(user.uid);
      if (profile != null) return profile;

      // Fallback if profile document missing
      final newModel = UserModel(
        id: user.uid,
        email: user.email ?? email,
        fullName: user.displayName ?? 'Client User',
        role: UserRole.client,
        createdAt: DateTime.now(),
      );
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid)
          .set(newModel.toFirestore());
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

      final userModel = UserModel(
        id: user.uid,
        email: email,
        fullName: fullName,
        phoneNumber: phoneNumber,
        role: UserRole.client,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid)
          .set(userModel.toFirestore());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Registration failed');
    } catch (e) {
      throw AuthException(e.toString());
    }
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

      final existingProfile = await getUserProfile(user.uid);
      if (existingProfile != null) return existingProfile;

      final newModel = UserModel(
        id: user.uid,
        email: user.email ?? '',
        fullName: user.displayName ?? googleUser.displayName ?? 'User',
        photoUrl: user.photoURL,
        role: UserRole.client,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid)
          .set(newModel.toFirestore());

      return newModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Google Sign-In failed');
    } catch (e) {
      final errStr = e.toString();
      if (errStr.contains('popup_closed') || errStr.contains('canceled')) {
        throw const AuthException('Google Sign-In popup was closed.');
      }
      if (errStr.contains('invalid_client')) {
        throw const AuthException('Google Web OAuth Client ID not configured. Please use Email Sign-In.');
      }
      throw AuthException('Google Sign-In error: $errStr');
    }
  }

  @override
  Future<void> logout() async {
    await _googleSignIn.signOut();
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
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } catch (e) {
      return null;
    }
  }
}
