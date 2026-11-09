import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_application_1/core/usecase/usecase.dart';
import 'package:flutter_application_1/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_application_1/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_application_1/features/auth/domain/entities/user_profile.dart';
import 'package:flutter_application_1/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_application_1/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:flutter_application_1/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_application_1/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutter_application_1/features/auth/domain/usecases/password_usecases.dart';
import 'package:flutter_application_1/features/auth/domain/usecases/register_usecase.dart';
import 'package:flutter_application_1/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:flutter_application_1/features/quiz/data/datasources/quiz_service.dart';
import 'package:flutter_application_1/features/documents/data/models/document.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  const url = String.fromEnvironment('SUPABASE_URL');
  const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  final dataSource = url.isEmpty || anonKey.isEmpty
      ? const UnavailableAuthDataSource()
      : SupabaseAuthDataSource(Supabase.instance.client);
  return AuthRepositoryImpl(dataSource);
});

final loginUseCaseProvider = Provider<LoginUseCase>(
  (ref) => LoginUseCase(ref.watch(authRepositoryProvider)),
);
final registerUseCaseProvider = Provider<RegisterUseCase>(
  (ref) => RegisterUseCase(ref.watch(authRepositoryProvider)),
);
final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>(
  (ref) => GetCurrentUserUseCase(ref.watch(authRepositoryProvider)),
);
final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>(
  (ref) => UpdateProfileUseCase(ref.watch(authRepositoryProvider)),
);
final logoutUseCaseProvider = Provider<LogoutUseCase>(
  (ref) => LogoutUseCase(ref.watch(authRepositoryProvider)),
);
final sendPasswordResetUseCaseProvider = Provider<SendPasswordResetUseCase>(
  (ref) => SendPasswordResetUseCase(ref.watch(authRepositoryProvider)),
);
final changePasswordUseCaseProvider = Provider<ChangePasswordUseCase>(
  (ref) => ChangePasswordUseCase(ref.watch(authRepositoryProvider)),
);

class AuthController extends StateNotifier<AsyncValue<UserProfile?>> {
  AuthController(this._ref) : super(const AsyncLoading()) {
    loadCurrentUser();
  }

  final Ref _ref;

  Future<void> loadCurrentUser() async {
    state = const AsyncLoading();
    final result = await _ref.read(getCurrentUserUseCaseProvider)(
      const NoParams(),
    );
    state = result.fold(
      (failure) => AsyncError(failure.message, StackTrace.current),
      AsyncData.new,
    );
  }

  Future<bool> login({required String email, required String password}) async {
    state = const AsyncLoading();
    final result = await _ref.read(loginUseCaseProvider)(
      LoginParams(email: email, password: password),
    );
    state = result.fold(
      (failure) => AsyncError(failure.message, StackTrace.current),
      (user) {
        _hydrateQuizBank();
        _hydrateDocuments();
        return AsyncData(user);
      },
    );
    return result.isRight();
  }

  Future<void> _hydrateDocuments() async {
    try {
      if (Supabase.instance.client.auth.currentUser != null) {
        await DocumentRepository.instance.hydrateFromSupabase();
      }
    } catch (_) {
      // Keep the local document catalogue when remote content is unavailable.
    }
  }

  Future<void> _hydrateQuizBank() async {
    try {
      if (Supabase.instance.client.auth.currentUser != null) {
        await QuizService.instance.hydrateFromSupabase(
          Supabase.instance.client,
        );
      }
    } catch (_) {
      // Keep the bundled question bank when remote content is unavailable.
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    final result = await _ref.read(registerUseCaseProvider)(
      RegisterParams(fullName: fullName, email: email, password: password),
    );
    state = result.fold(
      (failure) => AsyncError(failure.message, StackTrace.current),
      (_) => const AsyncData(null),
    );
    return result.isRight();
  }

  Future<bool> updateProfile(UserProfile profile) async {
    state = const AsyncLoading();
    final result = await _ref.read(updateProfileUseCaseProvider)(profile);
    state = result.fold(
      (failure) => AsyncError(failure.message, StackTrace.current),
      AsyncData.new,
    );
    return result.isRight();
  }

  Future<bool> logout() async {
    final result = await _ref.read(logoutUseCaseProvider)(const NoParams());
    if (result.isRight()) state = const AsyncData(null);
    return result.isRight();
  }

  Future<bool> sendPasswordReset(String email) async =>
      (await _ref.read(sendPasswordResetUseCaseProvider)(email)).isRight();

  Future<bool> changePassword(String password) async =>
      (await _ref.read(changePasswordUseCaseProvider)(password)).isRight();
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<UserProfile?>>(
      (ref) => AuthController(ref),
    );

final currentUserProvider = Provider<UserProfile?>((ref) {
  return ref.watch(authControllerProvider).valueOrNull;
});
