class UserProfile {
  const UserProfile({
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

  UserProfile copyWith({
    String? fullName,
    String? className,
    String? major,
    DateTime? birthday,
    String? cohort,
    List<String>? subjects,
    String? avatarUrl,
    String? role,
    bool? isLocked,
  }) {
    return UserProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email,
      className: className ?? this.className,
      major: major ?? this.major,
      birthday: birthday ?? this.birthday,
      cohort: cohort ?? this.cohort,
      subjects: subjects ?? this.subjects,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}
