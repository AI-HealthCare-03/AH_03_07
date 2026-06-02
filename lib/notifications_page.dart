import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'services/ocr_service.dart';
import 'main.dart';
import 'login_page.dart';
import 'home_page.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _isLoading = true;
  bool _hasError = false;
  List<Map<String, dynamic>> _notifications = [];
  final _client = http.Client();

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  Future<String?> _getToken() async {
    return SecureTokenStorage().getAccessToken();
  }

  Future<void> _loadNotifications() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final token = await _getToken();
      if (token == null) throw Exception('토큰 없음');

      final response = await _client.get(
        Uri.parse('${OcrConfig.baseUrl}/v1/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(OcrConfig.timeoutDuration);

      if (!mounted) return;

     if (response.statusCode == 200) {
  final data = jsonDecode(response.body);
  setState(() {
    _notifications = (data['items'] as List).cast<Map<String, dynamic>>();
    _isLoading = false;
  });
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _handleUnauthorized() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => LoginPage(
          onLoginSuccess: () {
            Navigator.of(context).pushAndRemoveUntil(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const HomePage(),
                transitionsBuilder: (_, anim, __, child) =>
                    FadeTransition(opacity: anim, child: child),
                transitionDuration: const Duration(milliseconds: 400),
              ),
              (route) => false,
            );
          },
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
      (route) => false,
    );
  }

  Future<void> _markAsRead(int id, int index) async {
    // 낙관적 업데이트
    setState(() => _notifications[index]['is_read'] = true);

    try {
      final token = await _getToken();
      if (token == null) return;

      await _client.put(
        Uri.parse('${OcrConfig.baseUrl}/v1/notifications/$id/read'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(OcrConfig.timeoutDuration);
    } catch (_) {
      // 실패 시 롤백
      if (!mounted) return;
      setState(() => _notifications[index]['is_read'] = false);
    }
  }

  Future<void> _markAllAsRead() async {
    final unreadIndices = <int>[];
    for (int i = 0; i < _notifications.length; i++) {
      if (_notifications[i]['is_read'] == false) {
        unreadIndices.add(i);
      }
    }
    if (unreadIndices.isEmpty) return;

    for (final i in unreadIndices) {
      final id = _notifications[i]['id'] as int?;
      if (id != null) await _markAsRead(id, i);
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays == 0) {
        return DateFormat('HH:mm').format(date);
      } else if (diff.inDays == 1) {
        return '어제 ${DateFormat('HH:mm').format(date)}';
      } else {
        return DateFormat('MM월 dd일').format(date);
      }
    } catch (_) {
      return '';
    }
  }

  int get _unreadCount =>
      _notifications.where((n) => n['is_read'] == false).length;

  // 오늘/어제/이전 그룹 분류 (내부 사용 예약)
  // ignore: unused_element
  Map<String, List<Map<String, dynamic>>> get _grouped {
    final now = DateTime.now();
    final todayKey = '오늘';
    final yesterdayKey = '어제';
    final olderKey = '이전';
    final result = <String, List<Map<String, dynamic>>>{};

    for (final n in _notifications) {
      final createdAt = n['created_at'] as String?;
      String group = olderKey;
      if (createdAt != null) {
        try {
          final date = DateTime.parse(createdAt).toLocal();
          final diff = now.difference(date);
          if (diff.inDays == 0) { group = todayKey; }
          else if (diff.inDays == 1) { group = yesterdayKey; }
        } catch (_) {}
      }
      result.putIfAbsent(group, () => []).add(n);
    }
    return result;
  }

  // mock 데이터 없을 때 UI 테스트용
  List<Map<String, dynamic>> get _displayNotifications =>
      _notifications.isNotEmpty
          ? _notifications
          : [
              {
                'id': 1,
                'title': '복약 시간',
                'body': '아침약을 복용해주세요',
                'notification_type': 'medication',
                'is_read': false,
                'created_at': DateTime.now()
                    .subtract(const Duration(hours: 1))
                    .toIso8601String(),
                'time_label': '09:00',
              },
              {
                'id': 2,
                'title': '의료진 확인 신호',
                'body': '통증 점수 패턴 감지',
                'notification_type': 'risk',
                'is_read': false,
                'created_at': DateTime.now()
                    .subtract(const Duration(hours: 3))
                    .toIso8601String(),
                'time_label': '07:00',
              },
              {
                'id': 3,
                'title': '활성도 기록',
                'body': '오늘 컨디션을 기록해주세요',
                'notification_type': 'activity',
                'is_read': true,
                'created_at': DateTime.now()
                    .subtract(const Duration(days: 1, hours: 3))
                    .toIso8601String(),
                'time_label': '21:00',
              },
              {
                'id': 4,
                'title': '약 복용 완료',
                'body': '저녁약 복용 완료',
                'notification_type': 'done',
                'is_read': true,
                'created_at': DateTime.now()
                    .subtract(const Duration(days: 1, hours: 4, minutes: 30))
                    .toIso8601String(),
                'time_label': '19:30',
              },
            ];

  @override
  Widget build(BuildContext context) {
    final source = _isLoading ? <Map<String, dynamic>>[] : _displayNotifications;

    // 그룹 분류
    final now = DateTime.now();
    final todayItems = <Map<String, dynamic>>[];
    final yesterdayItems = <Map<String, dynamic>>[];
    final olderItems = <Map<String, dynamic>>[];

    for (final n in source) {
      final createdAt = n['created_at'] as String?;
      int daysDiff = 99;
      if (createdAt != null) {
        try {
          final date = DateTime.parse(createdAt).toLocal();
          daysDiff = now.difference(date).inDays;
        } catch (_) {}
      }
      if (daysDiff == 0) {
        todayItems.add(n);
      } else if (daysDiff == 1) {
        yesterdayItems.add(n);
      } else {
        olderItems.add(n);
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F9F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F9F4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Colors.black87, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('모두 읽음',
                  style: TextStyle(color: Color(0xFF22C55E), fontSize: 13)),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF22C55E)))
          : _hasError
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  color: const Color(0xFF22C55E),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    children: [
                      // 큰 타이틀
                      const Text('알림',
                          style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87)),
                      const SizedBox(height: 20),

                      if (todayItems.isEmpty && yesterdayItems.isEmpty && olderItems.isEmpty)
                        _buildEmpty()
                      else ...[
                        if (todayItems.isNotEmpty) ...[
                          _groupHeader('오늘'),
                          const SizedBox(height: 8),
                          ...todayItems.asMap().entries.map(
                              (e) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _buildCard(e.value, _notifications.indexOf(e.value)),
                              )),
                        ],
                        if (yesterdayItems.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _groupHeader('어제'),
                          const SizedBox(height: 8),
                          ...yesterdayItems.asMap().entries.map(
                              (e) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _buildCard(e.value, _notifications.indexOf(e.value)),
                              )),
                        ],
                        if (olderItems.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _groupHeader('이전'),
                          const SizedBox(height: 8),
                          ...olderItems.asMap().entries.map(
                              (e) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _buildCard(e.value, _notifications.indexOf(e.value)),
                              )),
                        ],
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _groupHeader(String label) => Text(label,
      style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black87));

  Widget _buildCard(Map<String, dynamic> n, int index) {
    final id = n['id'] as int? ?? 0;
    final title = n['title'] as String? ?? '';
    final body = n['body'] as String? ?? '';
    final type = n['notification_type'] as String?;
    final isRead = n['is_read'] as bool? ?? true;
    final createdAt = n['created_at'] as String?;
    final timeLabel = n['time_label'] as String? ?? _formatDate(createdAt);

    final isRisk = type == 'risk';
    final isDone = type == 'done';

    return GestureDetector(
      onTap: () {
        if (!isRead && index >= 0 && index < _notifications.length) {
          _markAsRead(id, index);
        }
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isRisk
              ? Border.all(color: const Color(0xFFF59E0B), width: 1.5)
              : Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // 아이콘
              SizedBox(
                width: 36,
                child: Text(
                  _getNotificationEmoji(type),
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 10),
              // 내용
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: isRead
                                ? FontWeight.normal
                                : FontWeight.bold,
                            color: Colors.black87)),
                    if (body.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(body,
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600)),
                    ],
                  ],
                ),
              ),
              // 읽지 않음 빨간 점
              if (!isRead)
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                ),
              if (isDone)
                const Icon(Icons.check, color: Color(0xFF22C55E), size: 20),
            ]),
            // 시간 오른쪽 정렬
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                timeLabel,
                style: TextStyle(
                    fontSize: 12, color: Colors.grey.shade400),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getNotificationEmoji(String? type) {
    switch (type) {
      case 'medication': return '💊';
      case 'risk': return '⚠️';
      case 'activity': return '📊';
      case 'done': return '✅';
      case 'guide': return '📋';
      default: return '🔔';
    }
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('알림을 불러오지 못했습니다.',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadNotifications,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF22C55E),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('다시 시도',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('알림이 없습니다.',
              style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

}