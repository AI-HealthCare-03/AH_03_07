import 'dart:convert';
import 'dart:math';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'services/user_service.dart';
import 'services/ocr_service.dart';
import 'widgets/helcy_widget.dart';
import 'widgets/helcy_cheer_widget.dart';
import 'features/room/pages/room_page.dart';
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
            const SizedBox(height: 8),
            _buildRoomCard(),
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

  Widget _buildRoomCard() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RoomPage(gamificationService: _gamificationService),
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
            Text('🏠', style: TextStyle(fontSize: 22)),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('내 방 꾸미기',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text('포인트로 가구·동물 구매 후 방을 꾸며보세요',
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
            const SizedBox(height: 12),
            _buildGameCard(
              title: 'OX 퀴즈',
              description: '건강 상식을 O/X로 맞춰보세요',
              icon: Icons.quiz_outlined,
              color: Colors.blue,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => OxQuizPage(
                  onGameEnd: (score) => _submitScore('ox_quiz', score)),
              )),
            ),
            const SizedBox(height: 12),
            _buildGameCard(
              title: '단어 맞추기',
              description: '초성 힌트로 의학 용어를 맞춰보세요',
              icon: Icons.abc_outlined,
              color: Colors.purple,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => WordGuessPage(
                  onGameEnd: (score) => _submitScore('word_guess', score)),
              )),
            ),
            const SizedBox(height: 12),
            _buildGameCard(
              title: '타이머 챌린지',
              description: '제한 시간 안에 카드를 모두 뒤집으세요',
              icon: Icons.timer_outlined,
              color: Colors.red,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => TimerChallengeGame(
                  onGameEnd: (score) => _submitScore('timer_challenge', score)),
              )),
            ),
            const SizedBox(height: 12),
            _buildGameCard(
              title: '수치 범위 맞추기',
              description: '정상 건강 수치 범위를 슬라이더로 맞춰보세요',
              icon: Icons.show_chart_outlined,
              color: Colors.teal,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => HealthRangeQuizPage(
                  onGameEnd: (score) => _submitScore('health_range', score)),
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

// ── 메모리 카드 효과음 (web/index.html에 정의된 함수 호출) ─
class _CardSound {
  static void _call(String fn) {
    try { js.context.callMethod(fn, []); } catch (_) {}
  }

  static void flip()     => _call('cardFlip');
  static void match()    => _call('cardMatch');
  static void combo()    => _call('cardCombo');
  static void mismatch() => _call('cardMiss');
  static void complete() => _call('cardComplete');
}

// ── 메모리 카드 매칭 ──────────────────────────────────────
class MemoryGamePage extends StatefulWidget {
  final void Function(int score) onGameEnd;
  const MemoryGamePage({super.key, required this.onGameEnd});

  @override
  State<MemoryGamePage> createState() => _MemoryGamePageState();
}

class _MemoryGamePageState extends State<MemoryGamePage> {
  static const _allEmojis = [
    '💊','🏥','🩺','💉','🩹','🧬','🦠','🧪','🫀','🫁',
    '🧠','🦷','🦴','👁️','👂','🩻','🩸','💪','🌡️','⚕️',
  ];
  late List<String> _emojis;
  late List<String> _cards;
  late List<bool> _flipped;
  late List<bool> _matched;
  int? _firstIndex;
  bool _isChecking = false;
  int _moves = 0;
  int _matchedPairs = 0;
  int _comboCount = 0; // 연속 정답 카운터

  @override
  void initState() { super.initState(); _initGame(); }

  void _initGame() {
    // 매 게임마다 20개 중 6개 랜덤 선택
    final pool = List.of(_allEmojis)..shuffle(Random());
    _emojis = pool.take(6).toList();
    final pairs = [..._emojis, ..._emojis]..shuffle(Random());
    _cards = pairs;
    _flipped = List.filled(12, false);
    _matched = List.filled(12, false);
    _firstIndex = null;
    _isChecking = false;
    _moves = 0;
    _matchedPairs = 0;
    _comboCount = 0;
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
      _comboCount++;
      // 2연속 이상이면 콤보 소리, 아니면 일반 성공 소리
      if (_comboCount >= 2) {
        _CardSound.combo();
      } else {
        _CardSound.match();
      }
      setState(() { _matched[first] = true; _matched[index] = true; _matchedPairs++; _isChecking = false; });
      if (_matchedPairs == _emojis.length) {
        final score = max(0, 100 - (_moves - _emojis.length) * 5);
        _CardSound.complete();
        widget.onGameEnd(score);
        _showGameOverDialog(score);
      }
    } else {
      _comboCount = 0; // 틀리면 콤보 리셋
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
      body: Stack(children: [
        Column(children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${_matchedPairs}/${_emojis.length} 매칭 완료',
                style: const TextStyle(color: Colors.grey, fontSize: 14)),
            if (_comboCount >= 2) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8C00),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('🔥 $_comboCount연속!',
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
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
        // 응원 헬씨
        Positioned(
          right: 8,
          bottom: 80,
          child: HelcyCheerWidget(
            mood: _matchedPairs > 0
                ? (_comboCount >= 2 ? HelcyMood.excited : HelcyMood.happy)
                : HelcyMood.waving,
            message: _comboCount >= 2
                ? '$_comboCount연속!\n최고야!'
                : _matchedPairs > 0
                    ? '잘하고 있어!'
                    : '화이팅!',
          ),
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

// ══════════════════════════════════════════════════════════
// OX 퀴즈
// ══════════════════════════════════════════════════════════
class OxQuizPage extends StatefulWidget {
  final void Function(int score) onGameEnd;
  const OxQuizPage({super.key, required this.onGameEnd});
  @override
  State<OxQuizPage> createState() => _OxQuizPageState();
}

class _OxQuizPageState extends State<OxQuizPage> {
  static const _allQuestions = [
    // 자가면역
    (q: '류마티스 관절염은 노인에게만 발생한다.', answer: false, desc: '청년층에도 발생하며 30~50대에 많습니다.'),
    (q: '루푸스(SLE)는 남성에게 더 흔한 질환이다.', answer: false, desc: '루푸스는 여성 환자가 약 9배 더 많습니다.'),
    (q: '자가면역 질환은 면역계가 자기 몸을 공격하는 질환이다.', answer: true, desc: '면역계 오작동으로 자신의 조직을 공격합니다.'),
    (q: '류마티스 관절염은 완치가 가능한 질환이다.', answer: false, desc: '완치는 어렵지만 적절한 치료로 증상을 관리할 수 있습니다.'),
    (q: '루푸스 환자는 햇빛을 피하는 것이 좋다.', answer: true, desc: '자외선이 루푸스 증상을 악화시킬 수 있습니다.'),
    // 혈압·혈당
    (q: '혈압 정상 범위는 수축기 120mmHg 미만입니다.', answer: true, desc: '정상 혈압은 120/80mmHg 미만입니다.'),
    (q: '공복 혈당 정상치는 100mg/dL 미만이다.', answer: true, desc: '100 이상이면 당뇨 전단계로 봅니다.'),
    (q: '혈압이 높으면 증상이 항상 나타난다.', answer: false, desc: '고혈압은 증상이 없어 \'침묵의 살인자\'라 불립니다.'),
    (q: '당뇨 환자는 과일을 전혀 먹으면 안 된다.', answer: false, desc: '적정량의 과일은 섭취 가능하며 혈당 관리가 중요합니다.'),
    // 복약
    (q: '복약은 식사와 상관없이 아무 때나 먹어도 된다.', answer: false, desc: '약에 따라 식전/식후/공복 복용 지침이 다릅니다.'),
    (q: '항생제는 바이러스 감염에 효과적이다.', answer: false, desc: '항생제는 세균에만 효과적이며 바이러스에는 무효합니다.'),
    (q: '약을 먹다가 증상이 나아지면 바로 중단해도 된다.', answer: false, desc: '임의 중단 시 내성이 생기거나 재발할 수 있습니다.'),
    (q: '두 가지 이상의 약을 함께 먹으면 항상 위험하다.', answer: false, desc: '병용 가능한 약도 많지만 의사·약사와 상담이 필요합니다.'),
    // 운동·생활
    (q: '관절염 환자는 운동을 완전히 피해야 한다.', answer: false, desc: '적절한 저강도 운동은 관절 기능 유지에 도움이 됩니다.'),
    (q: 'BMI 25 이상은 과체중으로 분류된다.', answer: true, desc: 'WHO 기준 BMI 25~29.9는 과체중입니다.'),
    (q: '하루 물 권장 섭취량은 약 2리터이다.', answer: true, desc: '성인 기준 하루 1.5~2리터 섭취를 권장합니다.'),
    (q: '스트레스는 면역계에 영향을 미친다.', answer: true, desc: '만성 스트레스는 면역 기능을 저하시킬 수 있습니다.'),
    // 기초 건강
    (q: '정상 체온은 약 36.5°C입니다.', answer: true, desc: '36~37.5°C가 정상 체온 범위입니다.'),
    (q: '성인의 정상 심박수는 분당 60~100회이다.', answer: true, desc: '60 미만이면 서맥, 100 이상이면 빈맥입니다.'),
    (q: '수면 중에는 면역 기능이 저하된다.', answer: false, desc: '수면 중 면역 세포가 활성화되어 회복을 돕습니다.'),
    (q: '흡연은 류마티스 관절염 위험을 높인다.', answer: true, desc: '흡연은 류마티스 관절염의 주요 위험 인자입니다.'),
    (q: '칼슘 섭취는 뼈 건강에만 중요하다.', answer: false, desc: '칼슘은 근육 수축, 신경 전달 등 다양한 역할을 합니다.'),
    (q: '비타민 D는 햇빛을 통해 체내에서 합성된다.', answer: true, desc: '피부가 자외선에 노출되면 비타민 D가 합성됩니다.'),
    (q: '오메가-3 지방산은 염증을 줄이는 데 도움이 된다.', answer: true, desc: '항염증 효과가 있어 자가면역 질환에도 도움됩니다.'),
    (q: '고혈압 치료제는 평생 먹어야 한다.', answer: false, desc: '생활 습관 개선으로 감량·중단이 가능한 경우도 있습니다.'),
  ];
  late List<({String q, bool answer, String desc})> _questions;

  @override
  void initState() {
    super.initState();
    _questions = (List.of(_allQuestions)..shuffle(Random())).take(10).toList();
  }

  int _index = 0;
  int _correct = 0;
  bool? _answered;
  bool _done = false;

  void _answer(bool userAnswer) {
    if (_answered != null || _done) return;
    final correct = userAnswer == _questions[_index].answer;
    correct ? _CardSound.match() : _CardSound.mismatch();
    setState(() { _answered = userAnswer; if (correct) _correct++; });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      if (_index + 1 >= _questions.length) {
        final score = (_correct / _questions.length * 100).round();
        _CardSound.complete();
        setState(() => _done = true);
        widget.onGameEnd(score);
        _showResult(score);
      } else {
        setState(() { _index++; _answered = null; });
      }
    });
  }

  void _showResult(int score) {
    showDialog(
      context: context, barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          HelcyWidget(level: 3, mood: score >= 60 ? HelcyMood.excited : HelcyMood.sad, size: 90),
          const SizedBox(height: 8),
          Text(score >= 80 ? '🎉 훌륭해요!' : score >= 60 ? '👍 잘했어요!' : '💪 다시 도전!',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 6),
          Text('$_correct/${_questions.length} 정답  |  $score점'),
        ]),
        actions: [
          TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text('나가기')),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); setState(() { _index = 0; _correct = 0; _answered = null; _done = false; }); },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('다시하기', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_index];
    final answered = _answered;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87), onPressed: () => Navigator.pop(context)),
        title: const Text('OX 퀴즈', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        actions: [Center(child: Padding(padding: const EdgeInsets.only(right: 16),
            child: Text('${_index + 1}/${_questions.length}', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          LinearProgressIndicator(value: (_index + 1) / _questions.length, color: Colors.blue, backgroundColor: Colors.blue.shade100),
          const SizedBox(height: 32),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12)]),
            child: Text(q.q, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.5), textAlign: TextAlign.center),
          ),
          if (answered != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (answered == q.answer) ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: (answered == q.answer) ? Colors.green : Colors.red),
              ),
              child: Row(children: [
                Icon((answered == q.answer) ? Icons.check_circle : Icons.cancel, color: (answered == q.answer) ? Colors.green : Colors.red),
                const SizedBox(width: 8),
                Expanded(child: Text(q.desc, style: TextStyle(color: (answered == q.answer) ? Colors.green.shade800 : Colors.red.shade800))),
              ]),
            ),
          ],
          const Spacer(),
          Row(children: [
            Expanded(child: _OxButton(label: 'O', color: Colors.blue,
                onTap: answered == null ? () => _answer(true) : null,
                selected: answered == true, correct: answered != null && q.answer == true)),
            const SizedBox(width: 16),
            Expanded(child: _OxButton(label: 'X', color: Colors.red,
                onTap: answered == null ? () => _answer(false) : null,
                selected: answered == false, correct: answered != null && q.answer == false)),
          ]),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }
}

