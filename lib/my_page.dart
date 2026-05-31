import 'dart:convert';
import 'dart:math';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'services/user_service.dart';
import 'services/ocr_service.dart';
import 'user_edit_page.dart';
import 'ocr_history_page.dart';
import 'notification_toggle_page.dart';
import 'main.dart';
import 'features/gamification/services/gamification_service.dart';
import 'features/gamification/widgets/point_card_widget.dart';
import 'features/gamification/pages/gamification_page.dart';

class MyPage extends StatefulWidget {
  final TokenStorage tokenStorage;
  final VoidCallback? onLogout;

  const MyPage({
    super.key,
    required this.tokenStorage,
    this.onLogout,
  });

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  late final UserService _userService;
  final _gamificationService = GamificationService();

  bool _loading = true;
  String? _error;
  UserProfile? _profile;

  static const _green = Color(0xFF2ECC71);
  static const _greenLight = Color(0xFFE8F8F0);
  static const _bg = Color(0xFFF8FAF8);
  static const _cardBg = Colors.white;
  static const _textPrimary = Color(0xFF1A1A1A);
  static const _textSecondary = Color(0xFF888888);
  static const _divider = Color(0xFFF0F0F0);
  static const _purple = Color(0xFF7C5CCF);
  static const _purpleLight = Color(0xFFF0E8FF);

  @override
  void initState() {
    super.initState();
    _userService = UserService(tokenStorage: widget.tokenStorage);
    _loadProfile();
  }

