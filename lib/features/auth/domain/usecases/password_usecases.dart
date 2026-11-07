import 'package:flutter_application_1/core/error/failure.dart';
import 'package:flutter_application_1/core/usecase/usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_application_1/features/auth/domain/repositories/auth_repository.dart';

class SendPasswordResetUseCase implements UseCase<void, String> {
  const SendPasswordResetUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<void>> call(String email) {
    final normalizedEmail = email.trim().toLowerCase();
    if (!normalizedEmail.endsWith('@vku.udn.vn')) {
      return Future.value(
        const Left(AuthFailure('Chỉ được sử dụng email @vku.udn.vn.')),
      );
    }
    return _repository.sendPasswordReset(normalizedEmail);
  }
}

class ChangePasswordUseCase implements UseCase<void, String> {
  const ChangePasswordUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<void>> call(String password) {
    if (password.length < 8) {
      return Future.value(const Left(AuthFailure('Mật khẩu phải có ít nhất 8 ký tự.')));
    }
    return _repository.changePassword(password);
  }
}
