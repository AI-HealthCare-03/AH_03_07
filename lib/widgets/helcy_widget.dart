import 'dart:math' as math;
import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════
// 헬씨(Helcy) — 앱 마스코트 캐릭터
// 레벨별 성장, 상황별 표정 변화 지원
// ══════════════════════════════════════════════════════════

enum HelcyMood { happy, excited, sad, neutral, waving }

class HelcyWidget extends StatelessWidget {
  final int level;       // 1~5
  final HelcyMood mood;
  final double size;

  const HelcyWidget({
    super.key,
    this.level = 1,
    this.mood = HelcyMood.happy,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _HelcyPainter(level: level, mood: mood),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// 레벨별 색상
// ──────────────────────────────────────────────────────────
Color _bodyColor(int level) {
  switch (level) {
    case 1: return const Color(0xFF90CAF9); // 연파랑 - 씨앗
    case 2: return const Color(0xFF80CBC4); // 민트 - 새싹
    case 3: return const Color(0xFF81C784); // 초록 - 어린이
    case 4: return const Color(0xFFFFB74D); // 주황 - 청년
    case 5: return const Color(0xFFFF7043); // 진주황 - 영웅
    default: return const Color(0xFF90CAF9);
  }
}

Color _accentColor(int level) {
  switch (level) {
    case 1: return const Color(0xFF42A5F5);
    case 2: return const Color(0xFF26A69A);
    case 3: return const Color(0xFF43A047);
    case 4: return const Color(0xFFFB8C00);
    case 5: return const Color(0xFFE64A19);
    default: return const Color(0xFF42A5F5);
  }
}

// ──────────────────────────────────────────────────────────
// CustomPainter
// ──────────────────────────────────────────────────────────
class _HelcyPainter extends CustomPainter {
  final int level;
  final HelcyMood mood;

  const _HelcyPainter({required this.level, required this.mood});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width * 0.38;

    _drawBody(canvas, cx, cy, r);
    _drawFace(canvas, cx, cy, r);
    _drawAccessory(canvas, cx, cy, r, size);
    if (mood == HelcyMood.waving) _drawWavingArm(canvas, cx, cy, r);
    if (level >= 4) _drawStar(canvas, cx, cy - r * 1.3, r * 0.18);
  }

  // ── 몸통 ──
  void _drawBody(Canvas canvas, double cx, double cy, double r) {
    final body = Paint()..color = _bodyColor(level);
    final shadow = Paint()..color = Colors.black12;

    // 그림자
    canvas.drawCircle(Offset(cx + 2, cy + 4), r, shadow);
    // 메인 몸
    canvas.drawCircle(Offset(cx, cy), r, body);

    // 레벨별 추가 요소
    if (level >= 2) {
      // 귀 (level 2+)
      final ear = Paint()..color = _accentColor(level);
      canvas.drawCircle(Offset(cx - r * 0.75, cy - r * 0.6), r * 0.22, ear);
      canvas.drawCircle(Offset(cx + r * 0.75, cy - r * 0.6), r * 0.22, ear);
    }
    if (level >= 3) {
      // 볼 터치
      final cheek = Paint()..color = Colors.pink.withValues(alpha: 0.35);
      canvas.drawCircle(Offset(cx - r * 0.55, cy + r * 0.15), r * 0.2, cheek);
      canvas.drawCircle(Offset(cx + r * 0.55, cy + r * 0.15), r * 0.2, cheek);
    }
    if (level >= 5) {
      // 몸 테두리 발광
      final glow = Paint()
        ..color = _accentColor(level).withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      canvas.drawCircle(Offset(cx, cy), r + 4, glow);
    }
  }

  // ── 얼굴 ──
  void _drawFace(Canvas canvas, double cx, double cy, double r) {
    final eyePaint = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = const Color(0xFF1A237E);
    final eyeL = Offset(cx - r * 0.28, cy - r * 0.1);
    final eyeR = Offset(cx + r * 0.28, cy - r * 0.1);
    final eyeR_ = r * 0.16;
    final pupilR = r * 0.09;

    // 눈
    canvas.drawCircle(eyeL, eyeR_, eyePaint);
    canvas.drawCircle(eyeR, eyeR_, eyePaint);

    // 동공 (mood에 따라 위치 변경)
    final dy = mood == HelcyMood.sad ? pupilR * 0.5 : -pupilR * 0.3;
    canvas.drawCircle(Offset(eyeL.dx, eyeL.dy + dy), pupilR, pupilPaint);
    canvas.drawCircle(Offset(eyeR.dx, eyeR.dy + dy), pupilR, pupilPaint);

    // 반짝이 하이라이트
    final shine = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(eyeL.dx - pupilR * 0.5, eyeL.dy + dy - pupilR * 0.4), pupilR * 0.35, shine);
    canvas.drawCircle(Offset(eyeR.dx - pupilR * 0.5, eyeR.dy + dy - pupilR * 0.4), pupilR * 0.35, shine);

    // 기분에 따른 눈썹
    _drawEyebrows(canvas, eyeL, eyeR, r);

    // 입
    _drawMouth(canvas, cx, cy, r);
  }

  void _drawEyebrows(Canvas canvas, Offset eyeL, Offset eyeR, double r) {
    final brow = Paint()
      ..color = const Color(0xFF1A237E)
      ..strokeWidth = r * 0.08
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final bh = r * 0.22; // 눈썹 높이
    switch (mood) {
      case HelcyMood.excited:
      case HelcyMood.waving:
        // 위로 올라간 눈썹
        canvas.drawArc(Rect.fromCenter(center: Offset(eyeL.dx, eyeL.dy - bh), width: r * 0.3, height: r * 0.2), math.pi, math.pi, false, brow);
        canvas.drawArc(Rect.fromCenter(center: Offset(eyeR.dx, eyeR.dy - bh), width: r * 0.3, height: r * 0.2), math.pi, math.pi, false, brow);
      case HelcyMood.sad:
        // 처진 눈썹
        canvas.drawArc(Rect.fromCenter(center: Offset(eyeL.dx, eyeL.dy - bh), width: r * 0.3, height: r * 0.2), 0, math.pi, false, brow);
        canvas.drawArc(Rect.fromCenter(center: Offset(eyeR.dx, eyeR.dy - bh), width: r * 0.3, height: r * 0.2), 0, math.pi, false, brow);
      default:
        // 기본 직선
        canvas.drawLine(Offset(eyeL.dx - r * 0.12, eyeL.dy - bh), Offset(eyeL.dx + r * 0.12, eyeL.dy - bh), brow);
        canvas.drawLine(Offset(eyeR.dx - r * 0.12, eyeR.dy - bh), Offset(eyeR.dx + r * 0.12, eyeR.dy - bh), brow);
    }
  }

  void _drawMouth(Canvas canvas, double cx, double cy, double r) {
    final mouth = Paint()
      ..color = const Color(0xFF1A237E)
      ..strokeWidth = r * 0.08
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final my = cy + r * 0.28;
    switch (mood) {
      case HelcyMood.excited:
        // 크게 웃는 입 (채워진 반원)
        final fill = Paint()..color = Colors.white;
        canvas.drawArc(Rect.fromCenter(center: Offset(cx, my), width: r * 0.55, height: r * 0.4), 0, math.pi, true, fill);
        canvas.drawArc(Rect.fromCenter(center: Offset(cx, my), width: r * 0.55, height: r * 0.4), 0, math.pi, false, mouth);
      case HelcyMood.sad:
        // 슬픈 입
        canvas.drawArc(Rect.fromCenter(center: Offset(cx, my + r * 0.1), width: r * 0.4, height: r * 0.25), math.pi, math.pi, false, mouth);
      case HelcyMood.neutral:
        // 직선 입
        canvas.drawLine(Offset(cx - r * 0.18, my), Offset(cx + r * 0.18, my), mouth);
      default:
        // 보통 미소
        canvas.drawArc(Rect.fromCenter(center: Offset(cx, my), width: r * 0.4, height: r * 0.25), 0, math.pi, false, mouth);
    }
  }

  // ── 액세서리 (레벨별) ──
  void _drawAccessory(Canvas canvas, double cx, double cy, double r, Size size) {
    if (level == 1) {
      // 씨앗 - 작은 잎사귀
      final leaf = Paint()..color = const Color(0xFF81C784);
      final path = Path()
        ..moveTo(cx, cy - r - 2)
        ..quadraticBezierTo(cx + r * 0.3, cy - r * 1.25, cx, cy - r * 1.5)
        ..quadraticBezierTo(cx - r * 0.3, cy - r * 1.25, cx, cy - r - 2)
        ..close();
      canvas.drawPath(path, leaf);
    } else if (level == 2) {
      // 새싹 - 청진기
      _drawStethoscope(canvas, cx, cy, r);
    } else if (level == 3) {
      // 어린이 - 의사 가운 + 청진기
      _drawStethoscope(canvas, cx, cy, r);
      _drawCollar(canvas, cx, cy, r);
    } else if (level == 4) {
      // 청년 - 왕관 + 청진기
      _drawCrown(canvas, cx, cy, r);
      _drawStethoscope(canvas, cx, cy, r);
    } else if (level == 5) {
      // 영웅 - 왕관 + 망토 + 청진기
      _drawCrown(canvas, cx, cy, r);
      _drawCape(canvas, cx, cy, r, size);
      _drawStethoscope(canvas, cx, cy, r);
    }
  }

  void _drawStethoscope(Canvas canvas, double cx, double cy, double r) {
    final stet = Paint()
      ..color = const Color(0xFF37474F)
      ..strokeWidth = r * 0.07
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final disk = Paint()..color = const Color(0xFF78909C);

    final startX = cx + r * 0.4;
    final startY = cy + r * 0.25;
    final path = Path()
      ..moveTo(startX, startY)
      ..quadraticBezierTo(startX + r * 0.4, startY + r * 0.3, startX + r * 0.15, startY + r * 0.6);
    canvas.drawPath(path, stet);
    canvas.drawCircle(Offset(startX + r * 0.15, startY + r * 0.6), r * 0.1, disk);
  }

  void _drawCollar(Canvas canvas, double cx, double cy, double r) {
    final collar = Paint()..color = Colors.white.withValues(alpha: 0.8);
    final path = Path()
      ..moveTo(cx - r * 0.3, cy + r * 0.7)
      ..lineTo(cx, cy + r * 0.5)
      ..lineTo(cx + r * 0.3, cy + r * 0.7)
      ..close();
    canvas.drawPath(path, collar);
  }

  void _drawCrown(Canvas canvas, double cx, double cy, double r) {
    final crown = Paint()..color = const Color(0xFFFFD700);
    final outline = Paint()
      ..color = const Color(0xFFFFA000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final top = cy - r * 1.1;
    final path = Path()
      ..moveTo(cx - r * 0.35, top + r * 0.25)
      ..lineTo(cx - r * 0.35, top)
      ..lineTo(cx - r * 0.17, top + r * 0.15)
      ..lineTo(cx, top - r * 0.1)
      ..lineTo(cx + r * 0.17, top + r * 0.15)
      ..lineTo(cx + r * 0.35, top)
      ..lineTo(cx + r * 0.35, top + r * 0.25)
      ..close();
    canvas.drawPath(path, crown);
    canvas.drawPath(path, outline);

    // 보석
    final gem = Paint()..color = Colors.red;
    canvas.drawCircle(Offset(cx, top - r * 0.05), r * 0.065, gem);
  }

  void _drawCape(Canvas canvas, double cx, double cy, double r, Size size) {
    final cape = Paint()..color = _accentColor(level).withValues(alpha: 0.8);
    final path = Path()
      ..moveTo(cx - r * 0.7, cy)
      ..quadraticBezierTo(cx - r * 1.1, cy + r * 0.8, cx - r * 0.5, cy + r * 1.2)
      ..lineTo(cx + r * 0.5, cy + r * 1.2)
      ..quadraticBezierTo(cx + r * 1.1, cy + r * 0.8, cx + r * 0.7, cy)
      ..close();
    canvas.drawPath(path, cape);
  }

  void _drawWavingArm(Canvas canvas, double cx, double cy, double r) {
    final arm = Paint()
      ..color = _bodyColor(level)
      ..strokeWidth = r * 0.22
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(cx + r * 0.75, cy - r * 0.1)
      ..quadraticBezierTo(cx + r * 1.1, cy - r * 0.5, cx + r * 0.9, cy - r * 0.9);
    canvas.drawPath(path, arm);

    // 손
    final hand = Paint()..color = _bodyColor(level);
    canvas.drawCircle(Offset(cx + r * 0.9, cy - r * 0.9), r * 0.14, hand);
  }

  void _drawStar(Canvas canvas, double cx, double cy, double r) {
    final star = Paint()..color = const Color(0xFFFFD700);
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 72 - 90) * math.pi / 180;
      final innerAngle = ((i * 72 + 36) - 90) * math.pi / 180;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      final ix = cx + r * 0.4 * math.cos(innerAngle);
      final iy = cy + r * 0.4 * math.sin(innerAngle);
      if (i == 0) { path.moveTo(x, y); } else { path.lineTo(x, y); }
      path.lineTo(ix, iy);
    }
    path.close();
    canvas.drawPath(path, star);
  }