  @override
  void dispose() {
    _userService.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() { _loading = true; _error = null; });
    try {
      final profile = await _userService.getMe();
      if (mounted) setState(() => _profile = profile);
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = '정보를 불러올 수 없습니다.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool get _isAutoimmune => _profile?.userType == 'autoimmune';
  Color get _themeColor => _isAutoimmune ? _purple : _green;
  Color get _themeLightColor => _isAutoimmune ? _purpleLight : _greenLight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: _loading
            ? Center(child: CircularProgressIndicator(color: _themeColor))
            : _error != null ? _buildError() : _buildBody(),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_error!, style: const TextStyle(color: _textSecondary)),
          const SizedBox(height: 16),
          TextButton(onPressed: _loadProfile,
              child: Text('다시 시도', style: TextStyle(color: _themeColor))),
          const SizedBox(height: 8),
          TextButton(onPressed: () => widget.onLogout?.call(),
              child: const Text('로그아웃', style: TextStyle(color: Colors.red, fontSize: 15))),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: _loadProfile,
      color: _themeColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('마이페이지',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: _textPrimary)),
            const SizedBox(height: 20),
            _buildProfileCard(),
            const SizedBox(height: 8),
            _buildTypeBadge(),
            const SizedBox(height: 16),
            PointCardWidget(service: _gamificationService),
            const SizedBox(height: 8),
            _buildGamificationCard(),
            const SizedBox(height: 20),
            _sectionLabel('내 건강 정보'),
            const SizedBox(height: 8),
            _buildMenuCard(_healthMenuItems),
            const SizedBox(height: 20),
            _sectionLabel('앱 설정'),
            const SizedBox(height: 8),
            _buildMenuCard(_appSettingsMenuItems),
            const SizedBox(height: 20),
            _sectionLabel('지원'),
            const SizedBox(height: 8),
            _buildMenuCard(_supportMenuItems),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildGamificationCard() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GamificationPage(service: _gamificationService),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8F8F0)),
        ),
        child: const Row(
          children: [
            Text('🏅', style: TextStyle(fontSize: 22)),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('뱃지 · 보상',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text('획득한 뱃지와 포인트 보상을 확인하세요',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    final profile = _profile;
    final heightStr = profile?.height != null ? '${profile!.height!.toStringAsFixed(0)}cm' : '-';
    final weightStr = profile?.weight != null ? '${profile!.weight!.toStringAsFixed(0)}kg' : '-';
    final birthStr = profile?.birthDate?.replaceAll('-', '.') ?? '-';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(width: 52, height: 52,
                  decoration: BoxDecoration(color: _themeLightColor, shape: BoxShape.circle),
                  child: Icon(Icons.person_outline, color: _themeColor, size: 28)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(profile?.name ?? '-',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _textPrimary)),
                  const SizedBox(height: 2),
                  Text(profile?.email ?? '-',
                      style: const TextStyle(fontSize: 13, color: _textSecondary)),
                ]),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: _textSecondary, size: 22),
                onPressed: () => _navigate('user_edit'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _buildStatBox('키 / 몸무게', '$heightStr / $weightStr')),
            const SizedBox(width: 10),
            Expanded(child: _buildStatBox('생년월일', birthStr)),
          ]),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 12, color: _textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textPrimary)),
      ]),
    );
  }

  Widget _buildTypeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: _themeColor, borderRadius: BorderRadius.circular(20)),
      child: Text(_isAutoimmune ? '자가면역' : '일반',
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }

  List<_MenuItem> get _healthMenuItems => _isAutoimmune
      ? [
          _MenuItem(icon: Icons.description_outlined, label: '질환 정보', route: 'disease_info'),
          _MenuItem(icon: Icons.medication_outlined, label: '약물 목록', route: 'medication_list'),
          _MenuItem(icon: Icons.monitor_heart_outlined, label: '위험요인 프로필', route: 'risk_profile'),
          _MenuItem(icon: Icons.folder_outlined, label: '문서 보관함', route: 'documents'),
        ]
      : [
          _MenuItem(icon: Icons.description_outlined, label: '진료 기록', route: 'medical_records'),
          _MenuItem(icon: Icons.medication_outlined, label: '약물 목록', route: 'medication_list'),
          _MenuItem(icon: Icons.monitor_heart_outlined, label: '건강 수치 기록', route: 'health_metrics'),
          _MenuItem(icon: Icons.folder_outlined, label: '문서 보관함', route: 'documents'),
        ];

  List<_MenuItem> get _appSettingsMenuItems => [
        _MenuItem(icon: Icons.videogame_asset_outlined, label: '오늘의 활동', route: 'game'),
        _MenuItem(icon: Icons.notifications_none_outlined, label: '알림 설정', route: 'notification_settings'),
        _MenuItem(icon: Icons.swap_horiz_outlined, label: '모드 전환', route: 'mode_switch'),
        _MenuItem(icon: Icons.settings_outlined, label: '설정', route: 'settings'),
      ];

  List<_MenuItem> get _supportMenuItems => [
        _MenuItem(icon: Icons.help_outline, label: '도움말', route: 'help'),
        _MenuItem(icon: Icons.campaign_outlined, label: '문의하기', route: 'contact'),
        _MenuItem(icon: Icons.logout, label: '로그아웃', route: 'logout', isDestructive: true),
      ];

  Widget _buildMenuCard(List<_MenuItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return Column(children: [
            _buildMenuRow(item),
            if (i < items.length - 1)
              const Divider(height: 1, thickness: 1, color: _divider, indent: 16, endIndent: 16),
          ]);
        }),
      ),
    );
  }

  Widget _buildMenuRow(_MenuItem item) {
    return InkWell(
      onTap: () => _handleMenuTap(item.route),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(item.icon, size: 22, color: item.isDestructive ? Colors.red : _textPrimary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(item.label,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500,
                      color: item.isDestructive ? Colors.red : _textPrimary)),
            ),
            Icon(Icons.chevron_right,
                color: item.isDestructive ? Colors.red.withValues(alpha: 0.5) : _textSecondary,
                size: 20),
          ],
        ),
      ),
    );
  }

  void _handleMenuTap(String route) {
    if (route == 'logout') { _confirmLogout(); return; }
    _navigate(route);
  }

  void _navigate(String route) {
    if (route == 'user_edit' && _profile != null) {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => UserEditPage(
          tokenStorage: widget.tokenStorage,
          profile: _profile!,
          onWithdraw: widget.onLogout,
        ),
      ));
      return;
    }
    if (route == 'documents') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const OcrHistoryPage()));
      return;
    }
    if (route == 'notification_settings') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationTogglePage()));
      return;
    }
    if (route == 'game') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const GamePage()));
      return;
    }
    debugPrint('Navigate to: $route');
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('로그아웃', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        content: const Text('로그아웃 하시겠습니까?', style: TextStyle(fontSize: 15)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('취소', style: TextStyle(color: _textSecondary))),
          TextButton(
            onPressed: () { Navigator.pop(ctx); widget.onLogout?.call(); },
            child: const Text('로그아웃', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text,
        style: const TextStyle(fontSize: 13, color: _textSecondary, fontWeight: FontWeight.w500));
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String route;
  final bool isDestructive;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.route,
    this.isDestructive = false,
  });
}

