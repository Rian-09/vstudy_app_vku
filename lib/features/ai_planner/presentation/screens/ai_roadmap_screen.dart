import 'package:flutter/material.dart';

import 'package:flutter_application_1/features/ai_planner/data/datasources/ai_service.dart';
import 'package:flutter_application_1/core/widgets/auth_widgets.dart';
import 'ai_create_test_screen.dart';
import 'package:flutter_application_1/features/ai_planner/presentation/widgets/ai_widgets.dart';

class AiRoadmapScreen extends StatefulWidget {
  const AiRoadmapScreen({super.key});
  @override
  State<AiRoadmapScreen> createState() => _AiRoadmapScreenState();
}

class _AiRoadmapScreenState extends State<AiRoadmapScreen> {
  final _service = AiService.instance;

  @override
  Widget build(BuildContext context) {
    final done = _service.roadmapTasks.where((task) => task.done).length;
    final readiness = (64 + done * 9).clamp(0, 100);
    return AuthBackground(
      child: SafeArea(
        child: Column(
          children: [
            const AiScreenHeader(
              title: 'Lộ trình ôn tập',
              subtitle: 'AI lập theo lịch thi của bạn',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(18, 15, 18, 13),
                      decoration: BoxDecoration(
                        color: aiNavy,
                        borderRadius: BorderRadius.circular(23),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Thi Giải tích 1',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    color: Color(0xFFD8DCE7),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 13,
                                  vertical: 6,
                                ),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFC9A227),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(15),
                                  ),
                                ),
                                child: const Text(
                                  '26/10/2026',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: aiNavy,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'còn 12 ngày',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 11),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: readiness / 100,
                              minHeight: 7,
                              backgroundColor: const Color(0xFF46516D),
                              color: aiGold,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            'Sẵn sàng $readiness%',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFE7E3D8)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [for (var i = 0; i < 7; i++) _day(i)],
                      ),
                    ),
                    const SizedBox(height: 17),
                    const Text(
                      'Hôm nay · 14/10',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: aiNavy,
                      ),
                    ),
                    const SizedBox(height: 11),
                    for (var i = 0; i < _service.roadmapTasks.length; i++) ...[
                      RoadmapTaskTile(
                        task: _service.roadmapTasks[i],
                        tag: i < 4
                            ? const ['Đọc', 'Đề', 'Thẻ', 'AI'][i]
                            : 'Thêm',
                        onChanged: () => setState(() => _service.toggleTask(i)),
                      ),
                      const SizedBox(height: 8),
                    ],
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF2C8),
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            color: Color(0xFF9C7600),
                            size: 21,
                          ),
                          const SizedBox(width: 9),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Gợi ý AI',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF9C7600),
                                  ),
                                ),
                                Text(
                                  'Bạn hay sai phần Lagrange. Thêm 20 phút ôn vào chiều mai?',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 10,
                                    height: 14 / 10,
                                    color: aiNavy,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            height: 30,
                            child: FilledButton(
                              onPressed: () =>
                                  setState(_service.addSuggestedTask),
                              style: FilledButton.styleFrom(
                                backgroundColor: aiNavy,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 13,
                                ),
                                textStyle: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              child: const Text('Thêm'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: 'Bắt đầu ôn tập',
                      onPressed: () => Navigator.of(context).pushNamed<void>(
                        '/ai-quiz-play',
                        arguments: const AiPlayArgs(
                          examId: 'philosophy-exam-3',
                          timed: false,
                        ),
                      ),
                      height: 52,
                      borderRadius: 24,
                      showArrow: false,
                      enabledBackgroundColor: const Color(0xFFC9A227),
                      enabledForegroundColor: aiNavy,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _day(int index) {
    const labels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final colors = [
      const Color(0xFF8A93AA),
      const Color(0xFF495676),
      aiNavy,
      const Color(0xFFD9DDE7),
      const Color(0xFFD9DDE7),
      const Color(0xFFD9DDE7),
      const Color(0xFFEFE8D8),
    ];
    final active = index == 2;
    return Column(
      children: [
        Text(
          labels[index],
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 9,
            color: Color(0xFF8A93AA),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 36,
          height: 39,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors[index],
            borderRadius: BorderRadius.circular(11),
            border: active ? Border.all(color: aiGold, width: 2) : null,
          ),
          child: Text(
            '${12 + index}',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: index == 6 ? aiNavy : Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
