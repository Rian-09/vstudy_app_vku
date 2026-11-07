import 'package:flutter_application_1/core/error/failure.dart';
import 'package:flutter_application_1/core/usecase/usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_application_1/features/auth/domain/repositories/auth_repository.dart';

class RegisterParams {
  const RegisterParams({
    required this.fullName,
    required this.email,
    required this.password,
  });

  final String fullName;
  final String email;
  final String password;
}

class RegisterUseCase implements UseCase<void, RegisterParams> {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<void>> call(RegisterParams params) {
    final email = params.email.trim().toLowerCase();
    if (!_isVkuEmail(email)) {
      return Future.value(
        const Left(AuthFailure('Chỉ được sử dụng email @vku.udn.vn.')),
      );
    }
    if (params.fullName.trim().isEmpty) {
      return Future.value(const Left(AuthFailure('Họ và tên không được để trống.')));
    }
    if (params.password.length < 8) {
      return Future.value(const Left(AuthFailure('Mật khẩu phải có ít nhất 8 ký tự.')));
    }
    return _repository.register(
      fullName: params.fullName.trim(),
      email: email,
      password: params.password,
    );
  }

  static bool _isVkuEmail(String email) => email.endsWith('@vku.udn.vn');
}
