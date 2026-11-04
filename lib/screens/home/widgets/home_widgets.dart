import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../theme/auth_theme.dart';
import 'home_data.dart';

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({
    super.key,
    required this.userName,
    required this.avatarAsset,
    required this.onAvatarTap,
  });

  final String userName;
  final String avatarAsset;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Buổi sáng tốt lành!',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  height: 16 / 12,
                  color: Color(0x80000000),
                ),
              ),
              Text(
                'Xin chào, $userName!',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 20,
                  height: 26 / 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF213A65),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onAvatarTap,
            customBorder: const CircleBorder(),
            child: ClipOval(
              child: Image.asset(
                avatarAsset,
                width: 46,
                height: 46,
                fit: BoxFit.cover,
                semanticLabel: 'Mở hồ sơ',
                errorBuilder: (context, error, stackTrace) => const ColoredBox(
                  color: Color(0xFFDDE2EE),
                  child: Icon(Icons.person_outline, color: AuthColors.navy),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class StudyProgressCard extends StatelessWidget {
  const StudyProgressCard({super.key, required this.onQuizTap});

  final VoidCallback onQuizTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 310),
        child: SizedBox(
          height: 165,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 9,
                top: 28,
                width: 275,
                height: 137,
                child: Transform.rotate(
                  angle: -0.087,
                  child: SvgPicture.asset(
                    'assets/images/home/progress_backing.svg',
                    width: 275,
                    height: 137,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 165,
                padding: const EdgeInsets.fromLTRB(22, 18, 12, 12),
                decoration: BoxDecoration(
                  color: AuthColors.navy,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    const Positioned(
                      left: 0,
                      top: 0,
                      child: Text(
                        'Mục tiêu hôm nay',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          height: 16 / 12,
                          color: Color(0xCCFFFFFF),
                        ),
                      ),
                    ),
                    const Positioned(
                      left: 0,
                      top: 22,
                      child: Text(
                        '100/180 phút',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 20,
                          height: 26 / 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Positioned(
                      left: 0,
                      top: 55,
                      width: 164,
                      child: Text(
                        'Cố lên còn 80 phút nữa là hoàn thành!!',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          height: 13 / 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFFE062),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      bottom: 0,
                      child: SizedBox(
                        width: 128,
                        height: 27,
                        child: FilledButton(
                          onPressed: onQuizTap,
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.zero,
                            shape: const StadiumBorder(),
                            textStyle: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: const Text('Làm Quiz ngay hôm nay'),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      width: 88,
                      height: 88,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/images/home/chart_bars.svg',
                            width: 88,
                            height: 88,
                          ),
                          const Text(
                            '55,57%',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              height: 18 / 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
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

class QuickAccessList extends StatelessWidget {
  const QuickAccessList({super.key, required this.onItemTap});

  final ValueChanged<QuickAccessItem> onItemTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 14),
          child: Text('Truy cập nhanh', style: _SectionTitle.style),
        ),
        SizedBox(
          height: 143,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            itemCount: mockQuickAccessItems.length,
            separatorBuilder: (context, index) => const SizedBox(width: 25),
            itemBuilder: (context, index) {
              final item = mockQuickAccessItems[index];
              return QuickAccessCard(item: item, onTap: () => onItemTap(item));
            },
          ),
        ),
      ],
    );
  }
}

class QuickAccessCard extends StatelessWidget {
  const QuickAccessCard({super.key, required this.item, required this.onTap});

  final QuickAccessItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 242,
          height: 137,
          child: Stack(
            children: [
              Positioned(
                left: 12,
                top: 12,
                child: Container(
                  width: item.category == 'Tài liệu' ? 66 : 52,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: item.categoryColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.white, blurRadius: 16),
                    ],
                  ),
                  child: Text(
                    item.category,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      height: 16 / 12,
                      fontWeight: FontWeight.w700,
                      color: item.categoryTextColor,
                    ),
                  ),
                ),
              ),
              if (item.illustrationAsset case final String asset)
                Positioned(
                  right: 15,
                  top: 25,
                  width: 69,
                  height: 71,
                  child: Image.asset(asset, fit: BoxFit.contain),
                )
              else
                Positioned(
                  right: 16,
                  top: 18,
                  child: Container(
                    width: 38,
                    height: 33,
                    decoration: BoxDecoration(
                      color: AuthColors.navy,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/images/home/arrow_down.svg',
                        width: 13,
                        height: 13,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: 16,
                top: 72,
                right: 12,
                child: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    height: 17 / 13,
                    fontWeight: FontWeight.w700,
                    color: AuthColors.navy,
                  ),
                ),
              ),
              Positioned(
                left: 17,
                top: 96,
                right: 12,
                child: Text(
                  item.detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    height: 14 / 11,
                    fontWeight: FontWeight.w300,
                    color: AuthColors.navy,
                  ),
                ),
              ),
              Positioned(
                left: 17,
                bottom: 8,
                width: 204,
                height: 8,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: item.progress,
                    backgroundColor: const Color(0xFFEDE9DD),
                    color: item.progressColor,
                    minHeight: 8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AiSuggestionBanner extends StatelessWidget {
  const AiSuggestionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 343),
        child: Container(
          height: 76,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF6EBC4),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x85DFA841),
                offset: Offset(0, 4),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/images/home/ai_icon.svg',
                width: 50,
                height: 50,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gợi ý từ V-Study AI',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        height: 19 / 15,
                        fontWeight: FontWeight.w700,
                        color: AuthColors.navy,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Dành 45 phút ôn tập Giải tích trước 20:00, sau đó học trước lí thuyết mới',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        height: 14 / 11,
                        color: Color(0xCC1F2A44),
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

class WeeklyChart extends StatelessWidget {
  const WeeklyChart({super.key, required this.onDetailsTap});

  final VoidCallback onDetailsTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Text('Tuần này', style: _SectionTitle.style)),
            TextButton(
              onPressed: onDetailsTap,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFD64545),
                textStyle: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  height: 15 / 11,
                  fontWeight: FontWeight.w500,
                ),
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Chi tiết'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 358),
            child: Container(
              height: 222,
              padding: const EdgeInsets.fromLTRB(11, 12, 11, 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Color(0xFFFAF1E3)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x30D8D7D5),
                    offset: Offset(0, 4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Column(
                    children: [
                      const Expanded(
                        child: CustomPaint(
                          painter: WeeklyChartPainter(mockWeeklyStudyHours),
                          child: SizedBox.expand(),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _WeekdayLabel('T2'),
                          _WeekdayLabel('T3'),
                          _WeekdayLabel('T4'),
                          _WeekdayLabel('T5', selected: true),
                          _WeekdayLabel('T6'),
                          _WeekdayLabel('T7'),
                          _WeekdayLabel('CN'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class WeeklyChartPainter extends CustomPainter {
  const WeeklyChartPainter(this.values);

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    const leftInset = 28.0;
    const topInset = 10.0;
    const bottomInset = 7.0;
    final plotHeight = size.height - topInset - bottomInset;
    final plotWidth = size.width - leftInset - 4;
    final gridPaint = Paint()
      ..color = const Color(0xFFC0C4E0)
      ..strokeWidth = 1;

    for (var row = 0; row < 4; row++) {
      final y = topInset + plotHeight * row / 3;
      for (var x = leftInset; x < size.width; x += 7) {
        canvas.drawLine(
          Offset(x, y),
          Offset(math.min(x + 3, size.width), y),
          gridPaint,
        );
      }
      final label = TextPainter(
        text: TextSpan(
          text: const ['4+', '4', '2', '0'][row],
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            height: 13 / 10,
            fontWeight: FontWeight.w700,
            color: Color(0x8CC9A227),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      label.paint(canvas, Offset(0, y - label.height / 2));
    }

    final barWidth = math.min(14.0, plotWidth / values.length * 0.34);
    final slotWidth = plotWidth / values.length;
    final barPaint = Paint()..style = PaintingStyle.fill;
    for (var index = 0; index < values.length; index++) {
      final barHeight = plotHeight * values[index] / 5;
      final x = leftInset + slotWidth * index + (slotWidth - barWidth) / 2;
      final y = topInset + plotHeight - barHeight;
      barPaint.color = index == 3
          ? const Color(0xFFC9A227)
          : const Color(0xFFF6EBC4);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(5),
        ),
        barPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant WeeklyChartPainter oldDelegate) =>
      oldDelegate.values != values;
}

class UpcomingDeadlines extends StatelessWidget {
  const UpcomingDeadlines({super.key, required this.onSeeAllTap});

  final VoidCallback onSeeAllTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Text('Sắp đến', style: _SectionTitle.style)),
            TextButton(
              onPressed: onSeeAllTap,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFE76D6D),
                textStyle: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  height: 15 / 11,
                  fontWeight: FontWeight.w500,
                ),
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Xem thêm'),
            ),
          ],
        ),
        const SizedBox(height: 21),
        for (var index = 0; index < mockDeadlines.length; index++) ...[
          if (index > 0) const SizedBox(height: 22),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 350),
              child: DeadlineCard(item: mockDeadlines[index]),
            ),
          ),
        ],
      ],
    );
  }
}

