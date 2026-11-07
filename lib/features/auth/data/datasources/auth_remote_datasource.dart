import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_application_1/features/auth/data/models/user_profile_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<UserProfileModel> login({
    required String email,
    required String password,
  });

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  });

  Future<UserProfileModel?> currentUser();

  Future<UserProfileModel> updateProfile(UserProfileModel profile);

  Future<void> logout();

  Future<void> sendPasswordReset(String email);

  Future<void> changePassword(String password);
}

class UnavailableAuthDataSource implements AuthRemoteDataSource {
  const UnavailableAuthDataSource();

  Never _throw() => throw const AuthException(
    'Chưa cấu hình Supabase. Hãy chạy ứng dụng với SUPABASE_URL và SUPABASE_ANON_KEY.',
  );

  @override
  Future<UserProfileModel> login({required String email, required String password}) async => _throw();

  @override
  Future<void> register({required String fullName, required String email, required String password}) async => _throw();

  @override
  Future<UserProfileModel?> currentUser() async => _throw();

  @override
  Future<UserProfileModel> updateProfile(UserProfileModel profile) async => _throw();

  @override
  Future<void> logout() async => _throw();

  @override
  Future<void> sendPasswordReset(String email) async => _throw();

  @override
  Future<void> changePassword(String password) async => _throw();
}

class SupabaseAuthDataSource implements AuthRemoteDataSource {
  SupabaseAuthDataSource(this._client);

  final SupabaseClient _client;

  @override
  Future<UserProfileModel> login({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(email: email, password: password);
    final profile = await currentUser();
    if (profile == null) {
      await _client.auth.signOut();
      throw const AuthException('Không tìm thấy hồ sơ người dùng.');
    }
    if (profile.isLocked) {
      await _client.auth.signOut();
      throw const AuthException('Tài khoản đã bị khóa.');
    }
    return profile;
  }

  @override
  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
  }

  @override
  Future<UserProfileModel?> currentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final row = await _client
        .from('users')
        .select()
        .eq('id', user.id)
        .maybeSingle();
    if (row == null) return null;
    return UserProfileModel.fromJson(row);
  }

  @override
  Future<UserProfileModel> updateProfile(UserProfileModel profile) async {
    final row = await _client
        .from('users')
        .update(profile.toJson())
        .eq('id', profile.id)
        .select()
        .single();
    return UserProfileModel.fromJson(row);
  }

  @override
  Future<void> logout() => _client.auth.signOut();

  @override
  Future<void> sendPasswordReset(String email) => _client.auth.resetPasswordForEmail(email);

  @override
  Future<void> changePassword(String password) async {
    await _client.auth.updateUser(UserAttributes(password: password));
  }
}