// ══════════════════════════════════════════════════════════
// REQ-GAME-001: 게임 페이지
// ══════════════════════════════════════════════════════════
class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final _client = http.Client();
  int _totalPoints = 0;
  List<Map<String, dynamic>> _badges = [];
  bool _isLoadingBadges = false;

  @override
  void initState() {
    super.initState();
    _loadBadges();
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  Future<void> _loadBadges() async {
    setState(() => _isLoadingBadges = true);
    try {
      final token = await SecureTokenStorage().getAccessToken();
      if (token == null) return;
      final response = await _client.get(
        Uri.parse('${OcrConfig.baseUrl}/v1/games/badges'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      ).timeout(OcrConfig.timeoutDuration);
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _totalPoints = data['total_points'] as int? ?? 0;
          _badges = (data['badges'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoadingBadges = false);
    }
  }

  Future<void> _submitScore(String gameType, int score) async {
    try {
      final token = await SecureTokenStorage().getAccessToken();
      if (token == null) return;
      final response = await _client.post(
        Uri.parse('${OcrConfig.baseUrl}/v1/games/scores'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'game_type': gameType, 'score': score}),
      ).timeout(OcrConfig.timeoutDuration);
      if (!mounted) return;
      if (response.statusCode == 201) {
        final earned = jsonDecode(response.body)['points_earned'] as int? ?? 0;
        if (earned > 0 && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('🎉 +$earned 포인트 획득!'),
            backgroundColor: const Color(0xFFFF8C00),
            duration: const Duration(seconds: 2),
          ));
          _loadBadges();
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 360;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('오늘의 활동',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: isSmall ? 12 : 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPointsCard(),
            const SizedBox(height: 20),
            const Text('두뇌 활동',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 12),
            _buildGameCard(
              title: '메모리 카드 매칭',
              description: '카드를 뒤집어 같은 쌍을 찾아보세요',
              icon: Icons.grid_view_rounded,
              color: const Color(0xFFFF8C00),
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => MemoryGamePage(
                  onGameEnd: (score) => _submitScore('memory_card', score)),
              )),
            ),
            const SizedBox(height: 20),
            const Text('복약 확인',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 12),
            _buildGameCard(
              title: '복약 확인 퀴즈',
              description: '오늘 복용한 약을 확인해보세요',
              icon: Icons.medication_outlined,
              color: Colors.green,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => MedicationQuizPage(
                  onQuizEnd: (score) => _submitScore('medication_quiz', score)),
              )),
            ),
            if (_badges.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text('획득한 뱃지',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 12),
              _buildBadgesSection(),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF8C00), Color(0xFFFFAD00)],
          begin: Alignment.centerLeft, end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
          color: const Color(0xFFFF8C00).withValues(alpha: 0.3),
          blurRadius: 10, offset: const Offset(0, 4),
        )],
      ),
      child: _isLoadingBadges
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Row(children: [
              const Icon(Icons.stars_rounded, color: Colors.white, size: 40),
              const SizedBox(width: 16),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('누적 포인트', style: TextStyle(color: Colors.white70, fontSize: 13)),
                Text('$_totalPoints P',
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              ]),
            ]),
    );
  }

  Widget _buildGameCard({
    required String title, required String description,
    required IconData icon, required Color color, required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2),
          )],
        ),
        child: Row(children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
            const SizedBox(height: 4),
            Text(description, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ])),
          Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 16),
        ]),
      ),
    );
  }

  Widget _buildBadgesSection() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2),
        )],
      ),
      child: Wrap(
        spacing: 12, runSpacing: 12,
        children: _badges.map((badge) {
          final name = badge['name'] as String? ?? '';
          final icon = badge['icon'] as String? ?? '🏅';
          return Column(mainAxisSize: MainAxisSize.min, children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 4),
            Text(name, style: const TextStyle(fontSize: 11, color: Colors.grey), textAlign: TextAlign.center),
          ]);
        }).toList(),
      ),
    );
  }
}

