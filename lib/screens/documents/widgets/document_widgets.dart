import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../models/document.dart';
import '../../../theme/auth_theme.dart';

const _gold = Color(0xFFDFA841);
const _darkNavy = Color(0xFF1E2A4A);
const _cream = Color(0xFFF6EBC4);
const _warmText = Color(0xFF554336);
const _docAsset = 'assets/images/documents/';

class DocSearchBar extends StatelessWidget {
  const DocSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 39,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _gold),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x5EDFA841),
            offset: Offset(2, 2),
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          SvgPicture.asset('${_docAsset}search.svg', width: 18, height: 18),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: AuthColors.navy,
              ),
              decoration: const InputDecoration(
                hintText: 'Tìm giáo trình, slide, tài liệu ôn tập,...',
                hintStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: Color(0x7A8A93AA),
                ),
                isCollapsed: true,
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            onPressed: () => onChanged(controller.text),
            tooltip: 'Tìm kiếm bằng giọng nói',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 36, height: 36),
            icon: SvgPicture.asset(
              '${_docAsset}microphone.svg',
              width: 15,
              height: 15,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class StudyPromptCard extends StatelessWidget {
  const StudyPromptCard({super.key, required this.onChoose});

  final VoidCallback onChoose;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 131,
      padding: const EdgeInsets.fromLTRB(20, 17, 16, 13),
      decoration: BoxDecoration(
        color: _darkNavy,
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
                  fontSize: 18,
                  height: 23 / 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Chọn tài liệu và để AI giúp bạn ôn nhanh hơn.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  height: 14 / 10,
                  color: Color(0xFFDCDFe9),
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 29,
                child: FilledButton(
                  onPressed: onChoose,
                  style: FilledButton.styleFrom(
                    backgroundColor: _gold,
                    foregroundColor: _darkNavy,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Chọn tài liệu'),
                ),
              ),
            ],
          ),
          Positioned(
            right: 3,
            top: 16,
            child: SvgPicture.asset(
              '${_docAsset}study_sparkle.svg',
              width: 42,
              height: 42,
            ),
          ),
        ],
      ),
    );
  }
}

