import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../models/ai_models.dart';
import '../../../models/document.dart';

const aiGold = Color(0xFFDFA841);
const aiNavy = Color(0xFF1E2A4A);
const aiCream = Color(0xFFEFE8D8);
const _caption = TextStyle(
  fontFamily: 'Inter',
  fontSize: 10,
  color: Color(0xFF8A93AA),
);

class AiScreenHeader extends StatelessWidget {
  const AiScreenHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.onBack,
  });
  final String title;
  final String subtitle;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) => Container(
    height: 66,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    decoration: const BoxDecoration(color: Color(0x42FFFFFF)),
    child: Row(
      children: [
        InkWell(
          customBorder: const CircleBorder(),
          onTap: onBack ?? () => Navigator.of(context).maybePop(),
          child: SvgPicture.asset('assets/images/ai/back_arrow.svg'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  height: 22 / 18,
                  fontWeight: FontWeight.w700,
                  color: aiNavy,
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _caption.copyWith(fontSize: 11),
              ),
            ],
          ),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: Color(0xFFC9A227),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: SvgPicture.asset('assets/images/ai/ai_sparkle.svg'),
          ),
        ),
      ],
    ),
  );
}

class AiSectionTitle extends StatelessWidget {
  const AiSectionTitle(this.title, {super.key});
  final String title;
  @override
  Widget build(BuildContext context) => Text(
    title,
    style: const TextStyle(
      fontFamily: 'Inter',
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: aiNavy,
    ),
  );
}

class AiToolCard extends StatelessWidget {
  const AiToolCard({
    super.key,
    this.icon = Icons.auto_awesome,
    this.iconAsset,
    this.iconBackgroundAsset,
    this.iconLabel,
    this.iconBackgroundColor,
    required this.label,
    required this.onTap,
    this.goldIcon = false,
  });
  final IconData icon;
  final String? iconAsset;
  final String? iconBackgroundAsset;
  final String? iconLabel;
  final Color? iconBackgroundColor;
  final String label;
  final VoidCallback onTap;
  final bool goldIcon;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 10),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Container(
        width: 120,
        height: 96,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: const Color(0xFFE7E3D8)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                height: 1.1,
                fontWeight: FontWeight.w700,
                color: aiNavy,
              ),
            ),
            const SizedBox(height: 5),
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBackgroundAsset != null
                    ? Colors.transparent
                    : iconBackgroundColor ??
                          (goldIcon ? const Color(0xFFC9A227) : aiNavy),
                shape: BoxShape.circle,
              ),
              child: iconBackgroundAsset != null
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        SvgPicture.asset(iconBackgroundAsset!),
                        if (iconLabel != null)
                          Text(
                            iconLabel!,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: aiNavy,
                            ),
                          ),
                      ],
                    )
                  : iconLabel != null
                  ? Center(
                      child: Text(
                        iconLabel!,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: aiNavy,
                        ),
                      ),
                    )
                  : iconAsset != null
                  ? SvgPicture.asset(iconAsset!)
                  : Icon(icon, size: 22, color: Colors.white),
            ),
          ],
        ),
      ),
    ),
  );
}

class AiSuggestionTile extends StatelessWidget {
  const AiSuggestionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(17),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: const Color(0xFFE7E3D8)),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: aiCream,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, color: aiNavy, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: aiNavy,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _caption,
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

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});
  final AiChatMessage message;
  @override
  Widget build(BuildContext context) => Align(
    alignment: message.fromUser ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      constraints: const BoxConstraints(maxWidth: 318),
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: message.fromUser ? aiNavy : Colors.white,
        border: message.fromUser
            ? null
            : Border.all(color: const Color(0xFFE7E3D8)),
        borderRadius: BorderRadius.circular(19),
      ),
      child: Text(
        message.text,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          height: 18 / 13,
          color: message.fromUser ? Colors.white : aiNavy,
        ),
      ),
    ),
  );
}