class _OxButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool selected;
  final bool correct;
  const _OxButton({required this.label, required this.color, this.onTap, required this.selected, required this.correct});

  @override
  Widget build(BuildContext context) {
    Color bg = Colors.white;
    if (selected) {
      bg = correct ? Colors.green : Colors.red;
    } else if (correct && onTap == null) {
      bg = Colors.green.shade100;
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 90,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? bg : color, width: 3),
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 8)]),
        child: Center(child: Text(label, style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold,
            color: selected ? Colors.white : color))),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// 단어 맞추기
// ══════════════════════════════════════════════════════════
class WordGuessPage extends StatefulWidget {
  final void Function(int score) onGameEnd;
  const WordGuessPage({super.key, required this.onGameEnd});
  @override
  State<WordGuessPage> createState() => _WordGuessPageState();
}

class _WordGuessPageState extends State<WordGuessPage> {
  static const _allWords = [
    (word: '류마티스', hint: 'ㄹㅁㅌㅅ', desc: '관절에 염증이 생기는 자가면역 질환'),
    (word: '혈압', hint: 'ㅎㅇ', desc: '혈관 벽에 가해지는 혈액의 압력'),
    (word: '항생제', hint: 'ㅎㅅㅈ', desc: '세균 감염을 치료하는 약물'),
    (word: '루푸스', hint: 'ㄹㅍㅅ', desc: '피부·관절·신장 등을 침범하는 자가면역 질환'),
    (word: '복약', hint: 'ㅂㅇ', desc: '약을 정해진 방법대로 먹는 것'),
    (word: '혈당', hint: 'ㅎㄷ', desc: '혈액 속 포도당 농도'),
    (word: '면역', hint: 'ㅁㅇ', desc: '외부 병원체로부터 몸을 보호하는 시스템'),
    (word: '염증', hint: 'ㅇㅈ', desc: '조직 손상 시 나타나는 발적·부종·통증 반응'),
    (word: '고혈압', hint: 'ㄱㅎㅇ', desc: '혈압이 지속적으로 높은 상태'),
    (word: '당뇨', hint: 'ㄷㄴ', desc: '인슐린 이상으로 혈당 조절이 안 되는 질환'),
    (word: '골다공증', hint: 'ㄱㄷㄱㅈ', desc: '뼈 밀도가 감소하여 골절 위험이 높아지는 질환'),
    (word: '빈혈', hint: 'ㅂㅎ', desc: '혈액 내 적혈구나 헤모글로빈이 부족한 상태'),
    (word: '갑상선', hint: 'ㄱㅅㅅ', desc: '목 앞에 위치한 나비 모양의 내분비 기관'),
    (word: '인슐린', hint: 'ㅇㅅㄹ', desc: '혈당을 낮추는 췌장 호르몬'),
    (word: '백신', hint: 'ㅂㅅ', desc: '감염병 예방을 위해 투여하는 항원 물질'),
    (word: '항체', hint: 'ㅎㅊ', desc: '면역계가 생산하는 방어 단백질'),
    (word: '처방전', hint: 'ㅊㅂㅈ', desc: '의사가 약 종류·용량을 적어주는 문서'),
    (word: '부작용', hint: 'ㅂㅈㅇ', desc: '약물 투여 시 나타나는 의도치 않은 효과'),
    (word: '소염제', hint: 'ㅅㅇㅈ', desc: '염증과 통증을 완화하는 약물'),
    (word: '스테로이드', hint: 'ㅅㅌㄹㅇㄷ', desc: '강력한 항염증 효과를 가진 약물 또는 호르몬'),
  ];
  late List<({String word, String hint, String desc})> _words;

