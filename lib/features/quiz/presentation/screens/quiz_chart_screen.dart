import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:flutter_application_1/features/quiz/data/models/quiz_models.dart';
import 'package:flutter_application_1/features/quiz/data/datasources/quiz_service.dart';
import 'package:flutter_application_1/core/theme/auth_theme.dart';
import 'package:flutter_application_1/core/widgets/auth_widgets.dart';

class QuizChartScreen extends StatelessWidget {
  const QuizChartScreen({super.key, required this.result});

  final QuizResult result;

  @override
  Widget build(BuildContext context) {
    final exam = QuizService.instance.examById(result.examId);
    final entries = result.topicTotalCounts.entries.toList();
    final percent = result.score.round();
    return AuthBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  ),
                  const Expanded(
                    child: Text(
                      'Biểu đồ phân tích',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AuthColors.navy,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AuthColors.navy,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    const Text(
                      'KẾT QUẢ BÀI LÀM',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: Color(0xFFFFDF62),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 170,
                      child: CustomPaint(
                        painter: _GaugePainter(percent / 100),
                        child: Center(
                          child: Text(
                            '$percent%',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: thirtyTwo,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      exam?.chapterTitle ?? 'Phân tích theo chủ đề',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Kết quả theo chủ đề',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AuthColors.navy,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 220,
                      child: CustomPaint(
                        painter: _TopicChartPainter(
                          entries
                              .map(
                                (entry) => _TopicValue(
                                  entry.key,
                                  result.topicCorrectCounts[entry.key] ?? 0,
                                  entry.value,
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const thirtyTwo = 32.0;

class _GaugePainter extends CustomPainter {
  const _GaugePainter(this.value);
  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 12;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..color = const Color(0xFF3C4A70);
    final progress = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 14
      ..color = const Color(0xFFFFDF62);
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2, false, base);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * value.clamp(0, 1),
      false,
      progress,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.value != value;
}

class _TopicValue {
  const _TopicValue(this.label, this.correct, this.total);
  final String label;
  final int correct;
  final int total;
}

class _TopicChartPainter extends CustomPainter {
  const _TopicChartPainter(this.values);
  final List<_TopicValue> values;

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = values.isEmpty
        ? size.width
        : (size.width / values.length * .55).toDouble();
    final gap = values.isEmpty ? 0.0 : (size.width / values.length).toDouble();
    final maxHeight = size.height - 42;
    final grid = Paint()
      ..color = const Color(0xFFE8ECF4)
      ..strokeWidth = 1;
    for (var line = 0; line < 5; line++) {
      final y = maxHeight - line * maxHeight / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    for (var index = 0; index < values.length; index++) {
      final item = values[index];
      final ratio = item.total == 0 ? 0.0 : item.correct / item.total;
      final x = gap * index + (gap - barWidth) / 2;
      final bar = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x,
          maxHeight - maxHeight * ratio,
          barWidth,
          maxHeight * ratio,
        ),
        const Radius.circular(8),
      );
      canvas.drawRRect(
        bar,
        Paint()
          ..color = index.isEven
              ? const Color(0xFF3B2E9E)
              : const Color(0xFFDFA841),
      );
      final painter =
          TextPainter(
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
            )
            ..text = TextSpan(
              text: '${(ratio * 100).round()}%',
              style: const TextStyle(
                fontSize: 10,
                color: AuthColors.text,
                fontWeight: FontWeight.w700,
              ),
            )
            ..layout(maxWidth: gap);
      painter.paint(
        canvas,
        Offset(
          x + barWidth / 2 - painter.width / 2,
          maxHeight - maxHeight * ratio - 18,
        ),
      );
      final label =
          TextPainter(
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
            )
            ..text = TextSpan(
              text: item.label,
              style: const TextStyle(fontSize: 9, color: AuthColors.muted),
            )
            ..layout(maxWidth: gap);
      label.paint(
        canvas,
        Offset(x + barWidth / 2 - label.width / 2, maxHeight + 10),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TopicChartPainter oldDelegate) =>
      oldDelegate.values != values;
}
