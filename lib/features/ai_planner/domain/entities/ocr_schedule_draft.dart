class OcrScheduleDraft {
  const OcrScheduleDraft({
    required this.title,
    required this.subject,
    required this.startsAt,
    required this.endsAt,
    this.location = '',
    this.note = '',
    this.timeDetected = true,
  });

  final String title;
  final String subject;
  final DateTime startsAt;
  final DateTime endsAt;
  final String location;
  final String note;
  final bool timeDetected;
}
