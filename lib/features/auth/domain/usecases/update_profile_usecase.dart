import 'package:flutter_application_1/core/error/failure.dart';
import 'package:flutter_application_1/core/usecase/usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_application_1/features/auth/domain/entities/user_profile.dart';
import 'package:flutter_application_1/features/auth/domain/repositories/auth_repository.dart';

class UpdateProfileUseCase implements UseCase<UserProfile, UserProfile> {
  const UpdateProfileUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<UserProfile>> call(UserProfile params) {
    if (params.fullName.trim().isEmpty) {
      return Future.value(const Left(AuthFailure('Họ và tên không được để trống.')));
    }
    return _repository.updateProfile(params);
  }
}
