import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../models/calendar_event.dart';
import '../../services/calendar_service.dart';
import '../../theme/auth_theme.dart';
import '../../widgets/auth_widgets.dart';
import '../../widgets/profile_dialogs.dart';

const _detailNavy = Color(0xFF1F2A44);
const _detailGold = Color(0xFFC9A227);

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({super.key, required this.eventId});

  final String eventId;

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late List<bool> _checkedItems;
  late CalendarEvent _lastKnownEvent;

  CalendarEvent get _event =>
      CalendarService.instance.eventById(widget.eventId) ?? _lastKnownEvent;

  @override
  void initState() {
    super.initState();
    _lastKnownEvent =
        CalendarService.instance.eventById(widget.eventId) ??
        CalendarService.instance.events.first;
    _checkedItems = List<bool>.filled(_lastKnownEvent.checklist.length, true);
  }

  Future<void> _edit() async {
    await Navigator.of(context)
        .pushNamed('/calendar/event-form', arguments: _event);
    if (mounted) {
      setState(() {
        _lastKnownEvent =
            CalendarService.instance.eventById(widget.eventId) ??
            _lastKnownEvent;
      });
    }
  }

  Future<void> _delete() async {
    final event = _event;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => ConfirmDialog(
        title: 'Xác nhận xóa?',
        message: 'Bạn có chắc muốn xóa lịch này chứ?',
        cancelLabel: 'Hủy',
        confirmLabel: 'Xóa',
        onCancel: () => Navigator.of(dialogContext).pop(false),
        onConfirm: () => Navigator.of(dialogContext).pop(true),
      ),
    );
    if (shouldDelete != true || !mounted) return;

    CalendarService.instance.deleteEvent(event.id);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const SuccessPopup(
        message: 'Đã xóa lịch!',
        autoCloseDuration: Duration(milliseconds: 1500),
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CalendarService.instance,
      builder: (context, child) {
        final event = _event;
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: AuthBackground(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DetailHeader(
                      onBack: () => Navigator.of(context).maybePop(),
                      onEdit: _edit,
                    ),
                    const SizedBox(height: 17),
                    _EventSummaryCard(event: event),
                    const SizedBox(height: 40),
                    _RepeatReminderDetail(event: event),
                    const SizedBox(height: 34),
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/calendar/checklist_checked.svg',
                          width: 25,
                          height: 25,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Việc cần chuẩn bị',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 19,
                            height: 24 / 19,
                            fontWeight: FontWeight.w700,
                            color: _detailNavy,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (event.checklist.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(left: 30, top: 8),
                        child: Text(
                          'Chưa có việc cần chuẩn bị',
                          style: AuthTextStyles.caption,
                        ),
                      )
                    else
                      for (
                        var index = 0;
                        index < event.checklist.length;
                        index++
                      )
                        _ChecklistItem(
                          label: event.checklist[index],
                          checked: _checkedItems[index],
                          onChanged: (value) =>
                              setState(() => _checkedItems[index] = value),
                        ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton(
                        onPressed: _delete,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _detailNavy,
                          backgroundColor: const Color(0xFFD9D9D9),
                          side: const BorderSide(color: _detailNavy),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 3,
                          textStyle: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('Xóa buổi học'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.onBack, required this.onEdit});

  final VoidCallback onBack;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: onBack,
              tooltip: 'Quay lại lịch',
              icon: const Icon(Icons.arrow_back_ios_new, color: _detailGold),
            ),
          ),
          const Text(
            'Chi tiết buổi học',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 19,
              height: 24 / 19,
              fontWeight: FontWeight.w700,
              color: _detailNavy,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onEdit,
              style: TextButton.styleFrom(
                foregroundColor: _detailNavy,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              child: const Text('Sửa'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventSummaryCard extends StatelessWidget {
  const _EventSummaryCard({required this.event});

  final CalendarEvent event;

  @override
  Widget build(BuildContext context) {
    final duration = event.duration.inMinutes.clamp(1, 24 * 60);
    return Container(
      height: 190,
      padding: const EdgeInsets.fromLTRB(25, 16, 20, 20),
      decoration: BoxDecoration(
        color: _detailNavy,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _detailGold,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    event.format.label,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _detailNavy,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                event.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 20,
                  height: 26 / 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${_weekday(event.date.weekday)}, ${event.date.day}/${event.date.month}/${event.date.year}',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${event.startTime.format(context)} - ${event.endTime.format(context)}'
                '${event.location.isEmpty ? '' : ' - ${event.location}'}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: (duration / 180).clamp(0, 1).toDouble(),
                  minHeight: 9,
                  color: _detailGold,
                  backgroundColor: const Color(0x336B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RepeatReminderDetail extends StatelessWidget {
  const _RepeatReminderDetail({required this.event});

  final CalendarEvent event;

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
          _InfoRow(label: 'Lặp lại', value: event.repeat),
          SvgPicture.asset(
            'assets/images/calendar/detail_divider.svg',
            width: 316,
            height: 1,
          ),
          _InfoRow(label: 'Nhắc trước', value: event.reminder),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: _detailNavy,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: _detailNavy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({
    required this.label,
    required this.checked,
    required this.onChanged,
  });

  final String label;
  final bool checked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!checked),
      child: SizedBox(
        height: 32,
        child: Row(
          children: [
            SvgPicture.asset(
              checked
                  ? 'assets/images/calendar/checklist_checked.svg'
                  : 'assets/images/calendar/checklist_empty.svg',
              width: 22,
              height: 22,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: _detailNavy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _weekday(int weekday) => switch (weekday) {
  1 => 'Thứ hai',
  2 => 'Thứ ba',
  3 => 'Thứ tư',
  4 => 'Thứ năm',
  5 => 'Thứ sáu',
  6 => 'Thứ bảy',
  _ => 'Chủ nhật',
};
