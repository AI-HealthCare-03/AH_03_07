// REQ-SHARE-001: 보호자 공유 — 와이어프레임 기반 UI
import 'package:flutter/material.dart';
import '../../../main.dart';
import '../../../services/ocr_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GuardianSharingPage extends StatefulWidget {
  const GuardianSharingPage({super.key});

  @override
  State<GuardianSharingPage> createState() => _GuardianSharingPageState();
}

class _GuardianSharingPageState extends State<GuardianSharingPage> {
  static const _green = Color(0xFF22C55E);
  static const _greenPale = Color(0xFFDCFCE7);

  final _client = http.Client();

  // 공유 항목 상태
  final Map<String, bool> _shareItems = {
    '활성도 기록': true,
    '검사 결과': true,
    '복약 현황': true,
    '주의 증상 알림': true,
    '진료 일정': false,
  };

  // 등록된 보호자 목록 (mock 포함 실서버 연동)
  List<Map<String, dynamic>> _guardians = [];
  bool _guardianLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGuardians();
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  Future<String?> _getToken() => SecureTokenStorage().getAccessToken();

  Future<void> _loadGuardians() async {
    setState(() => _guardianLoading = true);
    try {
      final token = await _getToken();
      if (token == null) {
        _useMock();
        return;
      }
      final resp = await _client
          .get(
            Uri.parse('${OcrConfig.baseUrl}/v1/guardians'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(OcrConfig.timeoutDuration);

      if (!mounted) return;
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        setState(() {
          _guardians =
              List<Map<String, dynamic>>.from(data['items'] ?? []);
          _guardianLoading = false;
        });
      } else {
        _useMock();
      }
    } catch (_) {
      if (mounted) _useMock();
    }
  }

  void _useMock() {
    setState(() {
      _guardians = [
        {
          'id': 1,
          'name': '김영희',
          'relation': '어머니',
          'scope': '전체 공개',
          'avatar_color': 0xFF7C5CCF,
        },
        {
          'id': 2,
          'name': '김철수',
          'relation': '배우자',
          'scope': '일부 공개',
          'avatar_color': 0xFF60A5FA,
        },
      ];
      _guardianLoading = false;
    });
  }

  Future<void> _addGuardian() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const _AddGuardianDialog(),
    );
    if (result == null) return;

    try {
      final token = await _getToken();
      if (token == null) return;

      final resp = await _client
          .post(
            Uri.parse('${OcrConfig.baseUrl}/v1/guardians'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'name': result['name'],
              'relation': result['relation'],
              'contact': result['contact'],
            }),
          )
          .timeout(OcrConfig.timeoutDuration);

      if (!mounted) return;
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        _showSnack('보호자가 등록됐습니다.');
        _loadGuardians();
      } else {
        _showSnack('등록에 실패했습니다.');
      }
    } catch (_) {
      if (mounted) _showSnack('오류가 발생했습니다.');
    } finally {
      if (mounted) setState(() {});
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
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
          '보호자 공유',
          style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 20),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // ── 상단 배너 ──
          _buildBanner(),
          const SizedBox(height: 20),

          // ── 보호자 목록 헤더 ──
          Row(children: [
            const Text('등록된 보호자 ',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87)),
            Text(
              '${_guardians.length}',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _green),
            ),
          ]),
          const SizedBox(height: 10),

          // ── 보호자 카드 목록 ──
          if (_guardianLoading)
            const Center(
                child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: _green),
            ))
          else
            ..._guardians.map((g) => _buildGuardianCard(g)),

          // ── 보호자 추가 버튼 ──
          const SizedBox(height: 8),
          _buildAddButton(),
          const SizedBox(height: 24),

          // ── 공유 항목 설정 ──
          const Text('공유 항목 설정',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
          const SizedBox(height: 10),
          _buildShareItemsCard(),
          const SizedBox(height: 16),

          // ── 안내 문구 ──
          Center(
            child: Text(
              '보호자는 정보 열람만 가능하며\n회원님의 데이터를 수정할 수 없습니다',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _greenPale,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _green.withOpacity(0.3)),
      ),
      child: Row(children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _green.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.monitor_heart_outlined,
              color: _green, size: 20),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '보호자와 건강정보 공유',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 14),
              ),
              SizedBox(height: 2),
              Text(
                '가족이 내 상태를 함께 확인할 수 있어요',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildGuardianCard(Map<String, dynamic> g) {
    final avatarColor = Color(g['avatar_color'] as int? ?? 0xFF7C5CCF);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: avatarColor.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.person_outline, color: avatarColor, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                g['name'] as String? ?? '',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87),
              ),
              Text(
                '${g['relation']} · ${g['scope']}',
                style: TextStyle(
                    fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.settings_outlined,
              color: Colors.grey.shade400, size: 20),
          onPressed: () => _showGuardianSettings(g),
        ),
      ]),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _addGuardian,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _green,
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add, color: _green, size: 18),
              const SizedBox(width: 4),
              const Text(
                '+ 보호자 추가',
                style: TextStyle(
                    color: _green,
                    fontWeight: FontWeight.w600,
                    fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShareItemsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: _shareItems.entries.map((e) {
          final isLast = e.key == _shareItems.keys.last;
          return Column(children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(children: [
                Expanded(
                  child: Text(
                    e.key,
                    style: const TextStyle(
                        fontSize: 15, color: Colors.black87),
                  ),
                ),
                Switch(
                  value: e.value,
                  onChanged: (v) =>
                      setState(() => _shareItems[e.key] = v),
                  activeColor: _green,
                ),
              ]),
            ),
            if (!isLast)
              const Divider(height: 1, indent: 16, endIndent: 16),
          ]);
        }).toList(),
      ),
    );
  }

  void _showGuardianSettings(Map<String, dynamic> g) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${g['name']} 설정',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading:
                  const Icon(Icons.edit_outlined, color: Colors.black87),
              title: const Text('보호자 정보 수정'),
              onTap: () => Navigator.pop(context),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('보호자 삭제',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showSnack('보호자가 삭제됐습니다.');
                setState(() => _guardians
                    .removeWhere((x) => x['id'] == g['id']));
              },
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}

// ── 보호자 추가 다이얼로그 ──────────────────────────────────
class _AddGuardianDialog extends StatefulWidget {
  const _AddGuardianDialog();

  @override
  State<_AddGuardianDialog> createState() => _AddGuardianDialogState();
}

class _AddGuardianDialogState extends State<_AddGuardianDialog> {
  static const _green = Color(0xFF22C55E);
  final _nameCtrl = TextEditingController();
  final _relationCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _relationCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('보호자 추가',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _input(_nameCtrl, '이름', '홍길동'),
          const SizedBox(height: 12),
          _input(_relationCtrl, '관계', '어머니 / 배우자 / 자녀'),
          const SizedBox(height: 12),
          _input(_contactCtrl, '연락처', '010-0000-0000'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소',
              style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameCtrl.text.trim().isEmpty) return;
            Navigator.pop(context, {
              'name': _nameCtrl.text.trim(),
              'relation': _relationCtrl.text.trim(),
              'contact': _contactCtrl.text.trim(),
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _green,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          child: const Text('추가',
              style: TextStyle(color: Colors.white,
                  fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _input(
      TextEditingController ctrl, String label, String hint) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(fontSize: 12, color: Colors.grey)),
      const SizedBox(height: 4),
      TextField(
        controller: ctrl,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFFE0E0E0))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: _green, width: 1.5)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    ]);
  }
}
