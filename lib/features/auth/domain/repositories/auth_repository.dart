import '../entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;
  Future<UserEntity> loginWithEmailAndPassword(String email, String password);
  Future<UserEntity> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  });
  Future<UserEntity> signInWithGoogle();
  Future<UserEntity> updatePhoneNumber(String phoneNumber);
  Future<void> logout();
  Future<void> sendPasswordResetEmail(String email);
  Future<UserEntity?> getCurrentUser();
}
