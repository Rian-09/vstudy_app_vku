import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_application_1/features/documents/data/models/document.dart';
import 'package:flutter_application_1/core/theme/auth_theme.dart';
import 'package:flutter_application_1/core/widgets/auth_widgets.dart';
import 'package:flutter_application_1/features/documents/presentation/widgets/document_widgets.dart';
import 'package:flutter_application_1/features/documents/presentation/providers/document_providers.dart';

const _libraryGold = Color(0xFFDFA841);
const _libraryNavy = Color(0xFF1F2A44);
const _libraryCream = Color(0xFFF6EBC4);

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  static const _folders = [
    'Môn đại cương',
    'Chuyên ngành CNTT',
    'Ôn thi cấp tốc',
  ];

  int _selectedFolder = 0;
  bool _showAiHint = true;

  void _openDocument(StudyDocument document) {
    Navigator.of(context)
        .pushNamed<void>('/documents/viewer', arguments: document.id);
  }

  @override
  Widget build(BuildContext context) {
    final repository = ref.watch(documentRepositoryProvider);
    final documentUseCases = ref.read(documentUseCasesProvider);
    return AuthBackground(
      child: SafeArea(
        child: Builder(
          builder: (context) {
            final savedDocuments = repository.savedOrDownloaded;
            final popularDocuments = repository.documents.take(2).toList();
            final filteredDocuments = _selectedFolder == 0
                ? savedDocuments
                : savedDocuments.where((document) {
                    if (_selectedFolder == 1) {
                      return document.category == DocumentCategory.course;
                    }
                    return document.category == DocumentCategory.exam;
                  }).toList();
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(13, 6, 13, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _LibraryHeader(
                    onBack: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(height: 13),
                  const _LibrarySummaryCard(),
                  const SizedBox(height: 12),
                  if (_showAiHint) ...[
                    AiHintBanner(
                      onDismiss: () => setState(() => _showAiHint = false),
                    ),
                    const SizedBox(height: 13),
                  ],
                  Row(
                    children: [
                      const Text(
                        '▱  Thư mục:',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF786149),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: SizedBox(
                          height: 29,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _folders.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 5),
                            itemBuilder: (context, index) {
                              final selected = index == _selectedFolder;
                              return Material(
                                color: selected
                                    ? Colors.white
                                    : const Color(0xB3FFFFFF),
                                borderRadius: BorderRadius.circular(20),
                                child: InkWell(
                                  onTap: () =>
                                      setState(() => _selectedFolder = index),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    child: Text(
                                      _folders[index],
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 9,
                                        fontWeight: selected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: selected
                                            ? const Color(0xFFB45309)
                                            : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 202,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: popularDocuments.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final document = popularDocuments[index];
                        return DocCard(
                          document: document,
                          onOpen: () => _openDocument(document),
                          onDownload: () => _openDocument(document),
                          onToggleSaved: () =>
                              documentUseCases.toggleSaved(document.id),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Đang xem',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF786149),
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  if (filteredDocuments.isEmpty)
                    const _LibraryEmptyState()
                  else
                    for (
                      var index = 0;
                      index < filteredDocuments.length;
                      index++
                    ) ...[
                      if (index > 0) const SizedBox(height: 9),
                      DownloadProgressTile(
                        document: filteredDocuments[index],
                        onOpen: () => _openDocument(filteredDocuments[index]),
                        onContinue: () =>
                            _openDocument(filteredDocuments[index]),
                      ),
                    ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LibraryHeader extends StatelessWidget {
  const _LibraryHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: onBack,
              tooltip: 'Quay lại tài liệu',
              padding: EdgeInsets.zero,
              icon: SvgPicture.asset(
                'assets/images/documents/viewer_back.svg',
                width: 22,
                height: 22,
              ),
            ),
          ),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Thư viện đã lưu',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  height: 18 / 14,
                  fontWeight: FontWeight.w700,
                  color: AuthColors.navy,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Kho giáo trình & đề thi V-Study',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 9,
                  color: AuthColors.grayBlue,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: onBack,
              tooltip: 'Tài liệu đã lưu',
              icon: SvgPicture.asset(
                'assets/images/documents/library_bookmarks.svg',
                width: 20,
                height: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LibrarySummaryCard extends StatelessWidget {
  const _LibrarySummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 222,
      padding: const EdgeInsets.fromLTRB(21, 25, 16, 13),
      decoration: BoxDecoration(
        color: _libraryNavy,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x558A9AB8),
            offset: Offset(0, 4),
            blurRadius: 4,
          ),
        ],
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
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Bộ tập ôn các môn Đại cương chuẩn VKU',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  color: _libraryGold,
                ),
              ),
              const SizedBox(height: 12),
              const _LibrarySummaryStats(),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 36,
                child: FilledButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tải offline sẽ sớm khả dụng.'),
                    ),
                  ),
                  icon: SvgPicture.asset(
                    'assets/images/documents/success_offline.svg',
                    width: 14,
                    height: 14,
                  ),
                  label: const Text('Tải toàn bộ học Offline'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFF5A623),
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            right: 3,
            top: 0,
            child: SvgPicture.asset(
              'assets/images/documents/library_sparkle.svg',
              width: 37,
              height: 37,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 1,
            child: IconButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Chia sẻ thư viện sẽ sớm khả dụng.'),
                ),
              ),
              tooltip: 'Chia sẻ thư viện',
              icon: SvgPicture.asset(
                'assets/images/documents/viewer_share.svg',
                width: 15,
                height: 15,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LibrarySummaryStats extends StatelessWidget {
  const _LibrarySummaryStats();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: const Color(0x80D9D9D9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Expanded(
            child: _SummaryStat(
              value: '14',
              label: 'Đề thi',
              color: _libraryGold,
            ),
          ),
          Expanded(
            child: _SummaryStat(
              value: '8',
              label: 'Giáo trình',
              color: Colors.white,
            ),
          ),
          Expanded(
            child: _SummaryStat(
              value: '10',
              label: 'Slide&Tóm tắt',
              color: _libraryCream,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            height: 16 / 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 8,
            height: 11 / 8,
            color: Color(0xB3FFFFFF),
          ),
        ),
      ],
    );
  }
}

class _LibraryEmptyState extends StatelessWidget {
  const _LibraryEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 28),
      child: Center(
        child: Text(
          'Chưa có tài liệu trong thư mục này',
          style: AuthTextStyles.caption,
        ),
      ),
    );
  }
}
