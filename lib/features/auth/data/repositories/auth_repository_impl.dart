import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<UserEntity?> get authStateChanges {
    return remoteDataSource.authStateChanges.asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return await remoteDataSource.getUserProfile(firebaseUser.uid);
    });
  }

  @override
  Future<UserEntity> loginWithEmailAndPassword(String email, String password) async {
    try {
      return await remoteDataSource.loginWithEmailAndPassword(email, password);
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      throw const AuthFailure('An unexpected authentication error occurred.');
    }
  }

  @override
  Future<UserEntity> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    try {
      return await remoteDataSource.registerWithEmailAndPassword(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
      );
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      throw const AuthFailure('An unexpected registration error occurred.');
    }
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    try {
      return await remoteDataSource.signInWithGoogle();
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      throw const AuthFailure('Google sign-in failed.');
    }
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email);
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final currentUser = await remoteDataSource.authStateChanges.first;
    if (currentUser == null) return null;
    return await remoteDataSource.getUserProfile(currentUser.uid);
  }
}