  @override
  bool shouldRepaint(_HelcyPainter old) =>
      old.level != level || old.mood != mood;
}

// ──────────────────────────────────────────────────────────
// 헬씨 말풍선 위젯
// ──────────────────────────────────────────────────────────
class HelcyWithBubble extends StatelessWidget {
  final int level;
  final HelcyMood mood;
  final String message;
  final double size;

  const HelcyWithBubble({
    super.key,
    this.level = 1,
    this.mood = HelcyMood.happy,
    required this.message,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        HelcyWidget(level: level, mood: mood, size: size),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────
// 레벨별 이름과 메시지
// ──────────────────────────────────────────────────────────
class HelcyInfo {
  static String name(int level) => switch (level) {
    1 => '씨앗 헬씨',
    2 => '새싹 헬씨',
    3 => '건강이',
    4 => '건강 청년',
    _ => '건강 영웅',
  };

  static String greet(int level) => switch (level) {
    1 => '안녕! 나는 헬씨야 👋\n함께 건강해지자!',
    2 => '오늘도 건강 관리\n잘 하고 있어! 💪',
    3 => '꾸준함이 건강의 비결!\n오늘도 파이팅! 🌟',
    4 => '건강 마스터를 향해\n달려가는 중! 🔥',
    _ => '넌 이제 건강 영웅!\n모두의 롤모델이야! 👑',
  };

  static String gameWin(int level) => switch (level) {
    1 => '와! 대단해요! 🎉',
    2 => '역시 잘하는군요! 🌟',
    3 => '완벽한 실력이에요! ✨',
    4 => '역시 건강 청년답네요! 🏆',
    _ => '건강 영웅의 실력이네요! 👑',
  };

  static String gameLose(int level) => switch (level) {
    1 => '괜찮아요, 다시 해봐요! 💙',
    2 => '조금만 더 연습해요! 🌱',
    3 => '아쉽지만 다음엔 이길 거예요! 💪',
    _ => '실수는 누구나 해요!\n다시 도전! 🔥',
  };
}
