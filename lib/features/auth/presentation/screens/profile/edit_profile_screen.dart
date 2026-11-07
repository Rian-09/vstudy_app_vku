import 'package:flutter/material.dart';

import 'package:flutter_application_1/features/auth/data/datasources/auth_service.dart';
import 'package:flutter_application_1/core/theme/auth_theme.dart';
import 'package:flutter_application_1/core/widgets/auth_widgets.dart';
import 'package:flutter_application_1/core/widgets/profile_dialogs.dart';
import 'package:flutter_application_1/features/auth/presentation/widgets/profile_widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final _fallbackUser = StudyUser(
    name: 'Tom',
    email: 'tom@vku.udn.vn',
    className: '23SE4',
    major: 'Công nghệ phần mềm',
    birthday: DateTime(2005, 2, 18),
    subjects: const ['UX/UI', 'Java', 'Giải tích', 'Python', 'Pháp luật'],
    avatarAsset: 'assets/images/profile/profile_avatar.png',
  );

  late final StudyUser _originalUser;
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _classController;
  late final TextEditingController _majorController;
  late final TextEditingController _birthdayController;
  late DateTime _birthday;
  bool _isValidAndChanged = false;

  @override
  void initState() {
    super.initState();
    _originalUser = AuthService.instance.currentUser ?? _fallbackUser;
    _nameController = TextEditingController(text: _originalUser.name);
    _emailController = TextEditingController(text: _originalUser.email);
    _classController = TextEditingController(text: _originalUser.className);
    _majorController = TextEditingController(text: _originalUser.major);
    _birthday = _originalUser.birthday;
    _birthdayController = TextEditingController(text: _formatDate(_birthday));
    for (final controller in [
      _nameController,
      _classController,
      _majorController,
    ]) {
      controller.addListener(_updateValidity);
    }
    _updateValidity();
  }

  bool get _hasChanges =>
      _nameController.text.trim() != _originalUser.name ||
      _classController.text.trim() != _originalUser.className ||
      _majorController.text.trim() != _originalUser.major ||
      _birthday != _originalUser.birthday;

  void _updateValidity() {
    final isValidAndChanged =
        _hasChanges &&
        _nameController.text.trim().isNotEmpty &&
        _emailPattern.hasMatch(_emailController.text.trim()) &&
        _classController.text.trim().isNotEmpty &&
        _majorController.text.trim().isNotEmpty;
    if (isValidAndChanged != _isValidAndChanged && mounted) {
      setState(() => _isValidAndChanged = isValidAndChanged);
    }
  }

  Future<void> _selectBirthday() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _birthday,
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: AuthColors.navy,
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _birthday = selected;
      _birthdayController.text = _formatDate(selected);
    });
    _updateValidity();
  }

  Future<void> _saveChanges() async {
    if (!_isValidAndChanged) return;
    final updatedUser = _originalUser.copyWith(
      name: _nameController.text.trim(),
      className: _classController.text.trim(),
      major: _majorController.text.trim(),
      birthday: _birthday,
    );
    if (!AuthService.instance.updateCurrentUser(updatedUser)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể cập nhật hồ sơ.')),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0x8FFFFFFF),
      builder: (context) => const SuccessPopup(message: 'Cập nhật thành công!'),
    );
    if (mounted) Navigator.of(context).pop();
  }

  static String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';

  @override
  void dispose() {
    for (final controller in [
      _nameController,
      _emailController,
      _classController,
      _majorController,
      _birthdayController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuthBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProfileHeader(
                  user: _originalUser,
                  showIdentity: false,
                  onBack: () => Navigator.of(context).maybePop(),
                  onEdit: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đổi ảnh đại diện sẽ sớm khả dụng.'),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ProfileInputField(
                  label: 'Họ và tên',
                  controller: _nameController,
                ),
                const SizedBox(height: 28),
                ProfileInputField(
                  label: 'Email VKU',
                  controller: _emailController,
                  readOnly: true,
                ),
                const SizedBox(height: 28),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 84,
                      child: ProfileInputField(
                        label: 'Lớp',
                        controller: _classController,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ProfileInputField(
                        label: 'Ngành',
                        controller: _majorController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                ProfileInputField(
                  label: 'Ngày sinh',
                  controller: _birthdayController,
                  readOnly: true,
                  onTap: _selectBirthday,
                ),
                const SizedBox(height: 52),
                Center(
                  child: SizedBox(
                    width: 263,
                    child: PrimaryButton(
                      label: 'Lưu thay đổi',
                      onPressed: _isValidAndChanged ? _saveChanges : null,
                      height: 54,
                      borderRadius: 20,
                      showArrow: false,
                      disabledBackgroundColor: const Color(0xFFA5A7AB),
                      disabledForegroundColor: Colors.white,
                      textStyle: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 20,
                        height: 26 / 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
