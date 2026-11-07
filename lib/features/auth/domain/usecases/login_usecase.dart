import 'package:flutter_application_1/core/error/failure.dart';
import 'package:flutter_application_1/core/usecase/usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_application_1/features/auth/domain/entities/user_profile.dart';
import 'package:flutter_application_1/features/auth/domain/repositories/auth_repository.dart';

class LoginParams {
  const LoginParams({required this.email, required this.password});

  final String email;
  final String password;
}

class LoginUseCase implements UseCase<UserProfile, LoginParams> {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<UserProfile>> call(LoginParams params) {
    final email = params.email.trim().toLowerCase();
    if (!_isVkuEmail(email)) {
      return Future.value(
        const Left(AuthFailure('Chỉ được sử dụng email @vku.udn.vn.')),
      );
    }
    return _repository.login(email: email, password: params.password);
  }

  static bool _isVkuEmail(String email) => email.endsWith('@vku.udn.vn');
}
