// REQ-CHAT-006 : 챗봇 응답 평가 (+1 / -1) 위젯
// API: POST /api/v1/chat/messages/{id}/feedback
//      Request  : { score: 1 | -1, comment: String? }
//      Response : 200 { ... }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ───────────────────────────────────────────
// 1) API 서비스
// ───────────────────────────────────────────
class ChatFeedbackService {
  final String baseUrl;
  final String accessToken;

  const ChatFeedbackService({
    required this.baseUrl,
    required this.accessToken,
  });

  Future<void> submitFeedback({
    required String messageId,
    required int score, // 1 or -1
    String? comment,
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/chat/messages/$messageId/feedback');
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'score': score,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('피드백 전송 실패: ${response.statusCode}');
    }
  }
}

// ───────────────────────────────────────────
// 2) 평가 위젯
// ───────────────────────────────────────────
class ChatFeedbackWidget extends StatefulWidget {
  final String messageId;
  final ChatFeedbackService service;

  const ChatFeedbackWidget({
    super.key,
    required this.messageId,
    required this.service,
  });

  @override
  State<ChatFeedbackWidget> createState() => _ChatFeedbackWidgetState();
}

class _ChatFeedbackWidgetState extends State<ChatFeedbackWidget> {
  int? _selectedScore;   // 1 or -1, null이면 미선택
  bool _showComment = false;
  bool _submitted = false;
  bool _loading = false;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _onTapScore(int score) async {
    if (_submitted) return;

    setState(() {
      _selectedScore = score;
      // 👎 누르면 코멘트 입력창 표시
      _showComment = score == -1;
    });

    // 👍는 코멘트 없이 바로 전송
    if (score == 1) {
      await _submit();
    }
  }

  Future<void> _submit() async {
    if (_selectedScore == null || _loading) return;

    setState(() => _loading = true);

    try {
      await widget.service.submitFeedback(
        messageId: widget.messageId,
        score: _selectedScore!,
        comment: _commentController.text,
      );
      setState(() {
        _submitted = true;
        _showComment = false;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('피드백 전송에 실패했습니다. 다시 시도해주세요.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 제출 완료 상태
    if (_submitted) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Text(
          '피드백이 반영되었습니다. 감사합니다!',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 👍 / 👎 버튼 행
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _FeedbackButton(
              icon: '👍',
              label: '도움됐어요',
              selected: _selectedScore == 1,
              onTap: () => _onTapScore(1),
            ),
            const SizedBox(width: 8),
            _FeedbackButton(
              icon: '👎',
              label: '별로예요',
              selected: _selectedScore == -1,
              onTap: () => _onTapScore(-1),
            ),
          ],
        ),

        // 👎 선택 시 코멘트 입력창
        if (_showComment) ...[
          const SizedBox(height: 8),
          TextField(
            controller: _commentController,
            maxLength: 500,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: '어떤 점이 아쉬웠나요? (선택)',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('제출'),
            ),
          ),
        ],
      ],
    );
  }
}

// ───────────────────────────────────────────
// 3) 버튼 컴포넌트
// ───────────────────────────────────────────
class _FeedbackButton extends StatelessWidget {
  final String icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FeedbackButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.transparent,
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade400,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade600,
                fontWeight:
                    selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────
// 4) 사용 예시
// ───────────────────────────────────────────
//
// ChatFeedbackWidget(
//   messageId: 'msg-uuid-1234',
//   service: ChatFeedbackService(
//     baseUrl: 'https://api.yourserver.com',
//     accessToken: userAccessToken,
//   ),
// )
