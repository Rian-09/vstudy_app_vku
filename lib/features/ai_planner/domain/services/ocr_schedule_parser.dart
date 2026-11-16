import '../entities/ocr_schedule_draft.dart';

/// Parses common timetable OCR lines into drafts for user confirmation.
/// It deliberately does not save anything: the confirmation screen decides
/// whether a draft becomes a schedule event.
class OcrScheduleParser {
  const OcrScheduleParser();

  static final _datePattern = RegExp(
    r'(?<!\d)(\d{1,2})\s*[/-]\s*(\d{1,2})(?:\s*[/-]\s*(\d{2,4}))?(?!\d)',
  );
  static final _timePattern = RegExp(
    r'(?<!\d)([01]?\d|2[0-3])\s*[:.]\s*([0-5]\d)\s*[-–—]\s*'
    r'([01]?\d|2[0-3])\s*[:.]\s*([0-5]\d)(?!\d)',
  );
  static final _subjectPattern = RegExp(
    r'(?:môn(?: học)?|subject)\s*[:：-]\s*(.+)',
    caseSensitive: false,
  );
  static final _locationPattern = RegExp(
    r'(?:phòng|room|địa điểm)\s*[:：-]\s*(.+)',
    caseSensitive: false,
  );

  List<OcrScheduleDraft> parse(String text, {int? defaultYear}) {
    final lines = text
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);
    final drafts = <OcrScheduleDraft>[];
    for (var index = 0; index < lines.length; index++) {
      final date = _datePattern.firstMatch(lines[index]);
      final sameLineTime = _timePattern.firstMatch(lines[index]);
      if (date == null ||
          (sameLineTime != null && date.start > sameLineTime.start)) {
        continue;
      }
      final time = _findMatch(lines, _timePattern, index);

      final yearValue = int.tryParse(date.group(3) ?? '');
      final now = DateTime.now();
      var year = yearValue == null
          ? (defaultYear ?? now.year)
          : yearValue < 100
          ? 2000 + yearValue
          : yearValue;
      final month = int.parse(date.group(2)!);
      final day = int.parse(date.group(1)!);
      if (yearValue == null &&
          DateTime(
            year,
            month,
            day,
          ).isBefore(DateTime(now.year, now.month, now.day))) {
        year++;
      }
      final startHour = int.parse(time?.group(1) ?? '9');
      final startMinute = int.parse(time?.group(2) ?? '0');
      final endHour = int.parse(time?.group(3) ?? '10');
      final endMinute = int.parse(time?.group(4) ?? '0');
      final startsAt = DateTime(year, month, day, startHour, startMinute);
      var endsAt = DateTime(year, month, day, endHour, endMinute);
      if (!endsAt.isAfter(startsAt)) {
        endsAt = endsAt.add(const Duration(days: 1));
      }

      final subject =
          _findValue(lines, _subjectPattern, index) ?? 'Chưa xác định';
      final location = _findValue(lines, _locationPattern, index) ?? '';
      final title = subject == 'Chưa xác định'
          ? 'Lịch học ${_formatDate(startsAt)}'
          : subject;
      drafts.add(
        OcrScheduleDraft(
          title: title,
          subject: subject,
          startsAt: startsAt,
          endsAt: endsAt,
          location: location,
          note: time == null
              ? '${lines[index]} (OCR chưa nhận diện giờ; vui lòng chọn giờ trong biểu mẫu.)'
              : lines[index],
          timeDetected: time != null,
        ),
      );
    }
    return drafts;
  }

  RegExpMatch? _findMatch(
    List<String> lines,
    RegExp pattern,
    int currentIndex,
  ) {
    for (final index in [currentIndex, currentIndex - 1, currentIndex + 1]) {
      if (index < 0 || index >= lines.length) continue;
      final match = pattern.firstMatch(lines[index]);
      if (match != null) return match;
    }
    return null;
  }

  String? _findValue(List<String> lines, RegExp pattern, int currentIndex) {
    for (final index in [currentIndex, currentIndex - 1, currentIndex + 1]) {
      if (index < 0 || index >= lines.length) continue;
      final match = pattern.firstMatch(lines[index]);
      final value = match?.group(1)?.trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}