// ── 메모리 카드 효과음 (Web Audio API) ───────────────────
class _CardSound {
  static void _play(String script) {
    try { js.context.callMethod('eval', [script]); } catch (_) {}
  }

  // 카드 뒤집기: 짧은 클릭음
  static void flip() => _play('''
    (function(){
      var c=new(window.AudioContext||window.webkitAudioContext)();
      var o=c.createOscillator(),g=c.createGain();
      o.connect(g);g.connect(c.destination);
      o.frequency.value=600;o.type='sine';
      g.gain.setValueAtTime(0.2,c.currentTime);
      g.gain.exponentialRampToValueAtTime(0.001,c.currentTime+0.08);
      o.start(c.currentTime);o.stop(c.currentTime+0.08);
    })();
  ''');

  // 매칭 성공: 상승 두 음
  static void match() => _play('''
    (function(){
      var c=new(window.AudioContext||window.webkitAudioContext)();
      [523,784].forEach(function(f,i){
        var o=c.createOscillator(),g=c.createGain();
        o.connect(g);g.connect(c.destination);
        o.frequency.value=f;o.type='sine';
        var t=c.currentTime+i*0.12;
        g.gain.setValueAtTime(0.25,t);
        g.gain.exponentialRampToValueAtTime(0.001,t+0.15);
        o.start(t);o.stop(t+0.15);
      });
    })();
  ''');

  // 매칭 실패: 낮은 버즈음
  static void mismatch() => _play('''
    (function(){
      var c=new(window.AudioContext||window.webkitAudioContext)();
      var o=c.createOscillator(),g=c.createGain();
      o.connect(g);g.connect(c.destination);
      o.frequency.value=180;o.type='sawtooth';
      g.gain.setValueAtTime(0.15,c.currentTime);
      g.gain.exponentialRampToValueAtTime(0.001,c.currentTime+0.2);
      o.start(c.currentTime);o.stop(c.currentTime+0.2);
    })();
  ''');

  // 게임 완료: 승리 멜로디
  static void complete() => _play('''
    (function(){
      var c=new(window.AudioContext||window.webkitAudioContext)();
      [523,659,784,1047].forEach(function(f,i){
        var o=c.createOscillator(),g=c.createGain();
        o.connect(g);g.connect(c.destination);
        o.frequency.value=f;o.type='sine';
        var t=c.currentTime+i*0.15;
        g.gain.setValueAtTime(0.3,t);
        g.gain.exponentialRampToValueAtTime(0.001,t+0.2);
        o.start(t);o.stop(t+0.2);
      });
    })();
  ''');
}

// ── 메모리 카드 매칭 ──────────────────────────────────────
class MemoryGamePage extends StatefulWidget {
  final void Function(int score) onGameEnd;
  const MemoryGamePage({super.key, required this.onGameEnd});

  @override
  State<MemoryGamePage> createState() => _MemoryGamePageState();
}

