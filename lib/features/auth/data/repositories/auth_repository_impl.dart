import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fpdart/fpdart.dart';

import 'package:flutter_application_1/core/error/failure.dart';
import 'package:flutter_application_1/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_application_1/features/auth/data/models/user_profile_model.dart';
import 'package:flutter_application_1/features/auth/domain/entities/user_profile.dart';
import 'package:flutter_application_1/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  Future<Result<UserProfile>> login({
    required String email,
    required String password,
  }) => _guard(() async {
    final model = await _remote.login(email: email, password: password);
    return model.toEntity();
  });

  @override
  Future<Result<void>> register({
    required String fullName,
    required String email,
    required String password,
  }) => _guard(() => _remote.register(
    fullName: fullName,
    email: email,
    password: password,
  ));

  @override
  Future<Result<UserProfile?>> currentUser() => _guard(() async {
    final model = await _remote.currentUser();
    return model?.toEntity();
  });

  @override
  Future<Result<UserProfile>> updateProfile(UserProfile profile) => _guard(() async {
    final model = await _remote.updateProfile(UserProfileModel.fromEntity(profile));
    return model.toEntity();
  });

  @override
  Future<Result<void>> logout() => _guard(_remote.logout);

  @override
  Future<Result<void>> sendPasswordReset(String email) =>
      _guard(() => _remote.sendPasswordReset(email));

  @override
  Future<Result<void>> changePassword(String password) =>
      _guard(() => _remote.changePassword(password));

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on AuthException catch (error) {
      return Left(AuthFailure(error.message, code: error.statusCode));
    } on PostgrestException catch (error) {
      return Left(AuthFailure(error.message, code: error.code));
    } catch (error) {
      return Left(AuthFailure('Không thể kết nối dịch vụ xác thực: $error'));
    }
  }
}
