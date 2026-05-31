import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'services/auth_service.dart';
import 'main.dart';
import 'login_page.dart';
import 'onboarding_page.dart';
import 'home_page.dart';
import 'widgets/helcy_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final AuthService _authService;
  late final SecureTokenStorage _tokenStorage;
  Timer? _minTimer;
  bool _minTimerDone = false;
  bool _authCheckDone = false;
  bool? _isLoggedIn;
  bool _hasSeenOnboarding = false;

  static const _minSplashMs = 2000;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();

    _tokenStorage = SecureTokenStorage();
    _authService = AuthService(tokenStorage: _tokenStorage);

    _minTimer = Timer(const Duration(milliseconds: _minSplashMs), () {
      _minTimerDone = true;
      _tryNavigate();
    });

    _checkStatus();
  }

  Future<void> _checkStatus() async {
    try {
      final storage = const FlutterSecureStorage();
      final onboardingDone =
          await storage.read(key: 'onboarding_done').then((v) => v == 'true');
      _hasSeenOnboarding = onboardingDone;

      // 명시적 로그아웃 플래그 확인 — 로그아웃 버튼을 눌렀으면 항상 로그인 화면
      final explicitlyLoggedOut = await _tokenStorage.isExplicitlyLoggedOut();
      if (explicitlyLoggedOut) {
        _isLoggedIn = false;
      } else {
        final accessToken = await _tokenStorage.getAccessToken();
        if (accessToken == null || accessToken.isEmpty) {
          _isLoggedIn = false;
        } else {
          // P2: 로컬 만료 우선 체크
          final isLocallyExpired = _isTokenLocallyExpired(accessToken);
          try {
            _isLoggedIn = await _authService.isLoggedIn()
                .timeout(const Duration(seconds: 3));
          } catch (_) {
            // 네트워크 오류: 만료된 토큰이면 재로그인, 유효하면 유지
            if (isLocallyExpired) {
              await _tokenStorage.deleteAll();
              _isLoggedIn = false;
            } else {
              _isLoggedIn = true;
            }
          }
        }
      }
    } catch (_) {
      _isLoggedIn = false;
      _hasSeenOnboarding = false;
    } finally {
      _authCheckDone = true;
      _tryNavigate();
    }
  }

  bool _isTokenLocallyExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final exp = (jsonDecode(payload) as Map)['exp'] as int?;
      if (exp == null) return true;
      return DateTime.now().millisecondsSinceEpoch ~/ 1000 >= exp;
    } catch (_) {
      return true;
    }
  }

  void _tryNavigate() {
    if (!_minTimerDone || !_authCheckDone) return;
    if (!mounted) return;

    if (!_hasSeenOnboarding) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const OnboardingPage(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    } else if (_isLoggedIn == true) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomePage(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => LoginPage(
            onLoginSuccess: () {
              if (!mounted) return;
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const HomePage(),
                  transitionsBuilder: (_, anim, __, child) =>
                      FadeTransition(opacity: anim, child: child),
                  transitionDuration: const Duration(milliseconds: 400),
                ),
              );
            },
          ),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _minTimer?.cancel();
    _authService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const HelcyWidget(level: 3, mood: HelcyMood.waving, size: 140),
              const SizedBox(height: 16),
              const Text(
                'MediGuide',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF8C00),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '복약을 한눈에',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              const Text(
                '헬씨와 함께 건강을 관리해요! 👋',
                style: TextStyle(fontSize: 13, color: Color(0xFFFF8C00)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}