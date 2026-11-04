import 'package:flutter/material.dart';

import '../../theme/auth_theme.dart';

class SubmitConfirmDialog extends StatelessWidget {
  const SubmitConfirmDialog({
    super.key,
    required this.subjectName,
    required this.answeredCount,
    required this.unansweredCount,
    required this.remainingTime,
  });

  final String subjectName;
  final int answeredCount;
  final int unansweredCount;
  final String remainingTime;

  static Future<bool?> show(
    BuildContext context, {
    required String subjectName,
    required int answeredCount,
    required int unansweredCount,
    required String remainingTime,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SubmitConfirmDialog(
        subjectName: subjectName,
        answeredCount: answeredCount,
        unansweredCount: unansweredCount,
        remainingTime: remainingTime,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      backgroundColor: Colors.transparent,
      child: Container(
        width: 360,
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                color: AuthColors.navy,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: AuthColors.navyTint, spreadRadius: 7),
                ],
              ),
              child: const Icon(
                Icons.assignment_turned_in_outlined,
                color: Color(0xFFFFDF62),
                size: 38,
              ),
            ),
            const SizedBox(height: 17),
            const Text(
              'Xác nhận nộp bài?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 22,
                height: 28 / 22,
                fontWeight: FontWeight.w700,
                color: AuthColors.navy,
              ),
            ),
            const SizedBox(height: 10),
            Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  height: 19 / 13,
                  color: AuthColors.text,
                ),
                children: [
                  const TextSpan(
                    text: 'Bạn có chắc muốn kết thúc bài thi học phần ',
                  ),
                  TextSpan(
                    text: subjectName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const TextSpan(text: ' không?'),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _SubmitCountCard(
                    value: '$unansweredCount',
                    label: 'Chưa làm',
                    color: const Color(0xFFC32323),
                    background: const Color(0xFFFFE0E0),
                    icon: Icons.cancel_outlined,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SubmitCountCard(
                    value: '$answeredCount',
                    label: 'Đã làm',
                    color: const Color(0xFFFFA806),
                    background: const Color(0xFFFFE9C1),
                    icon: Icons.flag_outlined,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SubmitCountCard(
                    value: remainingTime,
                    label: 'Còn lại',
                    color: const Color(0xFF185C3D),
                    background: const Color(0xFFD0F5E4),
                    icon: Icons.timer_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFD7E1FB),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: AuthColors.navy, size: 20),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Sau khi nộp, hệ thống sẽ chốt điểm tự động và bạn sẽ không thể điều chỉnh lại bất kỳ câu trả lời nào.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        height: 16 / 11,
                        color: AuthColors.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: AuthColors.navy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('Nộp bài ngay'),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Tiếp tục làm'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmitCountCard extends StatelessWidget {
  const _SubmitCountCard({
    required this.value,
    required this.label,
    required this.color,
    required this.background,
    required this.icon,
  });

  final String value;
  final String label;
  final Color color;
  final Color background;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              height: 18 / 15,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Icon(icon, size: 14, color: color),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              height: 14 / 10,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
