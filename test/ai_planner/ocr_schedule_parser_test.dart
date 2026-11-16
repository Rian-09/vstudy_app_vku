import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/features/ai_planner/domain/services/ocr_schedule_parser.dart';

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

  test('ignores lines without both date and time range', () {
    expect(parser.parse('Triết học\n15/10/2026').isEmpty, isTrue);
  });
}
