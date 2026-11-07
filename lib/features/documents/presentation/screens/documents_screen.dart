import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter_application_1/features/documents/data/models/document.dart';
import 'package:flutter_application_1/core/theme/auth_theme.dart';
import 'package:flutter_application_1/core/widgets/auth_widgets.dart';
import 'package:flutter_application_1/features/documents/presentation/widgets/document_widgets.dart';

const _documentsGold = Color(0xFFDFA841);
const _documentsNavy = Color(0xFF1E2A4A);

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _popularKey = GlobalKey();
  int _selectedTab = 0;
  int _selectedSubject = 0;
  String _query = '';

  List<String> get _subjects => _selectedTab == 0
      ? const [
          'Tất cả (299)',
          'Mạng máy tính',
          'Triết học Mác-Lênin',
          'Pháp luật đại cương',
        ]
      : const [
          'Tất cả (299)',
          'Mạng máy tính',
          'Triết học Mác-Lênin',
          'Pháp luật đại cương',
        ];

  List<StudyDocument> _filteredDocuments(List<StudyDocument> allDocuments) {
    final category = _selectedTab == 0
        ? DocumentCategory.course
        : DocumentCategory.exam;
    final subject = _selectedSubject == 0 ? null : _subjects[_selectedSubject];
    return allDocuments.where((document) {
      final matchesCategory = document.category == category;
      final matchesSubject = subject == null || document.subject == subject;
      final matchesQuery =
          _query.isEmpty ||
          document.title.toLowerCase().contains(_query.toLowerCase());
      return matchesCategory && matchesSubject && matchesQuery;
    }).toList();
  }

  void _openDocument(StudyDocument document) {
    Navigator.of(context)
        .pushNamed<void>('/documents/viewer', arguments: document.id);
  }

  void _openLibrary() {
    Navigator.of(context).pushNamed<void>('/documents/library');
  }

  Future<void> _scrollToPopular() async {
    final targetContext = _popularKey.currentContext;
    if (targetContext != null) {
      await Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuthBackground(
        child: SafeArea(
          child: AnimatedBuilder(
            animation: DocumentRepository.instance,
            builder: (context, child) {
              final allDocuments = DocumentRepository.instance.documents;
              final documents = _filteredDocuments(allDocuments);
              final popular = documents.take(2).toList();
              final selected = documents.length > 2
                  ? documents.skip(2).toList()
                  : documents;
              return SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(21, 7, 21, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DocumentsHeader(onOpenLibrary: _openLibrary),
                    const SizedBox(height: 10),
                    DocSearchBar(
                      controller: _searchController,
                      onChanged: (value) =>
                          setState(() => _query = value.trim()),
                    ),
                    const SizedBox(height: 11),
                    StudyPromptCard(onChoose: _scrollToPopular),
                    const SizedBox(height: 13),
                    FilterTabs(
                      items: const ['Tài liệu môn học', 'Tài liệu ôn thi & Đề'],
                      selectedIndex: _selectedTab,
                      onSelected: (index) => setState(() {
                        _selectedTab = index;
                        _selectedSubject = 0;
                      }),
                    ),
                    const SizedBox(height: 10),
                    SubjectChips(
                      items: _subjects,
                      selectedIndex: _selectedSubject,
                      onSelected: (index) =>
                          setState(() => _selectedSubject = index),
                    ),
                    const SizedBox(height: 16),
                    KeyedSubtree(
                      key: _popularKey,
                      child: _SectionHeading(
                        title: 'Tài liệu tải nhiều nhất',
                        action: 'Xem tất cả',
                        iconAsset: 'assets/images/documents/fire.svg',
                        onAction: () => setState(() => _selectedSubject = 0),
                      ),
                    ),
                    const SizedBox(height: 9),
                    SizedBox(
                      height: 202,
                      child: popular.isEmpty
                          ? const _EmptyResults()
                          : ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: popular.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final document = popular[index];
                                return DocCard(
                                  document: document,
                                  onOpen: () => _openDocument(document),
                                  onDownload: () => _openDocument(document),
                                  onToggleSaved: () => DocumentRepository
                                      .instance
                                      .toggleSaved(document.id),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 18),
                    _SectionHeading(
                      title: _selectedTab == 0
                          ? 'Danh mục tài liệu chọn lọc'
                          : 'Danh mục tài liệu ôn tập',
                      action: 'Xem tất cả',
                      onAction: () => setState(() => _selectedSubject = 0),
                    ),
                    const SizedBox(height: 9),
                    if (selected.isEmpty)
                      const _EmptyResults()
                    else
                      for (var index = 0; index < selected.length; index++) ...[
                        if (index > 0) const SizedBox(height: 10),
                        DocListTile(
                          document: selected[index],
                          onOpen: () => _openDocument(selected[index]),
                          onDownload: () => _openDocument(selected[index]),
                          onToggleSaved: () => DocumentRepository.instance
                              .toggleSaved(selected[index].id),
                        ),
                      ],
                    const SizedBox(height: 16),
                    const _ShareDocumentPrompt(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DocumentsHeader extends StatelessWidget {
  const _DocumentsHeader({required this.onOpenLibrary});

  final VoidCallback onOpenLibrary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tài liệu học tập',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  height: 20 / 16,
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
                  height: 12 / 9,
                  color: AuthColors.grayBlue,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onOpenLibrary,
          tooltip: 'Thư viện tài liệu đã lưu',
          icon: SvgPicture.asset(
            'assets/images/documents/library_icon.svg',
            width: 23,
            height: 23,
          ),
        ),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.action,
    required this.onAction,
    this.iconAsset,
  });

  final String title;
  final String action;
  final String? iconAsset;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AuthColors.navy,
          ),
        ),
        if (iconAsset != null) ...[
          const SizedBox(width: 4),
          SvgPicture.asset(iconAsset!, width: 12, height: 12),
        ],
        const Spacer(),
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(
            foregroundColor: _documentsGold,
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            textStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: Text(action),
        ),
      ],
    );
  }
}

class _ShareDocumentPrompt extends StatelessWidget {
  const _ShareDocumentPrompt();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: _documentsGold,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_upload_outlined,
              size: 18,
              color: _documentsNavy,
            ),
          ),
          const SizedBox(width: 9),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chia sẻ tài liệu của bạn',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AuthColors.navy,
                  ),
                ),
                Text(
                  'Đóng góp bài giảng, nhận ngay 100 điểm V-Study',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 8,
                    color: AuthColors.grayBlue,
                  ),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Chia sẻ tài liệu sẽ sớm khả dụng.'),
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: _documentsNavy,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 11),
              minimumSize: const Size(0, 29),
              shape: const StadiumBorder(),
              textStyle: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Text('Đăng tải'),
          ),
        ],
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 82,
      child: Center(
        child: Text(
          'Không tìm thấy tài liệu phù hợp',
          style: AuthTextStyles.caption,
        ),
      ),
    );
  }
}
