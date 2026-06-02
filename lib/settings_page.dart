// 설정 페이지 — 와이어프레임 기반 UI
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsPage extends StatefulWidget {
  final VoidCallback? onLogout;
  const SettingsPage({super.key, this.onLogout});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const _green = Color(0xFF22C55E);
  static const _bg = Color(0xFFF4F9F4);
  static const _cardBg = Colors.white;

  final _storage = const FlutterSecureStorage();

  // 알림 설정
  bool _medAlert = true;
  bool _guideAlert = true;
  bool _marketingAlert = false;

  // 알림 채널
  bool _appAlert = true;
  bool _emailAlert = false;
  bool _kakaoAlert = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final med = await _storage.read(key: 'pref_med_alert');
    final guide = await _storage.read(key: 'pref_guide_alert');
    final marketing = await _storage.read(key: 'pref_marketing_alert');
    final app = await _storage.read(key: 'pref_app_channel');
    final email = await _storage.read(key: 'pref_email_channel');
    final kakao = await _storage.read(key: 'pref_kakao_channel');
    if (!mounted) return;
    setState(() {
      _medAlert = med != 'false';
      _guideAlert = guide != 'false';
      _marketingAlert = marketing == 'true';
      _appAlert = app != 'false';
      _emailAlert = email == 'true';
      _kakaoAlert = kakao != 'false';
    });
  }

  Future<void> _save(String key, bool value) async {
    await _storage.write(key: key, value: value.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '설정',
          style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 20),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          // ── 알림 설정 ──
          _sectionLabel('알림 설정'),
          const SizedBox(height: 8),
          _card([
            _toggleRow('복약 알림', _medAlert, (v) {
              setState(() => _medAlert = v);
              _save('pref_med_alert', v);
            }),
            _divider(),
            _toggleRow('가이드 확인 알림', _guideAlert, (v) {
              setState(() => _guideAlert = v);
              _save('pref_guide_alert', v);
            }),
            _divider(),
            _toggleRow('마케팅 알림', _marketingAlert, (v) {
              setState(() => _marketingAlert = v);
              _save('pref_marketing_alert', v);
            }),
          ]),
          const SizedBox(height: 20),

          // ── 알림 채널 ──
          _sectionLabel('알림 채널'),
          const SizedBox(height: 8),
          _card([
            _toggleRow('앱 알림', _appAlert, (v) {
              setState(() => _appAlert = v);
              _save('pref_app_channel', v);
            }),
            _divider(),
            _toggleRow('이메일', _emailAlert, (v) {
              setState(() => _emailAlert = v);
              _save('pref_email_channel', v);
            }),
            _divider(),
            _toggleRow('카카오톡', _kakaoAlert, (v) {
              setState(() => _kakaoAlert = v);
              _save('pref_kakao_channel', v);
            }),
          ]),
          const SizedBox(height: 20),

          // ── 계정 ──
          _sectionLabel('계정'),
          const SizedBox(height: 8),
          _card([
            _navRow('비밀번호 변경', onTap: () => _showSnack('준비 중입니다.')),
            _divider(),
            _navRow('회원 정보 수정', onTap: () => _showSnack('준비 중입니다.')),
            _divider(),
            _navRow('회원 탈퇴',
                textColor: Colors.red,
                onTap: _confirmWithdraw),
          ]),
          const SizedBox(height: 20),

          // ── 정보 ──
          _sectionLabel('정보'),
          const SizedBox(height: 8),
          _card([
            _navRow('개인정보처리방침',
                onTap: () => _showSnack('개인정보처리방침')),
            _divider(),
            _navRow('이용 약관', onTap: () => _showSnack('이용 약관')),
            _divider(),
            _navRow('오픈소스 라이선스',
                onTap: () => _showSnack('오픈소스 라이선스')),
            _divider(),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(children: [
                const Expanded(
                  child: Text('버전',
                      style: TextStyle(
                          fontSize: 15, color: Colors.black87)),
                ),
                Text('v1.0',
                    style: TextStyle(
                        fontSize: 14, color: Colors.grey.shade500)),
              ]),
            ),
          ]),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Text(text,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600)),
      );

  Widget _card(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(children: children),
      );

  Widget _toggleRow(String label, bool value, ValueChanged<bool> onChanged) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 15, color: Colors.black87)),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: _green),
        ]),
      );

  Widget _navRow(String label,
      {Color? textColor, required VoidCallback onTap}) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 15,
                      color: textColor ?? Colors.black87)),
            ),
            Icon(Icons.chevron_right,
                color: Colors.grey.shade400, size: 20),
          ]),
        ),
      );

  Widget _divider() =>
      const Divider(height: 1, indent: 16, endIndent: 16);

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  void _confirmWithdraw() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded,
              color: Colors.red, size: 22),
          SizedBox(width: 8),
          Text('회원 탈퇴',
              style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 17)),
        ]),
        content: const Text(
          '탈퇴 시 모든 의료 기록, 가이드, OCR 데이터가\n즉시 삭제되며 복구가 불가능합니다.',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소',
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onLogout?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('탈퇴',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() => BottomNavigationBar(
        currentIndex: 4,
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