class _MemoryGamePageState extends State<MemoryGamePage> {
  static const _emojis = ['💊', '🏥', '🩺', '💉', '🩹', '🧬'];
  late List<String> _cards;
  late List<bool> _flipped;
  late List<bool> _matched;
  int? _firstIndex;
  bool _isChecking = false;
  int _moves = 0;
  int _matchedPairs = 0;

  @override
  void initState() { super.initState(); _initGame(); }

  void _initGame() {
    final pairs = [..._emojis, ..._emojis]..shuffle(Random());
    _cards = pairs;
    _flipped = List.filled(12, false);
    _matched = List.filled(12, false);
    _firstIndex = null;
    _isChecking = false;
    _moves = 0;
    _matchedPairs = 0;
  }

  void _onCardTap(int index) {
    if (_isChecking || _flipped[index] || _matched[index]) return;
    _CardSound.flip();
    setState(() => _flipped[index] = true);
    if (_firstIndex == null) { _firstIndex = index; return; }
    _isChecking = true;
    final first = _firstIndex!;
    _firstIndex = null;
    _moves++;
    if (_cards[first] == _cards[index]) {
      _CardSound.match();
      setState(() { _matched[first] = true; _matched[index] = true; _matchedPairs++; _isChecking = false; });
      if (_matchedPairs == _emojis.length) {
        final score = max(0, 100 - (_moves - _emojis.length) * 5);
        _CardSound.complete();
        widget.onGameEnd(score);
        _showGameOverDialog(score);
      }
    } else {
      Future.delayed(const Duration(milliseconds: 400), () {
        _CardSound.mismatch();
      });
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        setState(() { _flipped[first] = false; _flipped[index] = false; _isChecking = false; });
      });
    }
  }

  void _showGameOverDialog(int score) {
    showDialog(
      context: context, barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('🎉 완료!', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('시도 횟수: $_moves회\n점수: $score점'),
        actions: [
          TextButton(
            onPressed: () { Navigator.pop(context); Navigator.pop(context); },
            child: const Text('나가기')),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); setState(() => _initGame()); },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8C00)),
            child: const Text('다시하기', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardFontSize = (MediaQuery.of(context).size.width - 56) / 4 * 0.4;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context)),
        title: const Text('메모리 카드 매칭',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        actions: [
          Center(child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text('시도 $_moves회',
                style: const TextStyle(color: Color(0xFFFF8C00), fontWeight: FontWeight.bold)),
          )),
        ],
      ),
      body: Column(children: [
        const SizedBox(height: 20),
        Text('${_matchedPairs}/${_emojis.length} 매칭 완료',
            style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8),
            itemCount: 12,
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => _onCardTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: _matched[i]
                      ? Colors.green.withValues(alpha: 0.15)
                      : _flipped[i] ? Colors.white : const Color(0xFFFF8C00),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08), blurRadius: 4, offset: const Offset(0, 2),
                  )],
                ),
                child: Center(child: Text(
                  _flipped[i] || _matched[i] ? _cards[i] : '?',
                  style: TextStyle(
                    fontSize: cardFontSize,
                    color: _flipped[i] || _matched[i] ? null : Colors.white),
                )),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () => setState(() => _initGame()),
          icon: const Icon(Icons.refresh, color: Colors.white),
          label: const Text('초기화', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        ),
      ]),
    );
  }
}

// ── 복약 확인 퀴즈 ────────────────────────────────────────
class MedicationQuizPage extends StatefulWidget {
  final void Function(int score) onQuizEnd;
  const MedicationQuizPage({super.key, required this.onQuizEnd});

  @override
  State<MedicationQuizPage> createState() => _MedicationQuizPageState();
}

class _MedicationQuizPageState extends State<MedicationQuizPage> {
  final _client = http.Client();
  bool _isLoading = true;
  List<Map<String, dynamic>> _medications = [];
  int _currentIndex = 0;
  int _correctCount = 0;
  bool? _answered;
  bool _quizDone = false;

  @override
  void initState() { super.initState(); _loadMedications(); }

  @override
  void dispose() { _client.close(); super.dispose(); }