  int _index = 0;
  int _correct = 0;
  final _ctrl = TextEditingController();
  bool? _result;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _words = (List.of(_allWords)..shuffle(Random())).take(8).toList();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _submit() {
    final ans = _ctrl.text.trim();
    if (ans.isEmpty) return;
    final isCorrect = ans == _words[_index].word;
    if (isCorrect) { _correct++; _CardSound.match(); } else { _CardSound.mismatch(); }
    setState(() => _result = isCorrect);
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      _ctrl.clear();
      if (_index + 1 >= _words.length) {
        final score = (_correct / _words.length * 100).round();
        setState(() => _done = true);
        widget.onGameEnd(score);
        _showResult(score);
      } else {
        setState(() { _index++; _result = null; });
      }
    });
  }

  void _skip() {
    if (_done) return;
    _CardSound.mismatch();
    _ctrl.clear();
    setState(() { _result = false; });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      if (_index + 1 >= _words.length) {
        final score = (_correct / _words.length * 100).round();
        _CardSound.complete();
        setState(() => _done = true);
        widget.onGameEnd(score);
        _showResult(score);
      } else {
        setState(() { _index++; _result = null; });
      }
    });
  }

  void _showResult(int score) {
    showDialog(
      context: context, barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(score >= 80 ? '🎉 단어 마스터!' : '💪 다시 도전!', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text('$_correct/${_words.length} 정답\n점수: $score점'),
        actions: [
          TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text('나가기')),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); setState(() { _index = 0; _correct = 0; _result = null; _done = false; _ctrl.clear(); }); },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: const Text('다시하기', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = _words[_index];
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87), onPressed: () => Navigator.pop(context)),
        title: const Text('단어 맞추기', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        actions: [Center(child: Padding(padding: const EdgeInsets.only(right: 16),
            child: Text('${_index + 1}/${_words.length}', style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold))))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          LinearProgressIndicator(value: (_index + 1) / _words.length, color: Colors.purple, backgroundColor: Colors.purple.shade100),
          const SizedBox(height: 32),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12)]),
            child: Column(children: [
              const Text('힌트 (초성)', style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 12),
              Text(w.hint, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 8, color: Colors.purple)),
              const SizedBox(height: 16),
              Text(w.desc, style: const TextStyle(color: Colors.grey, fontSize: 14), textAlign: TextAlign.center),
            ]),
          ),
          const SizedBox(height: 24),
          if (_result != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _result! ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _result! ? Colors.green : Colors.red),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(_result! ? Icons.check_circle : Icons.cancel, color: _result! ? Colors.green : Colors.red),
                const SizedBox(width: 8),
                Text(_result! ? '정답!' : '정답: ${w.word}',
                    style: TextStyle(color: _result! ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
              ]),
            ),
          const Spacer(),
          TextField(
            controller: _ctrl,
            enabled: _result == null,
            decoration: InputDecoration(
              hintText: '정답을 입력하세요',
              filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: _result == null ? _skip : null,
              child: const Text('건너뛰기'),
            )),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(
              onPressed: _result == null ? _submit : null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              child: const Text('확인', style: TextStyle(color: Colors.white)),
            )),
          ]),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// 타이머 챌린지
