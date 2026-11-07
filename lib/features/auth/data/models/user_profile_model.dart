import 'package:flutter_application_1/features/auth/domain/entities/user_profile.dart';

class UserProfileModel {
  const UserProfileModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.className,
    required this.major,
    required this.birthday,
    required this.cohort,
    required this.subjects,
    required this.avatarUrl,
    required this.role,
    required this.isLocked,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      fullName: (json['full_name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      className: (json['class_name'] as String?) ?? '',
      major: (json['major'] as String?) ?? '',
      birthday: DateTime.tryParse(json['birthday'] as String? ?? ''),
      cohort: (json['cohort'] as String?) ?? '',
      subjects: [
        for (final value in (json['subjects'] as List<dynamic>?) ?? const [])
          value.toString(),
      ],
      avatarUrl: json['avatar_url'] as String?,
      role: (json['role'] as String?) ?? 'STUDENT',
      isLocked: (json['is_locked'] as bool?) ?? false,
    );
  }

  final String id;
  final String fullName;
  final String email;
  final String className;
  final String major;
  final DateTime? birthday;
  final String cohort;
  final List<String> subjects;
  final String? avatarUrl;
  final String role;
  final bool isLocked;

  Map<String, dynamic> toJson() => {
    'id': id,
    'full_name': fullName,
    'email': email,
    'class_name': className,
    'major': major,
    'birthday': birthday?.toIso8601String(),
    'cohort': cohort,
    'subjects': subjects,
    'avatar_url': avatarUrl,
    'role': role,
    'is_locked': isLocked,
  };

  UserProfile toEntity() => UserProfile(
    id: id,
    fullName: fullName,
    email: email,
    className: className,
    major: major,
    birthday: birthday,
    cohort: cohort,
    subjects: subjects,
    avatarUrl: avatarUrl,
    role: role,
    isLocked: isLocked,
  );

  factory UserProfileModel.fromEntity(UserProfile profile) => UserProfileModel(
    id: profile.id,
    fullName: profile.fullName,
    email: profile.email,
    className: profile.className,
    major: profile.major,
    birthday: profile.birthday,
    cohort: profile.cohort,
    subjects: profile.subjects,
    avatarUrl: profile.avatarUrl,
    role: profile.role,
    isLocked: profile.isLocked,
  );
}
