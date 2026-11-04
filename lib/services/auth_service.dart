import 'package:flutter/foundation.dart';

@immutable
class StudyUser {
  const StudyUser({
    required this.name,
    required this.email,
    required this.className,
    required this.major,
    required this.birthday,
    required this.subjects,
    required this.avatarAsset,
  });

  final String name;
  final String email;
  final String className;
  final String major;
  final DateTime birthday;
  final List<String> subjects;
  final String avatarAsset;

  StudyUser copyWith({
    String? name,
    String? email,
    String? className,
    String? major,
    DateTime? birthday,
    List<String>? subjects,
    String? avatarAsset,
  }) {
    return StudyUser(
      name: name ?? this.name,
      email: email ?? this.email,
      className: className ?? this.className,
      major: major ?? this.major,
      birthday: birthday ?? this.birthday,
      subjects: subjects ?? this.subjects,
      avatarAsset: avatarAsset ?? this.avatarAsset,
    );
  }
}

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();
  static final _demoAccounts = <String, _RegisteredAccount>{
    'people@gmail.com': _RegisteredAccount(
      user: StudyUser(
        name: 'Tom',
        email: 'tom@vku.udn.vn',
        className: '23SE4',
        major: 'Công nghệ phần mềm',
        birthday: DateTime(2005, 2, 18),
        subjects: const ['UX/UI', 'Java', 'Giải tích', 'Python', 'Pháp luật'],
        avatarAsset: 'assets/images/profile/profile_avatar.png',
      ),
      password: 'admin123',
    ),
  };

  final Map<String, _RegisteredAccount> _accounts = {};
  StudyUser? _currentUser;
  String? _currentAccountKey;

  StudyUser? get currentUser => _currentUser;
  String? get currentUserName => _currentUser?.name;

  bool register({
    required String name,
    required String email,
    required String password,
  }) {
    final normalizedEmail = email.trim().toLowerCase();
    if (_demoAccounts.containsKey(normalizedEmail) ||
        _accounts.containsKey(normalizedEmail)) {
      return false;
    }
    _accounts[normalizedEmail] = _RegisteredAccount(
      user: StudyUser(
        name: name,
        email: email.trim(),
        className: '',
        major: '',
        birthday: DateTime(2000, 1, 1),
        subjects: const ['UX/UI', 'Java', 'Giải tích', 'Python', 'Pháp luật'],
        avatarAsset: 'assets/images/profile/profile_avatar.png',
      ),
      password: password,
    );
    return true;
  }

  bool login({required String email, required String password}) {
    final normalizedEmail = email.trim().toLowerCase();
    final account =
        _demoAccounts[normalizedEmail] ?? _accounts[normalizedEmail];
    if (account == null || account.password != password) {
      _currentUser = null;
      _currentAccountKey = null;
      return false;
    }
    _currentUser = account.user;
    _currentAccountKey = normalizedEmail;
    return true;
  }

  bool updateCurrentUser(StudyUser user) {
    final normalizedEmail = _currentAccountKey;
    if (normalizedEmail == null) return false;
    final account =
        _demoAccounts[normalizedEmail] ?? _accounts[normalizedEmail];
    if (account == null) return false;

    final updatedAccount = _RegisteredAccount(
      user: user,
      password: account.password,
    );
    if (_demoAccounts.containsKey(normalizedEmail)) {
      _demoAccounts[normalizedEmail] = updatedAccount;
    } else {
      _accounts[normalizedEmail] = updatedAccount;
    }
    _currentUser = user;
    return true;
  }

  void clearSession() {
    _currentUser = null;
    _currentAccountKey = null;
  }
}

class _RegisteredAccount {
  const _RegisteredAccount({required this.user, required this.password});

  final StudyUser user;
  final String password;
}