// ══════════════════════════════════════════════════════════
class TimerChallengeGame extends StatefulWidget {
  final void Function(int score) onGameEnd;
  const TimerChallengeGame({super.key, required this.onGameEnd});
  @override
  State<TimerChallengeGame> createState() => _TimerChallengeGameState();
}

class _TimerChallengeGameState extends State<TimerChallengeGame> {
  static const _allEmojis = [
    '💊','🏥','🩺','💉','🩹','🧬','🦠','🧪','🫀','🫁',
    '🧠','🦷','🦴','👁️','👂','🩻','🩸','💪','🌡️','⚕️',
  ];
  late List<String> _emojis;
  static const _totalTime = 30; // 초

  late List<String> _cards;
  late List<bool> _flipped;
  late List<bool> _matched;
  int? _firstIndex;
  bool _isChecking = false;
  int _matchedPairs = 0;
  int _timeLeft = _totalTime;
  bool _started = false;
  bool _done = false;

  @override
  void initState() { super.initState(); _initGame(); }

  void _initGame() {
    final pool = List.of(_allEmojis)..shuffle(Random());
    _emojis = pool.take(8).toList();
    final pairs = [..._emojis, ..._emojis]..shuffle(Random());
    _cards = pairs;
    _flipped = List.filled(16, false);
    _matched = List.filled(16, false);
    _firstIndex = null;
    _isChecking = false;
    _matchedPairs = 0;
    _timeLeft = _totalTime;
    _started = false;
    _done = false;
  }

