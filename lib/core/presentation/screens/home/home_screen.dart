import 'package:flutter/material.dart';

import '../../../../features/auth/data/datasources/auth_service.dart';
import '../../../../core/widgets/auth_widgets.dart';
import 'home_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final storedName = AuthService.instance.currentUserName?.trim();
    final userName = storedName == null || storedName.isEmpty
        ? 'Tom'
        : storedName;

    return AuthBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 47, 16, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 17, right: 16),
                child: GreetingHeader(
                  userName: userName,
                  avatarAsset:
                      user?.avatarAsset ?? 'assets/images/home/home_avatar.png',
                  onAvatarTap: _openProfile,
                ),
              ),
              const SizedBox(height: 31),
              StudyProgressCard(
                onQuizTap: () => _showMessage(context, 'Quiz sẽ sớm khả dụng.'),
              ),
              const SizedBox(height: 50),
              QuickAccessList(
                onItemTap: (item) => _showMessage(context, item.title),
              ),
              const SizedBox(height: 21),
              const AiSuggestionBanner(),
              const SizedBox(height: 30),
              WeeklyChart(
                onDetailsTap: () =>
                    _showMessage(context, 'Chi tiết tuần sẽ sớm khả dụng.'),
              ),
              const SizedBox(height: 26),
              UpcomingDeadlines(
                onSeeAllTap: () =>
                    _showMessage(context, 'Danh sách đầy đủ sẽ sớm khả dụng.'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openProfile() async {
    await Navigator.of(context).pushNamed<void>('/profile');
    if (mounted) setState(() {});
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}
