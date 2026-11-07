import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter_application_1/features/documents/data/models/document.dart';
import 'package:flutter_application_1/core/theme/auth_theme.dart';
import 'package:flutter_application_1/core/widgets/auth_widgets.dart';
import 'package:flutter_application_1/features/documents/presentation/widgets/document_widgets.dart';

const _viewerPages = [
  'assets/images/documents/viewer_page_1.png',
  'assets/images/documents/viewer_page_2.png',
  'assets/images/documents/viewer_page_3.png',
];
const _viewerWarmText = Color(0xFF554336);

class DocumentViewerScreen extends StatefulWidget {
  const DocumentViewerScreen({super.key, required this.documentId});

  final String documentId;

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  bool _showAiHint = true;

  StudyDocument get _document =>
      DocumentRepository.instance.findById(widget.documentId) ??
      DocumentRepository.instance.documents.first;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _startDownload() async {
    final document = _document;
    final started = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DownloadSheet(document: document),
    );
    if (started != true || !mounted) return;

    DocumentRepository.instance.markDownloaded(document.id);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0x99F6EBC4),
      builder: (dialogContext) => DownloadSuccessPopup(
        document: _document,
        onViewNow: () => Navigator.of(dialogContext).pop(),
        onSaveToLibrary: () {
          DocumentRepository.instance.saveToLibrary(document.id);
          Navigator.of(dialogContext).pop();
          Navigator.of(context).pushNamed<void>('/documents/library');
        },
        onClose: () => Navigator.of(dialogContext).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final document = _document;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuthBackground(
        child: SafeArea(
          child: Column(
            children: [
              _ViewerHeader(
                document: document,
                onBack: () => Navigator.of(context).maybePop(),
                onToggleSaved: () =>
                    DocumentRepository.instance.toggleSaved(document.id),
                onOpenLibrary: () =>
                    Navigator.of(context).pushNamed('/documents/library'),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(21, 10, 21, 24),
                      child: Column(
                        children: [
                          AnimatedBuilder(
                            animation: DocumentRepository.instance,
                            builder: (context, child) => _ViewerContextCard(
                              document: _document,
                              currentPage: _currentPage + 1,
                              onToggleSaved: () => DocumentRepository.instance
                                  .toggleSaved(document.id),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: SizedBox(
                              width: constraints.maxWidth - 34,
                              height: (constraints.maxWidth - 34) * .562,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: PageView.builder(
                                  controller: _pageController,
                                  itemCount: _viewerPages.length,
                                  onPageChanged: (page) =>
                                      setState(() => _currentPage = page),
                                  itemBuilder: (context, index) => Image.asset(
                                    _viewerPages[index],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (_showAiHint)
                            AiHintBanner(
                              onDismiss: () =>
                                  setState(() => _showAiHint = false),
                            ),
                          const SizedBox(height: 34),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: FilledButton(
                              onPressed: _startDownload,
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFFDFA841),
                                foregroundColor: const Color(0xFF1F2A44),
                                shape: const StadiumBorder(),
                                textStyle: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              child: Text('Tải xuống (${document.size})'),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ViewerHeader extends StatelessWidget {
  const _ViewerHeader({
    required this.document,
    required this.onBack,
    required this.onToggleSaved,
    required this.onOpenLibrary,
  });

  final StudyDocument document;
  final VoidCallback onBack;
  final VoidCallback onToggleSaved;
  final VoidCallback onOpenLibrary;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE9CFA5), Color(0xFFF0E3D3)],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: onBack,
              tooltip: 'Quay lại',
              padding: EdgeInsets.zero,
              icon: SvgPicture.asset(
                'assets/images/documents/viewer_back.svg',
                width: 23,
                height: 23,
              ),
            ),
          ),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Xem tài liệu',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 17,
                  height: 21 / 17,
                  fontWeight: FontWeight.w800,
                  color: AuthColors.navy,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Kho giáo trình & đề thi V-Study',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  height: 13 / 10,
                  fontWeight: FontWeight.w600,
                  color: AuthColors.grayBlue,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: onOpenLibrary,
              tooltip: 'Thư viện tài liệu',
              padding: EdgeInsets.zero,
              icon: SvgPicture.asset(
                'assets/images/documents/library_bookmarks.svg',
                width: 22,
                height: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewerContextCard extends StatelessWidget {
  const _ViewerContextCard({
    required this.document,
    required this.currentPage,
    required this.onToggleSaved,
  });

  final StudyDocument document;
  final int currentPage;
  final VoidCallback onToggleSaved;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAD0A9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const _FormatTag(),
              const SizedBox(width: 5),
              SvgPicture.asset(
                'assets/images/documents/viewer_verified.svg',
                width: 15,
                height: 15,
              ),
              const SizedBox(width: 4),
              const Text(
                'Đã thẩm định',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF825100),
                ),
              ),
              const Spacer(),
              _RoundToolButton(
                tooltip: 'Tìm từ khóa',
                iconAsset: 'assets/images/documents/viewer_search.svg',
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tìm trong tài liệu sẽ sớm khả dụng.'),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              _RoundToolButton(
                tooltip: document.isSaved ? 'Bỏ lưu' : 'Lưu trang',
                iconAsset: 'assets/images/documents/viewer_bookmark.svg',
                fill: const Color(0xFFFFDCC3),
                onPressed: onToggleSaved,
              ),
              const SizedBox(width: 5),
              _RoundToolButton(
                tooltip: 'Chia sẻ tài liệu',
                iconAsset: 'assets/images/documents/viewer_share.svg',
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Chia sẻ tài liệu sẽ sớm khả dụng.'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: Text(
                  document.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    height: 16 / 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFF1EDE6),
                  borderRadius: BorderRadius.all(Radius.circular(99)),
                ),
                child: Text(
                  'Trang ${currentPage.toString().padLeft(2, '0')} / ${document.pages}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _viewerWarmText,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FormatTag extends StatelessWidget {
  const _FormatTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: const BoxDecoration(
        color: Color(0xFFDAE2FD),
        borderRadius: BorderRadius.all(Radius.circular(99)),
      ),
      child: const Text(
        'PDF',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: Color(0xFF131B2E),
        ),
      ),
    );
  }
}

class _RoundToolButton extends StatelessWidget {
  const _RoundToolButton({
    required this.tooltip,
    required this.iconAsset,
    required this.onPressed,
    this.fill = const Color(0xFFF1EDE6),
  });

  final String tooltip;
  final String iconAsset;
  final VoidCallback onPressed;
  final Color fill;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: fill,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox.square(
          dimension: 32,
          child: Center(
            child: SvgPicture.asset(iconAsset, width: 15, height: 15),
          ),
        ),
      ),
    );
  }
}