  void _startTimer() {
    if (_started) return;
    _started = true;
    _tick();
  }

  void _tick() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted || _done) return;
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) {
        _endGame();
      } else {
        _tick();
      }
    });
  }

  void _onCardTap(int index) {
    if (!_started) _startTimer();
    if (_done || _isChecking || _flipped[index] || _matched[index]) return;
    _CardSound.flip();
    setState(() => _flipped[index] = true);
    if (_firstIndex == null) { _firstIndex = index; return; }
    _isChecking = true;
    final first = _firstIndex!;
    _firstIndex = null;
    if (_cards[first] == _cards[index]) {
      _CardSound.match();
      setState(() { _matched[first] = true; _matched[index] = true; _matchedPairs++; _isChecking = false; });
      if (_matchedPairs == _emojis.length) _endGame();
    } else {
      Future.delayed(const Duration(milliseconds: 300), () => _CardSound.mismatch());
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        setState(() { _flipped[first] = false; _flipped[index] = false; _isChecking = false; });
      });
    }
  }

  void _endGame() {
    if (_done) return;
    _done = true;
    final score = (_matchedPairs * 100 ~/ _emojis.length).clamp(0, 100);
    if (_matchedPairs == _emojis.length) _CardSound.complete();
    widget.onGameEnd(score);
    _showResult(score);
  }

  void _showResult(int score) {
    showDialog(
      context: context, barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(_matchedPairs == _emojis.length ? '🏆 완벽 클리어!' : '⏱️ 시간 초과!',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text('$_matchedPairs/${_emojis.length} 완료\n점수: $score점'),
        actions: [
          TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text('나가기')),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); setState(() => _initGame()); },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('다시하기', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timerColor = _timeLeft <= 10 ? Colors.red : _timeLeft <= 20 ? Colors.orange : Colors.green;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87), onPressed: () => Navigator.pop(context)),
        title: const Text('타이머 챌린지', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        actions: [Center(child: Padding(padding: const EdgeInsets.only(right: 16),
            child: Text('⏱️ $_timeLeft초', style: TextStyle(color: timerColor, fontWeight: FontWeight.bold, fontSize: 18))))],
      ),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          // 고정 UI 높이: 진행바6 + gap8 + 텍스트20 + gap8 + 버튼44 + gap10 + gap12
          const fixedH = 6.0 + 8 + 20 + 8 + 44 + 10 + 12;
          const hPad = 24.0; // 좌우 패딩 합계
          const gap = 6.0;
          const cols = 4;
          const rows = 4;
          // 카드 크기 = 너비/높이 중 더 작은 값 사용 (항상 화면 안에 맞도록)
          final byWidth  = (constraints.maxWidth  - hPad - gap * (cols - 1)) / cols;
          final byHeight = (constraints.maxHeight - fixedH - gap * (rows - 1)) / rows;
          final cardSize = byWidth < byHeight ? byWidth : byHeight;
          final fontSize = cardSize * 0.42;
          final gridSize = cardSize * rows + gap * (rows - 1);

          return Column(children: [
            LinearProgressIndicator(
              value: _timeLeft / _totalTime,
              color: timerColor,
              backgroundColor: Colors.grey.shade200,
              minHeight: 6,
            ),
            const SizedBox(height: 8),
            Text(
              !_started ? '카드를 탭하면 타이머 시작!' : '$_matchedPairs/${_emojis.length} 매칭 완료',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: cardSize * cols + gap * (cols - 1),
              height: gridSize,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: gap,
                  mainAxisSpacing: gap,
                ),
                itemCount: 16,
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => _onCardTap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      color: _matched[i]
                          ? Colors.green.withValues(alpha: 0.15)
                          : _flipped[i] ? Colors.white : Colors.red,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4)],
                    ),
                    child: Center(child: Text(
                      _flipped[i] || _matched[i] ? _cards[i] : '?',
                      style: TextStyle(fontSize: fontSize, color: _flipped[i] || _matched[i] ? null : Colors.white),
                    )),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => setState(() => _initGame()),
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('초기화', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
          ]);
        }),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// 건강 수치 범위 맞추기
