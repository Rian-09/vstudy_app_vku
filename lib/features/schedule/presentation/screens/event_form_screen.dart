import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_application_1/features/schedule/data/models/calendar_event.dart';
import 'package:flutter_application_1/core/theme/auth_theme.dart';
import 'package:flutter_application_1/core/widgets/auth_widgets.dart';
import 'package:flutter_application_1/core/widgets/profile_dialogs.dart';
import 'package:flutter_application_1/features/schedule/presentation/providers/schedule_providers.dart';
import 'package:flutter_application_1/features/schedule/presentation/widgets/calendar_widgets.dart';

const _formNavy = Color(0xFF1F2A44);

class EventFormScreen extends ConsumerStatefulWidget {
  const EventFormScreen({super.key, this.event});

  final CalendarEvent? event;

  @override
  ConsumerState<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends ConsumerState<EventFormScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _subjectController;
  late final TextEditingController _locationController;
  late final TextEditingController _noteController;
  late final TextEditingController _dateController;
  late DateTime _date;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late CalendarEventType _type;
  late CalendarEventFormat _format;
  late String _repeat;
  late String _reminder;
  bool _isDirty = false;
  bool _submitting = false;

  bool get _isEditing => widget.event != null;

  bool get _isValid {
    final titleValid = _titleController.text.trim().isNotEmpty;
    final subjectValid =
        _type != CalendarEventType.classSession ||
        _subjectController.text.trim().isNotEmpty;
    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;
    return titleValid && subjectValid && endMinutes > startMinutes;
  }

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    _titleController = TextEditingController(text: event?.title ?? '');
    _subjectController = TextEditingController(text: event?.subject ?? '');
    _locationController = TextEditingController(text: event?.location ?? '');
    _noteController = TextEditingController(text: event?.note ?? '');
    _date = event?.date ?? DateTime(2026, 10, 15);
    _dateController = TextEditingController(text: _dateLabel);
    _startTime = event?.startTime ?? const TimeOfDay(hour: 12, minute: 0);
    _endTime = event?.endTime ?? const TimeOfDay(hour: 20, minute: 0);
    _type = event?.type ?? CalendarEventType.classSession;
    _format = event?.format ?? CalendarEventFormat.inClass;
    _repeat = event?.repeat ?? 'Hằng tuần';
    _reminder = event?.reminder ?? 'Trước 1 tiếng';
    for (final controller in [
      _titleController,
      _subjectController,
      _locationController,
      _noteController,
    ]) {
      controller.addListener(_markDirty);
    }
  }

  void _markDirty() {
    if (!mounted) return;
    setState(() => _isDirty = true);
  }

  void _setType(CalendarEventType type) {
    setState(() {
      _type = type;
      if (type == CalendarEventType.selfStudy) {
        _format = CalendarEventFormat.selfStudy;
      } else if (type == CalendarEventType.free) {
        _format = CalendarEventFormat.free;
      } else if (_format == CalendarEventFormat.free) {
        _format = CalendarEventFormat.inClass;
      }
      _isDirty = true;
    });
  }

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: _formNavy,
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _date = selected;
      _dateController.text = _dateLabel;
      _isDirty = true;
    });
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => ConfirmDialog(
            title: title,
            message: message,
            cancelLabel: 'Hủy',
            confirmLabel: confirmLabel,
            confirmColor: _formNavy,
            onCancel: () => Navigator.of(dialogContext).pop(false),
            onConfirm: () => Navigator.of(dialogContext).pop(true),
          ),
        ) ??
        false;
  }

  Future<void> _save() async {
    if (!_isValid || _submitting) return;
    setState(() => _submitting = true);
    final confirmed = await _confirm(
      title: _isEditing ? 'Xác nhận lưu thay đổi?' : 'Xác nhận thêm lịch?',
      message: _isEditing
          ? 'Bạn có muốn lưu những thay đổi này không?'
          : 'Bạn có muốn thêm lịch trình này không?',
      confirmLabel: _isEditing ? 'Đồng ý' : 'Thêm',
    );
    if (!confirmed || !mounted) {
      if (mounted) setState(() => _submitting = false);
      return;
    }

    final savedEvent = CalendarEvent(
      id: widget.event?.id ?? 'event-${DateTime.now().microsecondsSinceEpoch}',
      title: _titleController.text.trim(),
      subject: _subjectController.text.trim(),
      type: _type,
      format: _format,
      date: _date,
      startTime: _startTime,
      endTime: _endTime,
      location: _locationController.text.trim(),
      note: _noteController.text.trim(),
      repeat: _repeat,
      reminder: _reminder,
      checklist: widget.event?.checklist ?? const [],
    );
    final success = _isEditing
        ? await ref.read(scheduleControllerProvider.notifier).update(savedEvent)
        : await ref.read(scheduleControllerProvider.notifier).add(savedEvent);
    if (!success || !mounted) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể lưu lịch.')),
        );
      }
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SuccessPopup(
        message: _isEditing ? 'Cập nhật thành công!' : 'Thêm lịch thành công!',
        autoCloseDuration: const Duration(milliseconds: 1500),
      ),
    );
    if (mounted) Navigator.of(context).pop(true);
  }

  Future<void> _attemptClose() async {
    if (!_isDirty) {
      Navigator.of(context).pop();
      return;
    }
    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => ConfirmDialog(
        title: 'Hủy thay đổi?',
        message: 'Các thay đổi chưa lưu sẽ bị hủy.',
        cancelLabel: 'Tiếp tục',
        confirmLabel: 'Hủy thay đổi',
        confirmColor: _formNavy,
        onCancel: () => Navigator.of(dialogContext).pop(false),
        onConfirm: () => Navigator.of(dialogContext).pop(true),
      ),
    );
    if (shouldDiscard == true && mounted) Navigator.of(context).pop();
  }

  String get _dateLabel =>
      '${_date.day.toString().padLeft(2, '0')}/'
      '${_date.month.toString().padLeft(2, '0')}/${_date.year}';

  @override
  void dispose() {
    for (final controller in [
      _titleController,
      _subjectController,
      _locationController,
      _noteController,
      _dateController,
    ]) {
      controller
        ..removeListener(_markDirty)
        ..dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _attemptClose();
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AuthBackground(
          child: SafeArea(
            child: Column(
              children: [
                _FormHeader(
                  title: _isEditing
                      ? 'Chỉnh sửa môn học'
                      : 'Thêm lịch trình mới',
                  onClose: _attemptClose,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(26, 13, 26, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _FieldLabel('Tên buổi học/ Deadline'),
                        AppTextField(
                          controller: _titleController,
                          label: '',
                          hint: 'Nhập tên môn học hoặc deadline',
                          fieldHeight: 43,
                          labelGap: 0,
                          fieldStyle: _CalendarFieldStyles.value,
                          onChanged: (_) => setState(() {}),
                        ),
                        if (_type == CalendarEventType.classSession) ...[
                          const SizedBox(height: 12),
                          _FieldLabel('Môn học'),
                          AppTextField(
                            controller: _subjectController,
                            label: '',
                            hint: 'Nhập tên môn học',
                            fieldHeight: 43,
                            labelGap: 0,
                            fieldStyle: _CalendarFieldStyles.value,
                            onChanged: (_) => setState(() {}),
                          ),
                        ],
                        const SizedBox(height: 17),
                        const _FieldLabel('Phân loại'),
                        EventTypeChips(selected: _type, onSelected: _setType),
                        const SizedBox(height: 16),
                        const _FieldLabel('Hình thức'),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            _FormatChip(
                              label: 'Trên lớp',
                              selected: _format == CalendarEventFormat.inClass,
                              onTap: () => setState(() {
                                _format = CalendarEventFormat.inClass;
                                _isDirty = true;
                              }),
                            ),
                            _FormatChip(
                              label: 'Tự học',
                              selected:
                                  _format == CalendarEventFormat.selfStudy,
                              onTap: () => setState(() {
                                _format = CalendarEventFormat.selfStudy;
                                if (_type == CalendarEventType.classSession) {
                                  _type = CalendarEventType.selfStudy;
                                }
                                _isDirty = true;
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 17),
                        const _FieldLabel('Ngày'),
                        AppTextField(
                          controller: _dateController,
                          label: '',
                          hint: 'Chọn ngày mà bạn sẽ thêm vào lịch',
                          readOnly: true,
                          onTap: _selectDate,
                          fieldHeight: 43,
                          labelGap: 0,
                          fieldStyle: _CalendarFieldStyles.value,
                          trailing: Padding(
                            padding: const EdgeInsets.all(9),
                            child: SvgPicture.asset(
                              'assets/images/calendar/date_picker.svg',
                              width: 23,
                              height: 23,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const _FieldLabel('Thời gian'),
                        TimeRangePicker(
                          start: _startTime,
                          end: _endTime,
                          onStartChanged: (time) => setState(() {
                            _startTime = time;
                            _isDirty = true;
                          }),
                          onEndChanged: (time) => setState(() {
                            _endTime = time;
                            _isDirty = true;
                          }),
                        ),
                        const SizedBox(height: 18),
                        const _FieldLabel('Địa điểm'),
                        AppTextField(
                          controller: _locationController,
                          label: '',
                          hint: 'Ví dụ: Phòng K.P206',
                          fieldHeight: 43,
                          labelGap: 0,
                          fieldStyle: _CalendarFieldStyles.value,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 18),
                        const _FieldLabel('Thêm ghi chú'),
                        AppTextField(
                          controller: _noteController,
                          label: '',
                          hint: 'Thêm chú thích mà cần lưu ý',
                          fieldHeight: 43,
                          labelGap: 0,
                          fieldStyle: _CalendarFieldStyles.value,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 22),
                        _RepeatReminderPanel(
                          repeat: _repeat,
                          reminder: _reminder,
                          onRepeatChanged: (value) => setState(() {
                            _repeat = value;
                            _isDirty = true;
                          }),
                          onReminderChanged: (value) => setState(() {
                            _reminder = value;
                            _isDirty = true;
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Bấm nút để xác nhận ${_isEditing ? 'cập nhật' : 'thêm'} lịch trình',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 9,
                            color: _formNavy,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 102,
                        child: PrimaryButton(
                          label: 'Hủy',
                          height: 37,
                          borderRadius: 15,
                          showArrow: false,
                          enabledBackgroundColor: const Color(0xFFD9D9D9),
                          enabledForegroundColor: _formNavy,
                          textStyle: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                          onPressed: _attemptClose,
                        ),
                      ),
                      const SizedBox(width: 14),
                      SizedBox(
                        width: 115,
                        child: PrimaryButton(
                          label: 'Xác nhận',
                          height: 37,
                          borderRadius: 15,
                          showArrow: false,
                          enabledBackgroundColor: _formNavy,
                          disabledBackgroundColor: const Color(0xFFB8BBC4),
                          enabledForegroundColor: Colors.white,
                          disabledForegroundColor: Colors.white,
                          textStyle: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                          onPressed: _isValid && !_submitting ? _save : null,
                        ),
                      ),
                    ],
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

class _FormHeader extends StatelessWidget {
  const _FormHeader({required this.title, required this.onClose});

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 53,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: onClose,
              tooltip: 'Đóng',
              icon: SvgPicture.asset(
                'assets/images/calendar/close.svg',
                width: 20,
                height: 20,
              ),
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _formNavy,
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          color: _formNavy,
        ),
      ),
    );
  }
}

class _FormatChip extends StatelessWidget {
  const _FormatChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? _formNavy : const Color(0xFFD9D9D9),
      borderRadius: BorderRadius.circular(15),
      elevation: selected ? 0 : 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: SizedBox(
          width: 115,
          height: 37,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : _formNavy,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RepeatReminderPanel extends StatelessWidget {
  const _RepeatReminderPanel({
    required this.repeat,
    required this.reminder,
    required this.onRepeatChanged,
    required this.onReminderChanged,
  });

  final String repeat;
  final String reminder;
  final ValueChanged<String> onRepeatChanged;
  final ValueChanged<String> onReminderChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          _DropdownRow(
            label: 'Lặp lại',
            value: repeat,
            options: const ['Không lặp lại', 'Hằng tuần', 'Hằng tháng'],
            onChanged: onRepeatChanged,
          ),
          const Divider(height: 1, color: Color(0xFFB7B7B7)),
          _DropdownRow(
            label: 'Nhắc trước',
            value: reminder,
            options: const [
              'Không nhắc trước',
              'Trước 10 phút',
              'Trước 1 tiếng',
              'Trước 1 ngày',
            ],
            onChanged: onReminderChanged,
          ),
        ],
      ),
    );
  }
}

class _DropdownRow extends StatelessWidget {
  const _DropdownRow({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: _formNavy,
                ),
              ),
            ),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isDense: true,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: _formNavy,
                ),
                items: [
                  for (final option in options)
                    DropdownMenuItem(value: option, child: Text(option)),
                ],
                onChanged: (value) {
                  if (value != null) onChanged(value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

abstract final class _CalendarFieldStyles {
  static const value = TextStyle(
    fontFamily: 'Inter',
    fontSize: 11,
    height: 14 / 11,
    color: AuthColors.navy,
  );
}
