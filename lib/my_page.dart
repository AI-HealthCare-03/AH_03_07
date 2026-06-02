import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'services/user_service.dart';
import 'services/ocr_service.dart';
import 'services/auth_service.dart';
import 'features/consent/pages/consent_page.dart';
import 'features/guardian/pages/guardian_sharing_page.dart';
import 'features/medication/pages/medication_add_page.dart';
import 'settings_page.dart';
import 'core/logging/app_logger.dart';
import 'core/api/api_client.dart';
import 'features/room/pages/room_page.dart';
import 'user_edit_page.dart';
import 'ocr_history_page.dart';
import 'notification_toggle_page.dart';
import 'pill_page.dart';
import 'contents_page.dart';
import 'main.dart';
import 'features/gamification/services/gamification_service.dart';
import 'features/gamification/widgets/point_card_widget.dart';
import 'features/gamification/pages/gamification_page.dart';
import 'features/game/pages/game_pages.dart';

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
          _MenuItem(icon: Icons.medication_liquid_outlined, label: '약품 인식', route: 'pill_recognize'),
          _MenuItem(icon: Icons.play_circle_outline, label: '콘텐츠 변환 내역', route: 'contents'),
        ]
      : [
          _MenuItem(icon: Icons.description_outlined, label: '진료 기록', route: 'medical_records'),
          _MenuItem(icon: Icons.medication_outlined, label: '약물 목록', route: 'medication_list'),
          _MenuItem(icon: Icons.monitor_heart_outlined, label: '건강 수치 기록', route: 'health_metrics'),
          _MenuItem(icon: Icons.folder_outlined, label: '문서 보관함', route: 'documents'),
          _MenuItem(icon: Icons.medication_liquid_outlined, label: '약품 인식', route: 'pill_recognize'),
          _MenuItem(icon: Icons.play_circle_outline, label: '콘텐츠 변환 내역', route: 'contents'),
        ];

  List<_MenuItem> get _appSettingsMenuItems => [
        _MenuItem(icon: Icons.videogame_asset_outlined, label: '오늘의 활동', route: 'game'),
        _MenuItem(icon: Icons.notifications_none_outlined, label: '알림 설정', route: 'notification_settings'),
        _MenuItem(icon: Icons.swap_horiz_outlined, label: '모드 전환', route: 'mode_switch'),
        _MenuItem(icon: Icons.people_outline, label: '보호자 공유', route: 'guardian_sharing'),
        _MenuItem(icon: Icons.policy_outlined, label: '동의 관리', route: 'consent'),
        _MenuItem(icon: Icons.settings_outlined, label: '설정', route: 'settings'),
      ];

  List<_MenuItem> get _supportMenuItems => [
        _MenuItem(icon: Icons.help_outline, label: '도움말', route: 'help'),
        _MenuItem(icon: Icons.campaign_outlined, label: '문의하기', route: 'contact'),
        _MenuItem(icon: Icons.logout, label: '로그아웃', route: 'logout', isDestructive: true),
        _MenuItem(icon: Icons.person_remove_outlined, label: '회원탈퇴', route: 'withdraw', isDestructive: true),
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
    if (route == 'withdraw') { _confirmWithdraw(); return; }
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
    if (route == 'consent') {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => ConsentPage(
          apiClient: ApiClient(storage: widget.tokenStorage),
        ),
      ));
      return;
    }
    if (route == 'pill_recognize') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const PillRecognizePage()));
      return;
    }
    if (route == 'contents') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ContentsPage()));
      return;
    }
    if (route == 'game') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const GamePage()));
      return;
    }
    if (route == 'guardian_sharing') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const GuardianSharingPage()));
      return;
    }
    if (route == 'medication_add') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicationAddPage()));
      return;
    }
    if (route == 'settings') {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => SettingsPage(onLogout: widget.onLogout),
      ));
      return;
    }
    logger.debug(LogCategory.userAction, 'Navigate: $route');
  }

  void _confirmWithdraw() {
    final reasons = ['서비스가 필요 없어졌어요', '다른 앱을 사용할 예정이에요', '개인정보가 걱정돼요', '기타'];
    String? selectedReason;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 22),
              SizedBox(width: 8),
              Text('회원탈퇴', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: Colors.red)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '탈퇴 시 모든 의료 기록, 가이드, OCR 데이터가\n즉시 삭제되며 복구가 불가능합니다.',
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              const Text('탈퇴 사유 (선택)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              ...reasons.map((r) => RadioListTile<String>(
                    dense: true,
                    value: r,
                    groupValue: selectedReason,
                    onChanged: (v) => setDialog(() => selectedReason = v),
                    title: Text(r, style: const TextStyle(fontSize: 13)),
                    contentPadding: EdgeInsets.zero,
                    activeColor: Colors.red,
                  )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await _doWithdraw(selectedReason);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('탈퇴하기', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _doWithdraw(String? reason) async {
    try {
      final authService = AuthService(tokenStorage: widget.tokenStorage);
      logger.logWithdraw(reason);
      await authService.withdraw(reason: reason);
      authService.dispose();
      if (mounted) widget.onLogout?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('탈퇴 실패: $e'), backgroundColor: Colors.red),
        );
      }
    }
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
            backgroundColor: const Color(0xFF22C55E),
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
              color: const Color(0xFF22C55E),
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
          colors: [Color(0xFF22C55E), Color(0xFF4ADE80)],
          begin: Alignment.centerLeft, end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
          color: const Color(0xFF22C55E).withValues(alpha: 0.3),
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