// ══════════════════════════════════════════════════════════
class HealthRangeQuizPage extends StatefulWidget {
  final void Function(int score) onGameEnd;
  const HealthRangeQuizPage({super.key, required this.onGameEnd});
  @override
  State<HealthRangeQuizPage> createState() => _HealthRangeQuizPageState();
}

class _HealthRangeQuizPageState extends State<HealthRangeQuizPage> {
  static const _allQuizzes = [
    // 심혈관
    (q: '정상 수축기 혈압 (mmHg)', min: 60.0, max: 200.0, answerMin: 90.0, answerMax: 120.0, unit: 'mmHg'),
    (q: '정상 이완기 혈압 (mmHg)', min: 40.0, max: 130.0, answerMin: 60.0, answerMax: 80.0, unit: 'mmHg'),
    (q: '성인 정상 심박수 (bpm)', min: 30.0, max: 150.0, answerMin: 60.0, answerMax: 100.0, unit: 'bpm'),
    (q: '정상 산소포화도 (%)', min: 80.0, max: 100.0, answerMin: 95.0, answerMax: 100.0, unit: '%'),
    (q: '성인 정상 호흡수 (회/분)', min: 5.0, max: 40.0, answerMin: 12.0, answerMax: 20.0, unit: '회/분'),
    // 혈당·대사
    (q: '공복 혈당 정상 범위 (mg/dL)', min: 50.0, max: 300.0, answerMin: 70.0, answerMax: 100.0, unit: 'mg/dL'),
    (q: '식후 2시간 혈당 정상치 (mg/dL)', min: 50.0, max: 350.0, answerMin: 70.0, answerMax: 140.0, unit: 'mg/dL'),
    (q: '정상 공복 인슐린 (μU/mL)', min: 0.0, max: 50.0, answerMin: 2.0, answerMax: 20.0, unit: 'μU/mL'),
    (q: 'HbA1c 정상 범위 (%)', min: 3.0, max: 15.0, answerMin: 4.0, answerMax: 5.7, unit: '%'),
    // 체온·체중
    (q: '정상 체온 범위 (°C)', min: 35.0, max: 42.0, answerMin: 36.1, answerMax: 37.2, unit: '°C'),
    (q: '정상 BMI 범위', min: 10.0, max: 50.0, answerMin: 18.5, answerMax: 24.9, unit: ''),
    // 염증 수치
    (q: '정상 CRP 수치 (mg/L)', min: 0.0, max: 50.0, answerMin: 0.0, answerMax: 5.0, unit: 'mg/L'),
    (q: '성인 정상 ESR (mm/h)', min: 0.0, max: 100.0, answerMin: 0.0, answerMax: 20.0, unit: 'mm/h'),
    (q: '정상 백혈구 수 (×10³/μL)', min: 1.0, max: 20.0, answerMin: 4.0, answerMax: 10.0, unit: '×10³/μL'),
    (q: '정상 혈소판 수 (×10³/μL)', min: 50.0, max: 600.0, answerMin: 150.0, answerMax: 400.0, unit: '×10³/μL'),
    // 신장·간
    (q: '정상 크레아티닌 수치 (mg/dL)', min: 0.0, max: 5.0, answerMin: 0.6, answerMax: 1.2, unit: 'mg/dL'),
    (q: '정상 ALT (GPT) 수치 (U/L)', min: 0.0, max: 100.0, answerMin: 7.0, answerMax: 40.0, unit: 'U/L'),
    (q: '정상 AST (GOT) 수치 (U/L)', min: 0.0, max: 100.0, answerMin: 10.0, answerMax: 40.0, unit: 'U/L'),
    // 콜레스테롤
    (q: '정상 총 콜레스테롤 (mg/dL)', min: 100.0, max: 400.0, answerMin: 0.0, answerMax: 200.0, unit: 'mg/dL'),
    (q: 'LDL 콜레스테롤 정상치 (mg/dL)', min: 0.0, max: 300.0, answerMin: 0.0, answerMax: 130.0, unit: 'mg/dL'),
    (q: 'HDL 콜레스테롤 정상치 (mg/dL)', min: 0.0, max: 150.0, answerMin: 40.0, answerMax: 150.0, unit: 'mg/dL'),
    (q: '정상 중성지방 (mg/dL)', min: 0.0, max: 500.0, answerMin: 0.0, answerMax: 150.0, unit: 'mg/dL'),
    // 갑상선·호르몬
    (q: '정상 TSH 범위 (μIU/mL)', min: 0.0, max: 10.0, answerMin: 0.4, answerMax: 4.0, unit: 'μIU/mL'),
    (q: '정상 비타민 D 수치 (ng/mL)', min: 0.0, max: 100.0, answerMin: 30.0, answerMax: 100.0, unit: 'ng/mL'),
    (q: '정상 요산 수치 (mg/dL)', min: 0.0, max: 15.0, answerMin: 2.5, answerMax: 7.0, unit: 'mg/dL'),
  ];
  late List<({String q, double min, double max, double answerMin, double answerMax, String unit})> _quizzes;

