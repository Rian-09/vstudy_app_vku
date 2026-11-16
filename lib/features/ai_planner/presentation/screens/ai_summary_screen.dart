import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/core/widgets/auth_widgets.dart';
import 'package:flutter_application_1/core/widgets/profile_dialogs.dart';
import 'package:flutter_application_1/features/ai_planner/data/models/ai_models.dart';
import 'package:flutter_application_1/features/ai_planner/presentation/providers/ai_planner_providers.dart';
import 'package:flutter_application_1/features/ai_planner/presentation/widgets/ai_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AiSummaryScreen extends ConsumerStatefulWidget {
  const AiSummaryScreen({super.key, required this.request});
  final AiSummaryRequest request;
  @override
  ConsumerState<AiSummaryScreen> createState() => _AiSummaryScreenState();
}

class _AiSummaryScreenState extends ConsumerState<AiSummaryScreen> {
  int _tab = 0;
  bool _isLoading = true;
  String? _error;
  AiSummaryData? _summary;

  @override
  void initState() {
    super.initState();
    _runSummary();
  }

  Future<void> _runSummary() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final result = await ref
        .read(aiSummaryUseCaseProvider)
        .call(
          title: widget.request.title,
          documentId: widget.request.documentId,
          fileName: widget.request.fileName,
          contentType: widget.request.contentType,
          bytes: widget.request.bytes,
        );
    if (!mounted) return;
    result.match(
      (failure) => setState(() {
        _error = failure.message;
        _isLoading = false;
      }),
      (summary) => setState(() {
        _summary = summary;
        _isLoading = false;
      }),
    );
  }

  Future<void> _showHistory() async {
    final result = await ref.read(aiSummaryHistoryUseCaseProvider).call();
    if (!mounted) return;
    String? error;
    List<AiSummaryData> history = const [];
    result.match(
      (failure) => error = failure.message,
      (items) => history = items,
    );
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error!)));
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(sheetContext).height * .7,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFFF8F4EA),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(18),
                child: Text(
                  'Lịch sử tóm tắt',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: aiNavy,
                  ),
                ),
              ),
              Expanded(
                child: history.isEmpty
                    ? const Center(child: Text('Bạn chưa có bản tóm tắt nào.'))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                        itemCount: history.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = history[index];
                          return ListTile(
                            tileColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              item.content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () {
                              setState(() {
                                _summary = item;
                                _error = null;
                                _isLoading = false;
                                _tab = 0;
                              });
                              Navigator.of(sheetContext).pop();
                            },
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
                                _summary?.title ?? widget.request.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: aiNavy,
                                ),
                              ),
                              Text(
                                _summary == null
                                    ? 'Đang tạo tóm tắt từ nội dung thật'
                                    : 'Đã tạo và lưu vào lịch sử',
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
                  if (_isLoading) ...[
                    _card(
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Column(
                          children: [
                            CircularProgressIndicator(color: aiNavy),
                            SizedBox(height: 14),
                            Text('AI đang đọc tài liệu và tạo tóm tắt...'),
                          ],
                        ),
                      ),
                    ),
                  ] else if (_error != null) ...[
                    _card(
                      child: Column(
                        children: [
                          Text(_error!, textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: _runSummary,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    ),
                  ] else if (_tab == 0 || _tab == 1) ...[
                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _tab == 0
                                      ? 'Tóm tắt nội dung'
                                      : 'Nội dung chi tiết',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: aiNavy,
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Sao chép',
                                onPressed: _summary == null
                                    ? null
                                    : () async {
                                        final messenger = ScaffoldMessenger.of(
                                          context,
                                        );
                                        await Clipboard.setData(
                                          ClipboardData(
                                            text: _summary!.content,
                                          ),
                                        );
                                        if (mounted) {
                                          messenger.showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Đã sao chép tóm tắt.',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                icon: const Icon(Icons.copy, size: 18),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SelectableText(
                            _summary?.content ?? '',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              height: 1.55,
                              color: aiNavy,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    _card(
                      child: const Text(
                        'Sơ đồ tư duy chưa được tạo cho bản tóm tắt này.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  if (!_isLoading && _error == null && _summary != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: _showHistory,
                        icon: const Icon(Icons.history),
                        label: const Text('Lịch sử tóm tắt'),
                      ),
                    ),
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
}