class SuggestionChip extends StatelessWidget {
  const SuggestionChip({super.key, required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ActionChip(
    label: Text(
      label,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: aiNavy,
      ),
    ),
    onPressed: onTap,
    side: const BorderSide(color: Color(0xFFE7E3D8)),
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
    visualDensity: VisualDensity.compact,
  );
}

class SummaryTabs extends StatelessWidget {
  const SummaryTabs({super.key, required this.index, required this.onChanged});
  final int index;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      color: const Color(0xFFECE6D8),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        for (var i = 0; i < 3; i++)
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: index == i ? aiNavy : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  ['Ngắn gọn', 'Chi tiết', 'Sơ đồ'][i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: index == i ? FontWeight.w700 : FontWeight.w400,
                    color: index == i ? Colors.white : aiNavy,
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class MindMapView extends StatelessWidget {
  const MindMapView({super.key});
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(18),
    child: Image.asset(
      'assets/images/ai/lagrange_mind_map.png',
      fit: BoxFit.contain,
      errorBuilder: (context, error, stack) => const _MindMapFallback(),
    ),
  );
}

class _MindMapFallback extends StatelessWidget {
  const _MindMapFallback();
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 300,
    child: CustomPaint(
      painter: _MindMapPainter(),
      child: const Center(
        child: Text(
          'PHƯƠNG PHÁP NHÂN TỬ LAGRANGE',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w700, color: aiNavy),
        ),
      ),
    ),
  );
}

class _MindMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final points = [
      Offset(size.width * .18, 45),
      Offset(size.width * .82, 45),
      Offset(size.width * .18, size.height - 45),
      Offset(size.width * .82, size.height - 45),
    ];
    final line = Paint()
      ..color = const Color(0xFFB9C2D4)
      ..strokeWidth = 2;
    for (final p in points) {
      canvas.drawLine(center, p, line);
      canvas.drawCircle(p, 30, Paint()..color = const Color(0xFFF7F0DF));
    }
    canvas.drawCircle(center, 43, Paint()..color = aiNavy);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DocCheckTile extends StatelessWidget {
  const DocCheckTile({
    super.key,
    required this.document,
    required this.selected,
    required this.onChanged,
  });
  final StudyDocument document;
  final bool selected;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
    final extension = document.type.toLowerCase().contains('slide')
        ? 'PPT'
        : document.type.toLowerCase().contains('báo cáo')
        ? 'DOC'
        : 'PDF';
    return InkWell(
      onTap: () => onChanged(!selected),
      borderRadius: BorderRadius.circular(17),
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: const Color(0xFFE7E3D8)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 46,
              decoration: BoxDecoration(
                color: aiNavy,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  extension,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: aiNavy,
                    ),
                  ),
                  Text(
                    '${document.pages} trang · ${document.updatedAt}',
                    style: _caption,
                  ),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? aiNavy : Colors.transparent,
                border: Border.all(
                  color: selected ? aiNavy : const Color(0xFFD4D0C4),
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class OptionChips extends StatelessWidget {
  const OptionChips({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelected,
  });
  final List<String> items;
  final String selected;
  final ValueChanged<String> onSelected;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (var i = 0; i < items.length; i++)
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == items.length - 1 ? 0 : 8),
            child: InkWell(
              onTap: () => onSelected(items[i]),
              borderRadius: BorderRadius.circular(13),
              child: Container(
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected == items[i] ? aiNavy : aiCream,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text(
                  items[i],
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected == items[i] ? Colors.white : aiNavy,
                  ),
                ),
              ),
            ),
          ),
        ),
    ],
  );
}

class RoadmapTaskTile extends StatelessWidget {
  const RoadmapTaskTile({
    super.key,
    required this.task,
    required this.onChanged,
    this.tag = 'Đọc',
  });
  final AiRoadmapTask task;
  final VoidCallback onChanged;
  final String tag;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: onChanged,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE7E3D8)),
        ),
        child: Row(
          children: [
            Icon(
              task.done ? Icons.check_circle : Icons.radio_button_unchecked,
              color: task.done
                  ? const Color(0xFF7E8CA9)
                  : const Color(0xFF8A93AA),
              size: 23,
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: aiNavy,
                    ),
                  ),
                  Text('${task.subtitle} · Giải tích 1', style: _caption),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: aiCream,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Text(
                tag,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: aiNavy,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class AiToggleRow extends StatelessWidget {
  const AiToggleRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: aiNavy,
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.white,
          activeTrackColor: aiNavy,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: aiCream,
        ),
      ],
    ),
  );
}

class AiDocFormatIcon extends StatelessWidget {
  const AiDocFormatIcon({super.key, required this.format});
  final String format;
  @override
  Widget build(BuildContext context) => Container(
    width: 40,
    height: 44,
    decoration: BoxDecoration(
      color: aiNavy,
      borderRadius: BorderRadius.circular(11),
    ),
    child: Center(
      child: Text(
        format,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    ),
  );
}