  Future<void> _loadMedications() async {
    try {
      final token = await SecureTokenStorage().getAccessToken();
      if (token == null) return;
      final response = await _client.get(
        Uri.parse('${OcrConfig.baseUrl}/v1/medications'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      ).timeout(OcrConfig.timeoutDuration);
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final meds = ((data['items'] ?? data) as List).cast<Map<String, dynamic>>();
        setState(() { _medications = meds.take(5).toList(); _isLoading = false; });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _answer(bool tookIt) {
    if (_answered != null) return;
    setState(() => _answered = tookIt);
    if (tookIt) _correctCount++;
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      if (_currentIndex + 1 >= _medications.length) {
        final score = (_correctCount / _medications.length * 100).round();
        setState(() => _quizDone = true);
        widget.onQuizEnd(score);
      } else {
        setState(() { _currentIndex++; _answered = null; });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context)),
        title: const Text('복약 확인 퀴즈',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF8C00)))
          : _medications.isEmpty ? _buildEmpty()
          : _quizDone ? _buildResult() : _buildQuiz(),
    );
  }

  Widget _buildEmpty() {
    return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.medication_outlined, size: 64, color: Colors.grey),
      SizedBox(height: 16),
      Text('등록된 약품이 없습니다.', style: TextStyle(color: Colors.grey, fontSize: 16)),
      SizedBox(height: 8),
      Text('진료기록에서 약품을 등록해보세요.', style: TextStyle(color: Colors.grey, fontSize: 13)),
    ]));
  }

  Widget _buildQuiz() {
    final med = _medications[_currentIndex];
    final name = med['drug_name_user_input'] as String? ?? med['drug_name'] as String? ?? '약품';
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        LinearProgressIndicator(
          value: (_currentIndex + 1) / _medications.length,
          backgroundColor: Colors.grey.shade200,
          color: const Color(0xFFFF8C00),
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 8),
        Text('${_currentIndex + 1} / ${_medications.length}',
            style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 40),
        Container(
          width: double.infinity, padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(
              color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2),
            )],
          ),
          child: Column(children: [
            const Text('💊', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            const Text('오늘 이 약을 복용했나요?', style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 8),
            Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                textAlign: TextAlign.center),
          ]),
        ),
        const SizedBox(height: 32),
        Row(children: [
          Expanded(child: _buildAnswerButton(label: '✓ 복용했어요', color: Colors.green, selected: _answered == true, onTap: () => _answer(true))),
          const SizedBox(width: 16),
          Expanded(child: _buildAnswerButton(label: '✗ 아직이에요', color: Colors.red.shade400, selected: _answered == false, onTap: () => _answer(false))),
        ]),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: const Row(children: [
            Icon(Icons.info_outline, size: 14, color: Colors.grey),
            SizedBox(width: 6),
            Expanded(child: Text(
              '본 퀴즈는 자가 복약 확인 도구이며 의학적 판단을 대체하지 않습니다.',
              style: TextStyle(color: Colors.grey, fontSize: 11, height: 1.4),
            )),
          ]),
        ),
      ]),
    );
  }

  Widget _buildAnswerButton({
    required String label, required Color color,
    required bool selected, required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: _answered == null ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? color : Colors.grey.shade300),
          boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2),
          )],
        ),
        child: Text(label, textAlign: TextAlign.center,
            style: TextStyle(color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold, fontSize: 15)),
      ),
    );
  }

  Widget _buildResult() {
    final score = (_correctCount / _medications.length * 100).round();
    return Center(child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(score >= 80 ? '🎉' : score >= 50 ? '👍' : '💪', style: const TextStyle(fontSize: 64)),
        const SizedBox(height: 16),
        const Text('복약 확인 완료!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('$_correctCount / ${_medications.length} 복용 완료',
            style: const TextStyle(color: Colors.grey, fontSize: 16)),
        const SizedBox(height: 32),
        SizedBox(width: double.infinity, child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF8C00),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('완료', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        )),
      ]),
    ));
  }
}