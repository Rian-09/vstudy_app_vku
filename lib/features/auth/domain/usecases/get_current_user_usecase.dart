import 'package:flutter_application_1/core/error/failure.dart';
import 'package:flutter_application_1/core/usecase/usecase.dart';
import 'package:flutter_application_1/features/auth/domain/entities/user_profile.dart';
import 'package:flutter_application_1/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase implements UseCase<UserProfile?, NoParams> {
  const GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<UserProfile?>> call(NoParams params) => _repository.currentUser();
}