class FilterTabs extends StatelessWidget {
  const FilterTabs({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFE7D2BD),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          for (var index = 0; index < items.length; index++)
            Expanded(
              child: Material(
                color: index == selectedIndex
                    ? Colors.white
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: () => onSelected(index),
                  borderRadius: BorderRadius.circular(20),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Text(
                        items[index],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: index == selectedIndex
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: index == selectedIndex
                              ? AuthColors.navy
                              : const Color(0xB31F2A44),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SubjectChips extends StatelessWidget {
  const SubjectChips({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(width: 5),
        itemBuilder: (context, index) {
          final selected = index == selectedIndex;
          return Material(
            color: selected ? _gold : Colors.white,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: () => onSelected(index),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: selected ? null : Border.all(color: _gold),
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  items[index],
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? _darkNavy : const Color(0xB31F2A44),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class DocCard extends StatelessWidget {
  const DocCard({
    super.key,
    required this.document,
    required this.onOpen,
    required this.onDownload,
    required this.onToggleSaved,
  });

  final StudyDocument document;
  final VoidCallback onOpen;
  final VoidCallback onDownload;
  final VoidCallback onToggleSaved;

  @override
  Widget build(BuildContext context) {
    final isExam = document.category == DocumentCategory.exam;
    return SizedBox(
      width: 178,
      height: 202,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onOpen,
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 25, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Image.asset(
                        document.thumbnail,
                        width: double.infinity,
                        height: 81,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      document.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 9,
                        height: 12 / 9,
                        fontWeight: FontWeight.w700,
                        color: AuthColors.navy,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${document.pages} trang • ${document.downloads} lượt tải',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 7,
                        color: AuthColors.muted,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 27,
                      child: FilledButton(
                        onPressed: onDownload,
                        style: FilledButton.styleFrom(
                          backgroundColor: _gold,
                          foregroundColor: _darkNavy,
                          padding: EdgeInsets.zero,
                          shape: const StadiumBorder(),
                          textStyle: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('Tải xuống ⊙'),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                child: _TypeBadge(label: document.type, isExam: isExam),
              ),
              Positioned(
                right: 5,
                top: 3,
                child: Material(
                  color: const Color(0x3DDFA841),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(14),
                    topRight: Radius.circular(18),
                  ),
                  child: InkWell(
                    onTap: onToggleSaved,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(14),
                      topRight: Radius.circular(18),
                    ),
                    child: SizedBox(
                      width: 31,
                      height: 23,
                      child: Center(
                        child: SvgPicture.asset(
                          '${_docAsset}bookmark.svg',
                          width: 13,
                          height: 15,
                          colorFilter: document.isSaved
                              ? const ColorFilter.mode(_gold, BlendMode.srcIn)
                              : null,
                        ),
                      ),
                    ),
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

class DocListTile extends StatelessWidget {
  const DocListTile({
    super.key,
    required this.document,
    required this.onOpen,
    required this.onDownload,
    required this.onToggleSaved,
  });

  final StudyDocument document;
  final VoidCallback onOpen;
  final VoidCallback onDownload;
  final VoidCallback onToggleSaved;

  @override
  Widget build(BuildContext context) {
    final isExam = document.category == DocumentCategory.exam;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          height: 142,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(9, 15, 9, 8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _TypeBadge(label: document.type, isExam: isExam),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            document.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              height: 13 / 10,
                              fontWeight: FontWeight.w700,
                              color: AuthColors.text,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: onToggleSaved,
                          tooltip: document.isSaved
                              ? 'Bỏ lưu tài liệu'
                              : 'Lưu tài liệu',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints.tightFor(
                            width: 28,
                            height: 28,
                          ),
                          icon: SvgPicture.asset(
                            '${_docAsset}bookmark.svg',
                            width: 12,
                            height: 14,
                            colorFilter: document.isSaved
                                ? const ColorFilter.mode(_gold, BlendMode.srcIn)
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${document.pages} trang    ${document.downloads} lượt tải    ${document.size}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 8,
                          color: AuthColors.muted,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${document.updatedAt}   4.9 ★',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 8,
                              color: AuthColors.grayBlue,
                            ),
                          ),
                        ),
                        _SmallActionButton(
                          label: 'Xem ngay',
                          onPressed: onOpen,
                          filled: false,
                        ),
                        const SizedBox(width: 6),
                        _SmallActionButton(
                          label: 'Tải',
                          onPressed: onDownload,
                          filled: true,
                        ),
                      ],
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

class AiHintBanner extends StatelessWidget {
  const AiHintBanner({super.key, required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
      decoration: BoxDecoration(
        color: const Color(0xEFFFFFFF),
        border: Border.all(color: const Color(0xFFF3DFC1)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x20DFA841),
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          SvgPicture.asset('${_docAsset}library_ai.svg', width: 33, height: 33),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GỢI Ý TỪ V-STUDY AI',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFD97706),
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Bạn có 3 đề thi chưa hoàn thành mục tiêu tuần này. Tiếp tục luyện ngay?',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    height: 14 / 10,
                    color: Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDismiss,
            tooltip: 'Đóng gợi ý',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 26, height: 26),
            icon: const Icon(Icons.close, size: 15, color: AuthColors.grayBlue),
          ),
        ],
      ),
    );
  }
}

class DownloadSheet extends StatefulWidget {
  const DownloadSheet({super.key, required this.document});

  final StudyDocument document;

  @override
  State<DownloadSheet> createState() => _DownloadSheetState();
}

class _DownloadSheetState extends State<DownloadSheet> {
  static const _formats = [
    (
      'Bản PDF chuẩn',
      '43 MB',
      'Chất lượng cao, đầy đủ sơ đồ, hình ảnh & công thức trích dẫn chuẩn V-Study',
    ),
    (
      'Bản nén',
      '8.2 MB',
      'Tối ưu đọc mượt trên thiết bị di động, tải siêu tốc qua mạng 5G',
    ),
    (
      'Bản tóm tắt cốt lõi của AI',
      '2.1 MB',
      '15 trang Mindmap học nhanh & 80 câu trắc nghiệm trọng tâm',
    ),
  ];

  int _selectedFormat = 0;
  bool _includeNotes = true;
  bool _saveOffline = true;
  bool _isDownloading = false;
  double _progress = 0;
  Timer? _timer;

  void _startDownload() {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);
    const ticks = 20;
    var tick = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      tick++;
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _progress = tick / ticks);
      if (tick >= ticks) {
        timer.cancel();
        Navigator.of(context).pop(true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.94,
      padding: EdgeInsets.fromLTRB(27, 38, 27, 18 + bottomPadding),
      decoration: const BoxDecoration(
        color: Color(0xFFF9F7F2),
        borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
        boxShadow: [
          BoxShadow(color: _gold, blurRadius: 4, offset: Offset(0, -5)),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 58,
                        height: 47,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFDAD6),
                          border: Border.all(color: const Color(0xFFD64545)),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: SvgPicture.asset('${_docAsset}sheet_pdf.svg'),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Tải tài liệu về máy',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1C1C17),
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.verified,
                                  size: 17,
                                  color: _darkNavy,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${widget.document.title}.pdf',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                height: 17 / 14,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${_formats[_selectedFormat].$2}  •  ${widget.document.pages} trang',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _darkNavy,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  const Text(
                    'Định dạng & Dung lượng',
                    style: _SheetStyles.section,
                  ),
                  const SizedBox(height: 14),
                  for (var index = 0; index < _formats.length; index++) ...[
                    if (index > 0) const SizedBox(height: 12),
                    _DownloadOption(
                      title: _formats[index].$1,
                      size: _formats[index].$2,
                      detail: _formats[index].$3,
                      selected: _selectedFormat == index,
                      onTap: () => setState(() => _selectedFormat = index),
                    ),
                  ],
                  const SizedBox(height: 18),
                  const Text('Tùy chọn bổ sung', style: _SheetStyles.section),
                  const SizedBox(height: 10),
                  _AdditionalOption(
                    value: _includeNotes,
                    label: 'Tải kèm lời giải chi tiết & ghi chú đầy đủ các nội dung',
                    onChanged: (value) => setState(() => _includeNotes = value),
                  ),
                  _AdditionalOption(
                    value: _saveOffline,
                    label: "Lưu vào thư mục 'Tài liệu ôn thi' offline",
                    onChanged: (value) => setState(() => _saveOffline = value),
                  ),
                  const Spacer(),
                  if (_isDownloading) ...[
                    LinearProgressIndicator(
                      value: _progress,
                      minHeight: 4,
                      color: _gold,
                      backgroundColor: const Color(0xFFECE8E0),
                    ),
                    const SizedBox(height: 10),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: FilledButton.icon(
                      onPressed: _isDownloading ? null : _startDownload,
                      icon: SvgPicture.asset(
                        '${_docAsset}sheet_download.svg',
                        width: 15,
                        height: 15,
                      ),
                      label: Text(
                        _isDownloading
                            ? 'Đang tải ${(100 * _progress).round()}%'
                            : 'Xác nhận tải về (${_formats[_selectedFormat].$2})',
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: _gold,
                        foregroundColor: _darkNavy,
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: TextButton(
                      onPressed: _isDownloading
                          ? null
                          : () => Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFF1EDE6),
                        foregroundColor: _warmText,
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Hủy bỏ'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DownloadSuccessPopup extends StatelessWidget {
  const DownloadSuccessPopup({
    super.key,
    required this.document,
    required this.onViewNow,
    required this.onSaveToLibrary,
    required this.onClose,
  });

  final StudyDocument document;
  final VoidCallback onViewNow;
  final VoidCallback onSaveToLibrary;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      alignment: Alignment.bottomCenter,
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: 564,
        padding: const EdgeInsets.fromLTRB(45, 50, 45, 36),
        decoration: const BoxDecoration(
          color: Color(0xFFF9F7F2),
          borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
          boxShadow: [
            BoxShadow(color: _gold, blurRadius: 4, offset: Offset(0, -5)),
          ],
        ),
        child: Column(
          children: [
            SvgPicture.asset(
              '${_docAsset}success_check.svg',
              width: 74,
              height: 74,
            ),
            const SizedBox(height: 16),
            const Text(
              'Tải xuống thành công',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 23,
                height: 29 / 23,
                fontWeight: FontWeight.w600,
                color: AuthColors.navy,
              ),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(color: Color(0xFFF7F3EB)),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 48,
                    padding: const EdgeInsets.all(7),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFDAD6),
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset('${_docAsset}success_pdf.svg'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          document.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AuthColors.navy,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${document.size} • ${document.pages} trang',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: _gold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            _SuccessActionButton(
              icon: '${_docAsset}success_open.svg',
              label: 'Xem tài liệu ngay',
              color: AuthColors.navy,
              foreground: Colors.white,
              onPressed: onViewNow,
            ),
            const SizedBox(height: 14),
            _SuccessActionButton(
              icon: '${_docAsset}success_bookmark.svg',
              label: 'Lưu vào Thư viện yêu thích',
              color: const Color(0xFFECE8E0),
              foreground: AuthColors.navy,
              onPressed: onSaveToLibrary,
            ),
            TextButton(
              onPressed: onClose,
              style: TextButton.styleFrom(foregroundColor: _gold),
              child: const Text('Đóng'),
            ),
          ],
        ),
      ),
    );
  }
}

class DownloadProgressTile extends StatelessWidget {
  const DownloadProgressTile({
    super.key,
    required this.document,
    required this.onOpen,
    required this.onContinue,
  });

  final StudyDocument document;
  final VoidCallback onOpen;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(11, 9, 11, 9),
          child: Column(
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      document.thumbnail,
                      width: 56,
                      height: 52,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          document.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            height: 13 / 10,
                            fontWeight: FontWeight.w700,
                            color: AuthColors.navy,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${document.pages} trang • ${document.size}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 8,
                            color: AuthColors.grayBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: document.progress,
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(6),
                      color: _gold,
                      backgroundColor: const Color(0xFFB7B7B7),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${(document.progress * 100).round()}%',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 8,
                      color: AuthColors.grayBlue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _SmallActionButton(
                    label: document.isDownloaded ? 'Đọc tiếp' : 'Đọc tiếp',
                    onPressed: onContinue,
                    filled: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DownloadOption extends StatelessWidget {
  const _DownloadOption({
    required this.title,
    required this.size,
    required this.detail,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String size;
  final String detail;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? _cream : const Color(0xFFF7F6F2),
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: SizedBox(
          height: 87,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 10, 9, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  selected
                      ? '${_docAsset}sheet_radio_selected.svg'
                      : '${_docAsset}sheet_radio.svg',
                  width: 21,
                  height: 21,
                ),
                const SizedBox(width: 8),
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
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        detail,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          height: 15 / 10,
                          color: _warmText,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: const BoxDecoration(
                    color: _darkNavy,
                    borderRadius: BorderRadius.all(Radius.circular(99)),
                  ),
                  child: Text(
                    size,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdditionalOption extends StatelessWidget {
  const _AdditionalOption({
    required this.value,
    required this.label,
    required this.onChanged,
  });

  final bool value;
  final String label;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: SizedBox(
        height: 55,
        child: Row(
          children: [
            SvgPicture.asset(
              '${_docAsset}sheet_check.svg',
              width: 21,
              height: 21,
              colorFilter: value
                  ? null
                  : const ColorFilter.mode(Color(0xFFE8E3DA), BlendMode.srcIn),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  height: 16 / 12,
                  color: Color(0xFF1C1C17),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessActionButton extends StatelessWidget {
  const _SuccessActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.foreground,
    required this.onPressed,
  });

  final String icon;
  final String label;
  final Color color;
  final Color foreground;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: SvgPicture.asset(
          icon,
          width: 18,
          height: 16,
          colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
        ),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: foreground,
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  const _SmallActionButton({
    required this.label,
    required this.onPressed,
    required this.filled,
  });

  final String label;
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 23,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: filled
              ? _gold
              : const Color(0xFFC8CFDF).withValues(alpha: .44),
          foregroundColor: _darkNavy,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.label, required this.isExam});

  final String label;
  final bool isExam;

  @override
  Widget build(BuildContext context) {
    final color = isExam ? const Color(0xFFD64545) : _gold;
    return Container(
      constraints: const BoxConstraints(minWidth: 38),
      height: 25,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .19),
        border: Border.all(color: color.withValues(alpha: .55)),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          bottomRight: Radius.circular(16),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label == 'Báo cáo' ? 'Báo cáo' : label.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 8,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

abstract final class _SheetStyles {
  static const section = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );
}
