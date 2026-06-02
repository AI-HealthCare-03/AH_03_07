// REQ-SYMP-001 복약 체크리스트 — 와이어프레임 기반 UI
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../services/ocr_service.dart';
import '../../../main.dart';
import '../../../login_page.dart';
import '../../../home_page.dart';

class MedicationChecklistPage extends StatefulWidget {
  const MedicationChecklistPage({super.key});

  @override
  State<MedicationChecklistPage> createState() =>
      _MedicationChecklistPageState();
}

class _MedicationChecklistPageState
    extends State<MedicationChecklistPage> {
  static const _green = Color(0xFF22C55E);
  static const _greenPale = Color(0xFFDCFCE7);
  static const _purple = Color(0xFF7C5CCF);
  static const _purplePale = Color(0xFFF0E8FF);

  final _client = http.Client();
  bool _isLoading = true;
  bool _hasError = false;

  // 약품 목록 (그룹: 시간대별)
  List<Map<String, dynamic>> _schedules = [];

  @override
  void initState() {
    super.initState();
    _loadChecklist();
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  Future<String?> _getToken() => SecureTokenStorage().getAccessToken();

  Future<void> _loadChecklist() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final token = await _getToken();
      if (token == null) {
        _useMock();
        return;
      }

      final today = DateTime.now();
      final dateStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final response = await _client
          .get(
            Uri.parse(
                '${OcrConfig.baseUrl}/v1/medication-checklist?date=$dateStr'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(OcrConfig.timeoutDuration);

      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _schedules =
              List<Map<String, dynamic>>.from(data['schedules'] ?? []);
          _isLoading = false;
        });
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        _useMock();
      }
    } catch (_) {
      if (mounted) _useMock();
    }
  }

  void _useMock() {
    setState(() {
      _schedules = [
        {
          'time': '오전 9:00',
          'items': [
            {
              'id': 1,
              'name': '메토트렉세이트 7.5mg',
              'type': '자가면역',
              'dose': '1정',
              'taken': true,
              'taken_at': '복용 09:05',
            },
            {
              'id': 2,
              'name': '폴산 5mg',
              'type': '자가면역',
              'dose': '1정',
              'taken': true,
              'taken_at': '복용 09:05',
            },
          ],
        },
        {
          'time': '오후 13:00',
          'items': [
            {
              'id': 3,
              'name': '아세트아미노펜 500mg',
              'type': '해열·진통',
              'dose': '1정',
              'taken': false,
              'taken_at': null,
            },
          ],
        },
        {
          'time': '오후 18:00',
          'items': [
            {
              'id': 4,
              'name': '아세트아미노펜 500mg',
              'type': '해열·진통',
              'dose': '1정',
              'taken': false,
              'taken_at': null,
            },
          ],
        },
      ];
      _isLoading = false;
    });
  }

  void _handleUnauthorized() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => LoginPage(
          onLoginSuccess: () => Navigator.of(context).pushAndRemoveUntil(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const HomePage(),
              transitionsBuilder: (_, a, __, c) =>
                  FadeTransition(opacity: a, child: c),
              transitionDuration: const Duration(milliseconds: 400),
            ),
            (r) => false,
          ),
        ),
        transitionsBuilder: (_, a, __, c) =>
            FadeTransition(opacity: a, child: c),
        transitionDuration: const Duration(milliseconds: 400),
      ),
      (r) => false,
    );
  }

  Future<void> _markTaken(int id) async {
    final token = await _getToken();
    if (token == null) return;

    // 즉시 UI 반영
    setState(() {
      for (final s in _schedules) {
        for (final item in (s['items'] as List)) {
          if (item['id'] == id) {
            item['taken'] = true;
            final now = DateTime.now();
            item['taken_at'] =
                '복용 ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
          }
        }
      }
    });

    try {
      await _client
          .post(
            Uri.parse(
                '${OcrConfig.baseUrl}/v1/medication-checklist/$id/take'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(OcrConfig.timeoutDuration);
    } catch (_) {
      // 서버 실패 시 UI 복원
      if (mounted) {
        setState(() {
          for (final s in _schedules) {
            for (final item in (s['items'] as List)) {
              if (item['id'] == id) {
                item['taken'] = false;
                item['taken_at'] = null;
              }
            }
          }
        });
      }
    }
  }

  int get _totalCount =>
      _schedules.fold(0, (sum, s) => sum + (s['items'] as List).length);

  int get _takenCount => _schedules.fold(
      0,
      (sum, s) => sum +
          (s['items'] as List)
              .where((i) => i['taken'] == true)
              .length);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final dayStr = weekdays[now.weekday - 1];
    final dateLabel =
        '${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')} ($dayStr)';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F9F4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '복약 체크리스트',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: _green))
          : _hasError
              ? _buildError()
              : RefreshIndicator(
                  color: _green,
                  onRefresh: _loadChecklist,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    children: [
                      // ── 날짜 요약 카드 ──
                      _buildDateCard(dateLabel),
                      const SizedBox(height: 20),

                      // ── 시간대별 리스트 ──
                      for (final s in _schedules) ...[
                        _buildTimeHeader(s['time'] as String),
                        const SizedBox(height: 8),
                        for (final item in (s['items'] as List))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _buildMedCard(
                                Map<String, dynamic>.from(item)),
                          ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildDateCard(String dateLabel) {
    final progress =
        _totalCount > 0 ? _takenCount / _totalCount : 0.0;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateLabel,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text('오늘의 복약 일정',
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500)),
                ],
              ),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('완료',
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade500)),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$_takenCount',
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: _green),
                    ),
                    TextSpan(
                      text: '/$_totalCount',
                      style: TextStyle(
                          fontSize: 16, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            ]),
          ]),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(_green),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeHeader(String time) {
    return Row(children: [
      Text('🕐 ', style: const TextStyle(fontSize: 14)),
      Text(
        time,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _green),
      ),
    ]);
  }

  Widget _buildMedCard(Map<String, dynamic> item) {
    final taken = item['taken'] == true;
    final isAutoimmune = (item['type'] as String?)
            ?.contains('자가면역') ??
        false;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: taken ? _greenPale : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: taken ? _green.withOpacity(0.2) : Colors.grey.shade200,
        ),
      ),
      child: Row(children: [
        // 체크 아이콘
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: taken ? _green : Colors.transparent,
            border: taken
                ? null
                : Border.all(color: Colors.grey.shade300, width: 2),
          ),
          child: taken
              ? const Icon(Icons.check, color: Colors.white, size: 18)
              : null,
        ),
        const SizedBox(width: 12),
        // 약품 정보
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['name'] as String? ?? '',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: taken
                      ? Colors.black54
                      : Colors.black87,
                  decoration:
                      taken ? TextDecoration.lineThrough : null,
                ),
              ),
              const SizedBox(height: 4),
              Row(children: [
                if (isAutoimmune) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _purplePale,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      item['type'] as String? ?? '',
                      style: const TextStyle(
                          fontSize: 11,
                          color: _purple,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  taken
                      ? '${item['dose']} · ${item['taken_at']}'
                      : '${item['dose']}',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600),
                ),
              ]),
            ],
          ),
        ),
        // 복용 버튼 또는 완료 표시
        if (!taken)
          ElevatedButton(
            onPressed: () => _markTaken(item['id'] as int),
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              elevation: 0,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('복용',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
          ),
      ]),
    );
  }

  Widget _buildError() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            const Text('데이터를 불러오지 못했습니다.',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadChecklist,
              style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0),
              child: const Text('다시 시도',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

  Widget _buildBottomNav() => BottomNavigationBar(
        currentIndex: 2,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: _green,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        onTap: (_) {},
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.add_box_outlined), label: '기록'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline), label: '챗봇'),
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: '홈'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined), label: '알림'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: '마이'),
        ],
      );
}