class DeadlineCard extends StatelessWidget {
  const DeadlineCard({super.key, required this.item});

  final DeadlineItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x30D8D7D5),
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 46,
            decoration: BoxDecoration(
              color: item.color,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: _DeadlineText.title),
                const SizedBox(height: 4),
                Text(
                  item.schedule,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _DeadlineText.body,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 108),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.tag,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _DeadlineText.tag.copyWith(color: item.tagColor),
                ),
                const SizedBox(height: 4),
                Text(
                  item.remaining,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _DeadlineText.body.copyWith(
                    color: item.remainingColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  const _WeekdayLabel(this.text, {this.selected = false});

  final String text;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 11,
        height: 14 / 11,
        fontWeight: FontWeight.w700,
        color: selected ? const Color(0xFFC9A227) : const Color(0xFFD8C27F),
      ),
    );
  }
}

abstract final class _SectionTitle {
  static const style = TextStyle(
    fontFamily: 'Inter',
    fontSize: 13,
    height: 17 / 13,
    fontWeight: FontWeight.w700,
    color: AuthColors.navy,
  );
}

abstract final class _DeadlineText {
  static const title = TextStyle(
    fontFamily: 'Inter',
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w700,
    color: AuthColors.navy,
  );
  static const body = TextStyle(
    fontFamily: 'Inter',
    fontSize: 10,
    height: 13 / 10,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );
  static const tag = TextStyle(
    fontFamily: 'Inter',
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w500,
  );
}
