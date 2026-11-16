import 'package:flutter_application_1/features/ai_planner/domain/services/ocr_schedule_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const parser = OcrScheduleParser();

  test('parses Vietnamese timetable line with subject and room', () {
    final drafts = parser.parse(
      '''Môn học: Triết học\n15/10/2026 12:00 - 14:30\nPhòng: A101''',
    );

    expect(drafts, hasLength(1));
    expect(drafts.single.subject, 'Triết học');
    expect(drafts.single.startsAt, DateTime(2026, 10, 15, 12));
    expect(drafts.single.endsAt, DateTime(2026, 10, 15, 14, 30));
    expect(drafts.single.location, 'A101');
  });

  test('handles a two-digit year and overnight end time', () {
    final draft = parser.parse('23/12/26 23:00-01:00').single;

    expect(draft.startsAt, DateTime(2026, 12, 23, 23));
    expect(draft.endsAt, DateTime(2026, 12, 24, 1));
  });

  test(
    'keeps a recognized date when the time is missing for later editing',
    () {
      final draft = parser.parse('Triết học\n15/10/2026').single;

      expect(draft.startsAt, DateTime(2026, 10, 15, 9));
      expect(draft.endsAt, DateTime(2026, 10, 15, 10));
      expect(draft.timeDetected, isFalse);
    },
  );

  test('finds a time range on a neighboring OCR line', () {
    final draft = parser.parse('15/10/2026\n08:30 - 10:00').single;

    expect(draft.startsAt, DateTime(2026, 10, 15, 8, 30));
    expect(draft.endsAt, DateTime(2026, 10, 15, 10));
    expect(draft.timeDetected, isTrue);
  });
}
