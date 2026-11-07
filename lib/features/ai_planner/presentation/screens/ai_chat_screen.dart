import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_application_1/features/ai_planner/data/models/ai_models.dart';
import 'package:flutter_application_1/features/ai_planner/data/datasources/ai_service.dart';
import 'package:flutter_application_1/core/theme/auth_theme.dart';
import 'package:flutter_application_1/core/widgets/auth_widgets.dart';
import 'package:flutter_application_1/features/ai_planner/presentation/widgets/ai_widgets.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});
  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _controller = TextEditingController();
  final _service = AiService.instance;
  final _scrollController = ScrollController();
  bool _typing = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send([String? preset]) async {
    final text = (preset ?? _controller.text).trim();
    if (text.isEmpty || _typing) return;
    _controller.clear();
    setState(() {
      _service.chat.add(AiChatMessage(text: text, fromUser: true));
      _typing = true;
    });
    _scrollToBottom();
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    setState(() {
      _service.chat.add(
        AiChatMessage(
          text: _service.replyFor(_service.chat.length),
          fromUser: false,
        ),
      );
      _typing = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => AuthBackground(
    child: SafeArea(
      child: Column(
        children: [
          const AiScreenHeader(
            title: 'Hỏi đáp tài liệu',
            subtitle: 'Giải tích 1 · Chương 3.pdf',
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(20, 10, 20, 8),
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const AiDocFormatIcon(format: 'PDF'),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Giải tích 1 · Chương 3',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: aiNavy,
                        ),
                      ),
                      Text(
                        '48 trang · đã phân tích xong',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          color: Color(0xFF8A93AA),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed<void>('/pick-documents'),
                  child: const Text(
                    'Đổi',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFC3911B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              children: [
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 14),
                    child: Text(
                      'Hôm nay',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        color: Color(0xFF8A93AA),
                      ),
                    ),
                  ),
                ),
                for (final message in _service.chat)
                  ChatBubble(message: message),
                if (_typing)
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'AI đang trả lời...',
                        style: AuthTextStyles.caption,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            height: 43,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              scrollDirection: Axis.horizontal,
              children: [
                SuggestionChip(
                  label: 'Cho ví dụ',
                  onTap: () => _send('Cho mình ví dụ với f(x) = x²'),
                ),
                const SizedBox(width: 7),
                SuggestionChip(
                  label: 'Tạo 5 câu hỏi',
                  onTap: () => _send('Tạo 5 câu hỏi về chương này'),
                ),
                const SizedBox(width: 7),
                SuggestionChip(
                  label: 'Tóm tắt chương',
                  onTap: () =>
                      Navigator.of(context).pushNamed<void>('/pick-documents'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 6, 14, 18),
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFE7E3D8)),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () =>
                        Navigator.of(context)
                            .pushNamed<void>('/pick-documents'),
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: aiNavy,
                      size: 24,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _send(),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: aiNavy,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Hỏi AI bất cứ điều gì...',
                        hintStyle: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: Color(0xFF8A93AA),
                        ),
                        border: InputBorder.none,
                        isCollapsed: true,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _typing ? null : _send,
                    icon: const Icon(
                      Icons.arrow_upward,
                      color: Colors.white,
                      size: 21,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFC9A227),
                      fixedSize: const Size(40, 40),
                    ),
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
