import 'package:flutter/material.dart';

class QuickAccessItem {
  const QuickAccessItem({
    required this.category,
    required this.title,
    required this.detail,
    required this.categoryColor,
    required this.categoryTextColor,
    required this.progressColor,
    required this.progress,
    this.illustrationAsset,
  });

  final String category;
  final String title;
  final String detail;
  final Color categoryColor;
  final Color categoryTextColor;
  final Color progressColor;
  final double progress;
  final String? illustrationAsset;
}

class DeadlineItem {
  const DeadlineItem({
    required this.title,
    required this.schedule,
    required this.tag,
    required this.remaining,
    required this.color,
    required this.tagColor,
    required this.remainingColor,
  });

  final String title;
  final String schedule;
  final String tag;
  final String remaining;
  final Color color;
  final Color tagColor;
  final Color remainingColor;
}

const mockQuickAccessItems = <QuickAccessItem>[
  QuickAccessItem(
    category: 'Quiz',
    title: 'Triết học Mác-Lênin',
    detail: 'Chương 2 - Câu 3/10',
    categoryColor: Color(0xFFFFE062),
    categoryTextColor: Color(0xFF340D6E),
    progressColor: Color(0xFFF4D87F),
    progress: 0.30,
    illustrationAsset: 'assets/images/home/quick_quiz_illustration.png',
  ),
  QuickAccessItem(
    category: 'Tài liệu',
    title: 'Phân tích thiết kế và giải thuật',
    detail: 'Chương 5 - Slide 53/68',
    categoryColor: Color(0xFF8CA5E2),
    categoryTextColor: Color(0xFF0D0223),
    progressColor: Color(0xFF9EB3E6),
    progress: 0.78,
    illustrationAsset: 'assets/images/home/quick_document_illustration.png',
  ),
  QuickAccessItem(
    category: 'AI chat',
    title: 'Gợi ý ôn tập thống kê',
    detail: 'Học theo từng dạng bài cùng AI',
    categoryColor: Color(0xFFFFC6C6),
    categoryTextColor: Color(0xFF672A2A),
    progressColor: Color(0xFFE7A3A3),
    progress: 0.46,
  ),
];

const mockWeeklyStudyHours = <double>[3.8, 1.7, 2.5, 1.2, 3.1, 3.7, 4.5];

const mockDeadlines = <DeadlineItem>[
  DeadlineItem(
    title: 'Nộp bài UX/UI',
    schedule: 'Ngày mai 19:00 - 21:00',
    tag: 'Deadline',
    remaining: 'Còn 28h',
    color: Color(0xFFFB2323),
    tagColor: Color(0xFF880E0E),
    remainingColor: Color(0xFFCF0909),
  ),
  DeadlineItem(
    title: 'Đại số tuyến tính',
    schedule: 'Ngày mai 7:30 - 9:20',
    tag: 'Lịch học',
    remaining: 'Còn 14h',
    color: Color(0xFF1F2A44),
    tagColor: Color(0xFF731647),
    remainingColor: Color(0xB31F2A44),
  ),
];
