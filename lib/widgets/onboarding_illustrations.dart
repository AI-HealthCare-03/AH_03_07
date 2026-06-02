import 'package:flutter/material.dart';

// 온보딩/스플래시용 컬러 일러스트 (CustomPainter — 웹에서도 컬러 렌더링)

Paint _fill(Color c) => Paint()..color = c..style = PaintingStyle.fill;
Paint _stroke(Color c, double w) =>
    Paint()..color = c..style = PaintingStyle.stroke..strokeWidth = w
      ..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;

const _green = Color(0xFF22C55E);
const _greenLight = Color(0xFF86EFAC);
const _greenPale = Color(0xFFBBF7D0);

// ══════════════════════════════════════════════════════════
// 스플래시 — 체크 표시 알약
// ══════════════════════════════════════════════════════════
class PillCheckIllustration extends StatelessWidget {
  final double size;
  const PillCheckIllustration({super.key, this.size = 140});

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: size, height: size, child: CustomPaint(painter: _PillCheckPainter()));
}

class _PillCheckPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final w = s.width, h = s.height;
    final cx = w * 0.5, cy = h * 0.5;

    // 그림자
    c.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.86), width: w * 0.4, height: h * 0.06),
      Paint()..color = Colors.black.withValues(alpha: 0.08),
    );

    // 캡슐 (15도 기울임)
    c.save();
    c.translate(cx, cy);
    c.rotate(0.26); // ~15도
    c.translate(-cx, -cy);

    final capRect = Rect.fromCenter(center: Offset(cx, cy), width: w * 0.42, height: w * 0.72);
    final rrect = RRect.fromRectAndRadius(capRect, Radius.circular(w * 0.21));

    // 아래쪽(초록)
    c.drawRRect(rrect, _fill(_green));
    // 위쪽(연한) — 위 절반 클립
    c.save();
    c.clipRect(Rect.fromLTWH(capRect.left, capRect.top, capRect.width, capRect.height * 0.5));
    c.drawRRect(rrect, _fill(const Color(0xFFE8FCEF)));
    c.restore();

    // 하이라이트
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx - w * 0.06, cy - h * 0.12), width: w * 0.08, height: w * 0.3),
        Radius.circular(w * 0.04)),
      _fill(Colors.white.withValues(alpha: 0.5)),
    );
    c.restore();

    // 체크 표시
    final check = Path()
      ..moveTo(cx - w * 0.1, cy + h * 0.02)
      ..lineTo(cx - w * 0.02, cy + h * 0.1)
      ..lineTo(cx + w * 0.14, cy - h * 0.08);
    c.drawPath(check, _stroke(Colors.white, w * 0.05));
  }

  @override
  bool shouldRepaint(_) => false;
}

// ══════════════════════════════════════════════════════════
// 온보딩 1 — 두 개의 알약
// ══════════════════════════════════════════════════════════
class TwoPillsIllustration extends StatelessWidget {
  final double size;
  const TwoPillsIllustration({super.key, this.size = 160});

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: size, height: size, child: CustomPaint(painter: _TwoPillsPainter()));
}

class _TwoPillsPainter extends CustomPainter {
  void _capsule(Canvas c, Offset center, double angle, double len, double thick, Color main, Color light) {
    c.save();
    c.translate(center.dx, center.dy);
    c.rotate(angle);
    final r = Rect.fromCenter(center: Offset.zero, width: thick, height: len);
    final rr = RRect.fromRectAndRadius(r, Radius.circular(thick / 2));
    c.drawRRect(rr, _fill(main));
    c.save();
    c.clipRect(Rect.fromLTWH(r.left, r.top, r.width, r.height / 2));
    c.drawRRect(rr, _fill(light));
    c.restore();
    // 하이라이트
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(-thick * 0.2, -len * 0.2), width: thick * 0.18, height: len * 0.4),
        Radius.circular(thick * 0.1)),
      _fill(Colors.white.withValues(alpha: 0.45)),
    );
    c.restore();
  }

  @override
  void paint(Canvas c, Size s) {
    final w = s.width, h = s.height;
    // 뒤 알약 (연두)
    _capsule(c, Offset(w * 0.4, h * 0.42), -0.7, w * 0.5, w * 0.26, _greenLight, const Color(0xFFD9FBE5));
    // 앞 알약 (진초록)
    _capsule(c, Offset(w * 0.58, h * 0.58), -0.7, w * 0.52, w * 0.27, _green, const Color(0xFFBBF7D0));
  }

  @override
  bool shouldRepaint(_) => false;
}

// ══════════════════════════════════════════════════════════
// 온보딩 2 — 일지/기록
// ══════════════════════════════════════════════════════════
class DiaryIllustration extends StatelessWidget {
  final double size;
  const DiaryIllustration({super.key, this.size = 160});

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: size, height: size, child: CustomPaint(painter: _DiaryPainter()));
}

