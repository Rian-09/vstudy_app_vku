import 'package:flutter/material.dart';

import 'package:flutter_application_1/features/ai_planner/data/models/ai_models.dart';
import 'package:flutter_application_1/features/quiz/data/models/quiz_models.dart';
import 'package:flutter_application_1/features/ai_planner/domain/usecases/ai_planner_usecases.dart';
import 'package:flutter_application_1/core/widgets/auth_widgets.dart';
import 'package:flutter_application_1/core/presentation/main_shell.dart';
import 'package:flutter_application_1/features/quiz/presentation/screens/quiz_chart_screen.dart';
import 'package:flutter_application_1/features/quiz/presentation/screens/quiz_play_screen.dart';
import 'package:flutter_application_1/features/quiz/presentation/screens/quiz_result_screen.dart';
import 'package:flutter_application_1/features/quiz/presentation/screens/quiz_review_screen.dart';
import 'ai_chat_screen.dart';
import 'ai_create_test_screen.dart';
import 'ai_pick_documents_screen.dart';
import 'ai_roadmap_screen.dart';
import 'ai_summary_screen.dart';
import 'package:flutter_application_1/features/ai_planner/presentation/widgets/ai_widgets.dart';

class AiNavigationHost extends StatelessWidget {
  const AiNavigationHost({super.key, this.shellArgs});

  final MainShellNavigationArgs? shellArgs;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: Navigator(
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final page = switch (settings.name) {
          '/' => AiHomeScreen(shellArgs: shellArgs),
          '/chat' => const AiChatScreen(),
          '/pick-documents' => const AiPickDocumentsScreen(),
          '/summary' => AiSummaryScreen(
            data: settings.arguments as AiSummaryData,
          ),
          '/create-test' => const AiCreateTestScreen(),
          '/roadmap' => const AiRoadmapScreen(),
          '/ai-quiz-play' => _quizPage(settings),
          '/quiz/result' => QuizResultScreen(
            result: settings.arguments as QuizResult,
          ),
          '/review' => QuizReviewScreen(
            result: settings.arguments as QuizResult,
          ),
          '/chart' => QuizChartScreen(result: settings.arguments as QuizResult),
          _ => const AiHomeScreen(),
        };
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => page,
        );
      },
    ),
  );

  Widget _quizPage(RouteSettings settings) {
    final args = settings.arguments as AiPlayArgs;
    return QuizPlayScreen(examId: args.examId, isTimed: args.timed);
  }
}

class AiHomeScreen extends StatelessWidget {
  const AiHomeScreen({super.key, this.shellArgs});

  final MainShellNavigationArgs? shellArgs;

  void _open(BuildContext context, String route) =>
      Navigator.of(context).pushNamed<void>(route);

  @override
  Widget build(BuildContext context) => AuthBackground(
    child: SafeArea(
      child: Column(
        children: [
          const AiScreenHeader(
            title: 'Trợ lý V-Study',
            subtitle: 'Hỏi, tóm tắt, tạo đề từ tài liệu',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 132,
                    margin: const EdgeInsets.symmetric(horizontal: 9),
                    padding: const EdgeInsets.fromLTRB(20, 17, 18, 14),
                    decoration: BoxDecoration(
                      color: aiNavy,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Hôm nay ôn gì nào?',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 21,
                                height: 26 / 21,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Chọn tài liệu và để AI giúp bạn ôn nhanh hơn.',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                color: Color(0xFFD8DCE7),
                              ),
                            ),
                            const Spacer(),
                            SizedBox(
                              height: 30,
                              child: FilledButton(
                                onPressed: () =>
                                    _open(context, '/pick-documents'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: aiGold,
                                  foregroundColor: aiNavy,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                  ),
                                  shape: const StadiumBorder(),
                                  textStyle: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                child: const Text('Chọn tài liệu'),
                              ),
                            ),
                          ],
                        ),
                        const Positioned(
                          right: 10,
                          bottom: 20,
                          child: Icon(
                            Icons.auto_awesome,
                            size: 52,
                            color: aiGold,
                          ),
                        ),
                        const Positioned(
                          right: 0,
                          top: 39,
                          child: Icon(Icons.add, size: 28, color: aiGold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Padding(
                    padding: EdgeInsets.only(left: 7),
                    child: AiSectionTitle('Công cụ AI'),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        AiToolCard(
                          iconAsset: 'assets/images/ai/tool_summary.svg',
                          label: 'Tóm tắt',
                          onTap: () => _open(context, '/pick-documents'),
                        ),
                        AiToolCard(
                          iconAsset: 'assets/images/ai/tool_question.svg',
                          iconBackgroundColor: const Color(0xFFC8CFDF),
                          label: 'Hỏi đáp',
                          onTap: () => _open(context, '/chat'),
                        ),
                        AiToolCard(
                          iconLabel: 'DOC',
                          iconBackgroundAsset: 'assets/images/ai/tool_test.svg',
                          label: 'Tạo đề ôn',
                          goldIcon: true,
                          onTap: () => _open(context, '/create-test'),
                        ),
                        AiToolCard(
                          iconAsset: 'assets/images/ai/tool_roadmap.svg',
                          iconBackgroundColor: const Color(0xFFC8CFDF),
                          label: 'Lộ trình',
                          onTap: () => _open(context, '/roadmap'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Padding(
                    padding: EdgeInsets.only(left: 7),
                    child: AiSectionTitle('Gần đây'),
                  ),
                  const SizedBox(height: 12),
                  for (final item in AiService.recentItems)
                    AiSuggestionTile(
                      title: item.$1,
                      subtitle: item.$2,
                      onTap: () => _open(context, item.$3),
                    ),
                ],
              ),
            ),
          ),
          if (shellArgs != null)
            MainShellBottomNavigationBar(
              selectedIndex: shellArgs!.selectedIndex,
              onSelected: (index) {
                shellArgs!.onSelected(index);
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
        ],
      ),
    ),
  );
}