  int _index = 0;
  int _totalScore = 0;
  double _userMin = 0;
  double _userMax = 0;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _quizzes = (List.of(_allQuizzes)..shuffle(Random())).take(5).toList();
    _initQuestion();
  }

  void _initQuestion() {
    final q = _quizzes[_index];
    _userMin = q.min + (q.max - q.min) * 0.3;
    _userMax = q.min + (q.max - q.min) * 0.7;
    _submitted = false;
  }

  int _calcScore() {
    final q = _quizzes[_index];
    final range = q.max - q.min;
    final minDiff = (_userMin - q.answerMin).abs() / range;
    final maxDiff = (_userMax - q.answerMax).abs() / range;
    final accuracy = 1.0 - ((minDiff + maxDiff) / 2).clamp(0.0, 1.0);
    return (accuracy * 100).round();
  }

  void _submit() {
    final score = _calcScore();
    _totalScore += score;
    // 80점 이상 성공음, 미만 실패음
    score >= 80 ? _CardSound.match() : _CardSound.mismatch();
    setState(() => _submitted = true);
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      if (_index + 1 >= _quizzes.length) {
        final avg = _totalScore ~/ _quizzes.length;
        _CardSound.complete();
        widget.onGameEnd(avg);
        _showResult(avg);
      } else {
        setState(() { _index++; _initQuestion(); });
      }
    });
  }

  void _showResult(int score) {
    showDialog(
      context: context, barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(score >= 80 ? '🎉 건강 박사!' : score >= 60 ? '👍 잘 알고 있어요!' : '📚 더 공부해봐요!',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text('평균 점수: $score점'),
        actions: [
          TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text('나가기')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() { _index = 0; _totalScore = 0; _initQuestion(); });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text('다시하기', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = _quizzes[_index];
    final score = _submitted ? _calcScore() : null;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87), onPressed: () => Navigator.pop(context)),
        title: const Text('수치 범위 맞추기', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        actions: [Center(child: Padding(padding: const EdgeInsets.only(right: 16),
            child: Text('${_index + 1}/${_quizzes.length}', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold))))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          LinearProgressIndicator(value: (_index + 1) / _quizzes.length, color: Colors.teal, backgroundColor: Colors.teal.shade100),
          const SizedBox(height: 24),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10)]),
            child: Text(q.q, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ),
          const SizedBox(height: 24),
          Text('최솟값: ${_userMin.toStringAsFixed(1)} ${q.unit}',
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.teal)),
          Slider(value: _userMin, min: q.min, max: q.max - 1, activeColor: Colors.teal,
              onChanged: _submitted ? null : (v) => setState(() => _userMin = v < _userMax ? v : _userMax - 1)),
          Text('최댓값: ${_userMax.toStringAsFixed(1)} ${q.unit}',
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.teal)),
          Slider(value: _userMax, min: q.min + 1, max: q.max, activeColor: Colors.teal,
              onChanged: _submitted ? null : (v) => setState(() => _userMax = v > _userMin ? v : _userMin + 1)),
          if (_submitted) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: score! >= 80 ? Colors.green.shade50 : score >= 50 ? Colors.orange.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: score >= 80 ? Colors.green : score >= 50 ? Colors.orange : Colors.red),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('정답: ${q.answerMin.toStringAsFixed(1)} ~ ${q.answerMax.toStringAsFixed(1)} ${q.unit}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('내 답: ${_userMin.toStringAsFixed(1)} ~ ${_userMax.toStringAsFixed(1)} ${q.unit}',
                    style: TextStyle(color: Colors.grey.shade600)),
                Text('정확도: $score점', style: TextStyle(
                    color: score >= 80 ? Colors.green : score >= 50 ? Colors.orange : Colors.red,
                    fontWeight: FontWeight.bold)),
              ]),
            ),
          ],
          const Spacer(),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: _submitted ? null : _submit,
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal, padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('확인', style: TextStyle(color: Colors.white, fontSize: 16)),
          )),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }
}