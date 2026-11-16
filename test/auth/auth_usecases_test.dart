import 'package:flutter_application_1/core/error/failure.dart';
import 'package:flutter_application_1/core/usecase/usecase.dart';
import 'package:flutter_application_1/features/auth/domain/entities/user_profile.dart';
import 'package:flutter_application_1/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_application_1/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:flutter_application_1/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_application_1/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutter_application_1/features/auth/domain/usecases/password_usecases.dart';
import 'package:flutter_application_1/features/auth/domain/usecases/register_usecase.dart';
import 'package:flutter_application_1/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

void main() {
  late RecordingAuthRepository repository;
  late UserProfile profile;

  setUp(() {
    repository = RecordingAuthRepository();
    profile = UserProfile(
      id: 'user-1',
      fullName: 'Nguyễn Văn A',
      email: 'a@vku.udn.vn',
      className: '22IT1',
      major: 'Công nghệ thông tin',
      birthday: null,
      cohort: 'K22',
      subjects: const ['Triết học'],
      avatarUrl: null,
      role: 'STUDENT',
      isLocked: false,
    );
  });

  test('login validates VKU email and normalizes valid input', () async {
    final useCase = LoginUseCase(repository);

    final invalid = await useCase(
      const LoginParams(email: 'student@gmail.com', password: 'password123'),
    );
    expect(invalid.isLeft(), isTrue);

    final valid = await useCase(
      const LoginParams(email: '  A@VKU.UDN.VN ', password: 'password123'),
    );
    expect(valid.isRight(), isTrue);
    expect(repository.lastEmail, 'a@vku.udn.vn');
  });

  test('register validates fields and forwards trimmed values', () async {
    final useCase = RegisterUseCase(repository);

    expect(
      (await useCase(const RegisterParams(
        fullName: '',
        email: 'a@vku.udn.vn',
        password: 'password123',
      ))).isLeft(),
      isTrue,
    );
    expect(
      (await useCase(const RegisterParams(
        fullName: 'A',
        email: 'a@vku.udn.vn',
        password: 'short',
      ))).isLeft(),
      isTrue,
    );

    final result = await useCase(const RegisterParams(
      fullName: '  Nguyễn Văn A  ',
      email: ' A@VKU.UDN.VN ',
      password: 'password123',
    ));
    expect(result.isRight(), isTrue);
    expect(repository.lastFullName, 'Nguyễn Văn A');
    expect(repository.lastEmail, 'a@vku.udn.vn');
  });

  test('profile, session, and password usecases delegate correctly', () async {
    final current = await GetCurrentUserUseCase(repository)(const NoParams());
    expect(current.isRight(), isTrue);
    expect(current.getRight().toNullable()?.id, profile.id);
    expect(
      (await UpdateProfileUseCase(repository)(profile)).isRight(),
      isTrue,
    );
    expect((await LogoutUseCase(repository)(const NoParams())).isRight(), isTrue);
    expect(
      (await SendPasswordResetUseCase(repository)(' A@VKU.UDN.VN ')).isRight(),
      isTrue,
    );
    expect(
      (await ChangePasswordUseCase(repository)('short')).isLeft(),
      isTrue,
    );
    expect(
      (await ChangePasswordUseCase(repository)('newpassword')).isRight(),
      isTrue,
    );
    expect(repository.lastEmail, 'a@vku.udn.vn');
  });

  test('profile update rejects an empty name', () async {
    final result = await UpdateProfileUseCase(repository)(
      profile.copyWith(fullName: '  '),
    );
    expect(result.isLeft(), isTrue);
  });
}

class RecordingAuthRepository implements AuthRepository {
  String? lastEmail;
  String? lastFullName;

  @override
  Future<Result<UserProfile?>> currentUser() async => Right(_profile);

  @override
  Future<Result<UserProfile>> login({
    required String email,
    required String password,
  }) async {
    lastEmail = email;
    return Right(_profile);
  }

  @override
  Future<Result<void>> logout() async => const Right(null);

  @override
  Future<Result<void>> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    lastFullName = fullName;
    lastEmail = email;
    return const Right(null);
  }

  @override
  Future<Result<void>> sendPasswordReset(String email) async {
    lastEmail = email;
    return const Right(null);
  }

  @override
  Future<Result<void>> changePassword(String password) async => const Right(null);

  @override
  Future<Result<UserProfile>> updateProfile(UserProfile profile) async =>
      Right(profile);

  UserProfile get _profile => UserProfile(
    id: 'user-1',
    fullName: 'Nguyễn Văn A',
    email: 'a@vku.udn.vn',
    className: '22IT1',
    major: 'Công nghệ thông tin',
    birthday: null,
    cohort: 'K22',
    subjects: const [],
    avatarUrl: null,
    role: 'STUDENT',
    isLocked: false,
  );
}
