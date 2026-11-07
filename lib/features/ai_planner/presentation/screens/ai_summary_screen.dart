import 'package:flutter/material.dart';

import 'package:flutter_application_1/features/ai_planner/data/models/ai_models.dart';
import 'package:flutter_application_1/core/widgets/auth_widgets.dart';
import 'package:flutter_application_1/core/widgets/profile_dialogs.dart';
import 'package:flutter_application_1/features/ai_planner/presentation/widgets/ai_widgets.dart';

class AiSummaryScreen extends StatefulWidget {
  const AiSummaryScreen({super.key, required this.data});
  final AiSummaryData data;
  @override
  State<AiSummaryScreen> createState() => _AiSummaryScreenState();
}

class _AiSummaryScreenState extends State<AiSummaryScreen> {
  int _tab = 0;

  Widget _card({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFE8E2D5)),
      borderRadius: BorderRadius.circular(21),
    ),
    child: child,
  );

  @override
  Widget build(BuildContext context) => AuthBackground(
    child: SafeArea(
      child: Column(
        children: [
          const AiScreenHeader(
            title: 'Tóm tắt tài liệu',
            subtitle: 'Tóm tắt ngắn gọn, dễ hiểu',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _card(
                    child: Row(
                      children: [
                        const AiDocFormatIcon(format: 'PDF'),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.data.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: aiNavy,
                                ),
                              ),
                              const Text(
                                '48 trang → 1 trang tóm tắt',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 10,
                                  color: Color(0xFF8A93AA),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(11),
                  ),
                  const SizedBox(height: 15),
                  SummaryTabs(
                    index: _tab,
                    onChanged: (value) => setState(() => _tab = value),
                  ),
                  const SizedBox(height: 17),
                  if (_tab == 0) ...[
                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ý chính',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: aiNavy,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _bullet(
                            'Định lý Rolle và định lý giá trị trung bình là nền tảng của chương.',
                          ),
                          _bullet(
                            'Điều kiện: liên tục trên [a, b], khả vi trên (a, b).',
                          ),
                          _bullet(
                            'Ứng dụng: chứng minh bất đẳng thức, đánh giá nghiệm phương trình.',
                          ),
                          _bullet(
                            'Hay gặp trong đề thi: chứng minh tồn tại c thuộc (a, b).',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Quan trọng',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: aiNavy,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 7,
                            runSpacing: 7,
                            children: [
                              'Rolle',
                              'Lagrange',
                              'Khả vi',
                              'Liên tục',
                              'Cực trị',
                            ].map((word) => _tag(word)).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _card(
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Tóm tắt này hữu ích?',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: aiNavy,
                              ),
                            ),
                          ),
                          _ratingButton(Icons.thumb_up_alt_outlined),
                          const SizedBox(width: 6),
                          _ratingButton(Icons.thumb_down_alt_outlined),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                    ),
                  ] else if (_tab == 1) ...[
                    _detailCard(
                      1,
                      'Định lý Rolle',
                      'Nếu f liên tục trên [a, b], khả vi trên (a, b) và f(a) = f(b) thì tồn tại c ∈ (a, b) sao cho:',
                      'f′(c) = 0',
                      'Ý nghĩa: tiếp tuyến tại c nằm ngang.',
                      'Tr. 3–5',
                    ),
                    const SizedBox(height: 16),
                    _detailCard(
                      2,
                      'Định lý Lagrange',
                      'Bổ đề của định lý Rolle cho ta:',
                      'f′(c) = (f(b) − f(a)) / (b − a)',
                      'Ý nghĩa: có điểm mà tốc độ tiếp tuyến bằng độ dốc trung bình của cả đoạn.',
                      'Tr. 6–9',
                    ),
                    const SizedBox(height: 14),
                    _collapsedDetail(3, 'Ứng dụng', 'Tr. 10–13'),
                    const SizedBox(height: 12),
                    _collapsedDetail(4, 'Bài tập thường gặp', 'Tr. 14–20'),
                  ] else ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: const MindMapView(),
                    ),
                  ],
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: 'Tạo flashcard',
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) =>
                          const SuccessPopup(message: 'Đã tạo flashcard!'),
                    ),
                    height: 54,
                    borderRadius: 20,
                    showArrow: false,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _bullet(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Icon(Icons.circle, size: 7, color: Color(0xFFC9A227)),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              height: 17 / 12,
              color: aiNavy,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _tag(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xFFEFE8D8),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: aiNavy,
      ),
    ),
  );

  Widget _ratingButton(IconData icon) => Container(
    width: 34,
    height: 34,
    decoration: const BoxDecoration(
      color: Color(0xFFEFE8D8),
      shape: BoxShape.circle,
    ),
    child: Icon(icon, size: 17, color: Colors.black),
  );

  Widget _detailCard(
    int number,
    String title,
    String intro,
    String formula,
    String note,
    String pages,
  ) => _card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 27,
              height: 27,
              decoration: const BoxDecoration(
                color: aiNavy,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$number',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: aiNavy,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFEFE8D8),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                pages,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: aiNavy,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Text(
          intro,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            height: 15 / 11,
            color: aiNavy,
          ),
        ),
        const SizedBox(height: 9),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: const Color(0xFFEFE8D8),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            formula,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: aiNavy,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          note,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            height: 15 / 10,
            color: Color(0xFF8A93AA),
          ),
        ),
      ],
    ),
  );

  Widget _collapsedDetail(int number, String title, String pages) => _card(
    child: Row(
      children: [
        CircleAvatar(
          radius: 13,
          backgroundColor: const Color(0xFFEFE8D8),
          child: Text(
            '$number',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: aiNavy,
            ),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: aiNavy,
            ),
          ),
        ),
        Text(
          pages,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: aiNavy,
          ),
        ),
        const SizedBox(width: 7),
        const Icon(Icons.keyboard_arrow_down, color: Color(0xFF8A93AA)),
      ],
    ),
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
  );
}