class _DiaryPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final w = s.width, h = s.height;
    // 노트 본체
    final note = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.22, h * 0.18, w * 0.56, h * 0.64), Radius.circular(w * 0.06));
    c.drawRRect(note, _fill(Colors.white));
    c.drawRRect(note, _stroke(_greenPale, w * 0.02));
    // 상단 초록 바
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.22, h * 0.18, w * 0.56, h * 0.12),
        Radius.circular(w * 0.06)),
      _fill(_green));
    // 줄들
    for (var i = 0; i < 3; i++) {
      c.drawLine(Offset(w * 0.3, h * (0.42 + i * 0.12)), Offset(w * 0.62, h * (0.42 + i * 0.12)),
          _stroke(_greenPale, w * 0.025));
    }
    // 체크 동그라미
    c.drawCircle(Offset(w * 0.68, h * 0.66), w * 0.06, _fill(_green));
    final ch = Path()
      ..moveTo(w * 0.655, h * 0.66)
      ..lineTo(w * 0.675, h * 0.68)
      ..lineTo(w * 0.71, h * 0.64);
    c.drawPath(ch, _stroke(Colors.white, w * 0.018));
    // 연필
    c.save();
    c.translate(w * 0.74, h * 0.32);
    c.rotate(0.7);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: w * 0.06, height: w * 0.3), Radius.circular(w * 0.02)), _fill(const Color(0xFFFFD54F)));
    c.restore();
  }

  @override
  bool shouldRepaint(_) => false;
}

// ══════════════════════════════════════════════════════════
// 온보딩 3 — 의료진/문서 공유
// ══════════════════════════════════════════════════════════
class MedicalShareIllustration extends StatelessWidget {
  final double size;
  const MedicalShareIllustration({super.key, this.size = 160});

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: size, height: size, child: CustomPaint(painter: _MedicalSharePainter()));
}

class _MedicalSharePainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final w = s.width, h = s.height;
    // 중앙 문서
    final doc = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.32, h * 0.28, w * 0.36, h * 0.46), Radius.circular(w * 0.04));
    c.drawRRect(doc, _fill(Colors.white));
    c.drawRRect(doc, _stroke(_greenPale, w * 0.018));
    // 십자 (의료)
    final plus = _fill(_green);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.37, h * 0.32, w * 0.07, w * 0.025), const Radius.circular(2)), plus);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.395, h * 0.295, w * 0.025, w * 0.07), const Radius.circular(2)), plus);
    // 심전도 라인
    final ecg = Path()
      ..moveTo(w * 0.36, h * 0.46)
      ..lineTo(w * 0.42, h * 0.46)
      ..lineTo(w * 0.45, h * 0.4)
      ..lineTo(w * 0.48, h * 0.52)
      ..lineTo(w * 0.51, h * 0.46)
      ..lineTo(w * 0.64, h * 0.46);
    c.drawPath(ecg, _stroke(_green, w * 0.02));
    // 텍스트 줄
    for (var i = 0; i < 2; i++) {
      c.drawLine(Offset(w * 0.37, h * (0.56 + i * 0.06)), Offset(w * 0.6, h * (0.56 + i * 0.06)), _stroke(_greenPale, w * 0.02));
    }
    // 하트
    _heart(c, Offset(w * 0.6, h * 0.68), w * 0.025, _green);
    // 의사 아이콘 (우상단 원)
    c.drawCircle(Offset(w * 0.72, h * 0.3), w * 0.09, _fill(_greenLight));
    c.drawCircle(Offset(w * 0.72, h * 0.27), w * 0.035, _fill(Colors.white));
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.69, h * 0.30, w * 0.06, w * 0.05), Radius.circular(w * 0.02)), _fill(Colors.white));
    // 막대그래프 (좌하단 원)
    c.drawCircle(Offset(w * 0.26, h * 0.6), w * 0.08, _fill(_greenLight));
    for (var i = 0; i < 3; i++) {
      c.drawRect(Rect.fromLTWH(w * (0.215 + i * 0.03), h * (0.62 - i * 0.012), w * 0.018, h * (0.03 + i * 0.012)), _fill(Colors.white));
    }
    // 파이 (우하단 원)
    c.drawCircle(Offset(w * 0.74, h * 0.6), w * 0.08, _fill(_green));
    c.drawCircle(Offset(w * 0.74, h * 0.6), w * 0.05, _fill(Colors.white));
    c.drawCircle(Offset(w * 0.74, h * 0.6), w * 0.05,
        Paint()..color = _green..style = PaintingStyle.stroke..strokeWidth = w * 0.02);
    // 연결선
    final line = _stroke(_greenPale, w * 0.012);
    c.drawLine(Offset(w * 0.32, h * 0.55), Offset(w * 0.3, h * 0.58), line);
    c.drawLine(Offset(w * 0.68, h * 0.38), Offset(w * 0.7, h * 0.36), line);
    c.drawLine(Offset(w * 0.68, h * 0.55), Offset(w * 0.71, h * 0.58), line);
  }

  void _heart(Canvas c, Offset center, double r, Color color) {
    final p = Path();
    p.moveTo(center.dx, center.dy + r * 0.6);
    p.cubicTo(center.dx - r * 1.5, center.dy - r * 0.5, center.dx - r * 0.5, center.dy - r * 1.2, center.dx, center.dy - r * 0.3);
    p.cubicTo(center.dx + r * 0.5, center.dy - r * 1.2, center.dx + r * 1.5, center.dy - r * 0.5, center.dx, center.dy + r * 0.6);
    c.drawPath(p, _fill(color));
  }

  @override
  bool shouldRepaint(_) => false;
}
