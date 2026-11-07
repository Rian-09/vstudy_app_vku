import 'package:flutter_application_1/core/error/failure.dart';
import 'package:flutter_application_1/features/auth/domain/entities/user_profile.dart';

abstract interface class AuthRepository {
  Future<Result<UserProfile>> login({
    required String email,
    required String password,
  });

  Future<Result<void>> register({
    required String fullName,
    required String email,
    required String password,
  });

  Future<Result<UserProfile?>> currentUser();

  Future<Result<UserProfile>> updateProfile(UserProfile profile);

  Future<Result<void>> logout();

  Future<Result<void>> sendPasswordReset(String email);

  Future<Result<void>> changePassword(String password);
}
