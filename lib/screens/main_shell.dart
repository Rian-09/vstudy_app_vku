import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/auth_theme.dart';
import '../widgets/auth_widgets.dart';
import 'calendar/calendar_screen.dart';
import 'documents/documents_screen.dart';
import 'documents/library_screen.dart';
import 'home/home_screen.dart';
import 'quiz/quiz_home_screen.dart';
import 'stats/stats_menu_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialIndex = 2, this.showLibrary = false});

  final int initialIndex;
  final bool showLibrary;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const _tabs = <_TabItem>[
    _TabItem('Lịch', 'assets/images/home/tab_calendar.svg'),
    _TabItem('Quiz', 'assets/images/home/tab_quiz.svg'),
    _TabItem('Trang chủ', 'assets/images/home/tab_home.svg'),
    _TabItem('Thống kê', 'assets/images/home/tab_stats.svg'),
    _TabItem('Tài liệu', 'assets/images/home/tab_documents.svg'),
  ];

  late int _selectedIndex;
  late bool _showLibrary;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _showLibrary = widget.showLibrary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _showLibrary
          ? const LibraryScreen()
          : switch (_selectedIndex) {
              0 => const CalendarScreen(),
              1 => const QuizNavigationHost(),
              2 => const HomeScreen(),
              3 => const StatsNavigationHost(),
              4 => const DocumentsScreen(),
              _ => _PlaceholderTab(title: _tabs[_selectedIndex].label),
            },
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton:
          _selectedIndex == 0 ||
              _selectedIndex == 1 ||
              _selectedIndex == 2 ||
              _selectedIndex == 3 ||
              _selectedIndex == 4
          ? SizedBox.square(
              dimension: 65,
              child: FloatingActionButton(
                tooltip: 'Trợ lý AI',
                heroTag: 'home-ai-assistant',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Trợ lý AI sắp ra mắt'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                backgroundColor: const Color(0xFFC9A227),
                foregroundColor: Colors.white,
                elevation: 8,
                shape: const CircleBorder(),
                child: SvgPicture.asset(
                  'assets/images/home/ai_badge.svg',
                  width: 65,
                  height: 65,
                ),
              ),
            )
          : null,
      bottomNavigationBar: _MainBottomNavigationBar(
        items: _tabs,
        selectedIndex: _selectedIndex,
        onSelected: (index) => setState(() {
          _selectedIndex = index;
          _showLibrary = false;
        }),
      ),
    );
  }
}

class _MainBottomNavigationBar extends StatelessWidget {
  const _MainBottomNavigationBar({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<_TabItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return SizedBox(
      height: 69 + bottomInset,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / items.length;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: 69 + bottomInset,
                child: ColoredBox(
                  color: const Color(0xFFC8CFDF),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(height: 1, color: const Color(0x70000000)),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 8,
                height: 46,
                child: Row(
                  children: [
                    for (var index = 0; index < items.length; index++)
                      SizedBox(
                        width: itemWidth,
                        child: index == 2
                            ? const SizedBox.shrink()
                            : _NavigationItem(
                                item: items[index],
                                selected: selectedIndex == index,
                                onTap: () => onSelected(index),
                              ),
                      ),
                  ],
                ),
              ),
              Positioned(
                left: (constraints.maxWidth - 78) / 2,
                top: -22,
                width: 78,
                height: 78,
                child: Semantics(
                  button: true,
                  selected: selectedIndex == 2,
                  label: items[2].label,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onSelected(2),
                      customBorder: const CircleBorder(),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/images/home/selected_home_outer.svg',
                            width: 78,
                            height: 78,
                          ),
                          SvgPicture.asset(
                            'assets/images/home/selected_home_inner.svg',
                            width: 62,
                            height: 62,
                          ),
                          SvgPicture.asset(
                            items[2].iconAsset,
                            width: 26,
                            height: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _TabItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: IconButton(
        tooltip: item.label,
        onPressed: onTap,
        padding: EdgeInsets.zero,
        icon: SvgPicture.asset(
          item.iconAsset,
          width: 26,
          height: 26,
          colorFilter: selected
              ? const ColorFilter.mode(AuthColors.accent, BlendMode.srcIn)
              : null,
        ),
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: SafeArea(
        child: Center(child: Text(title, style: AuthTextStyles.title)),
      ),
    );
  }
}

class _TabItem {
  const _TabItem(this.label, this.iconAsset);

  final String label;
  final String iconAsset;
}
