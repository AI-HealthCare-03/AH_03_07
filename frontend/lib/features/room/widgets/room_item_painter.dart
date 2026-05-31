import 'dart:math' as math;
import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════
// 색깔 있는 방 아이템 위젯
// ══════════════════════════════════════════════════════════

class RoomItemWidget extends StatelessWidget {
  final String itemId;
  final double size;

  const RoomItemWidget({super.key, required this.itemId, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _getpainter(itemId)),
    );
  }

  CustomPainter _getpainter(String id) => switch (id) {
    'bed'       => _BedPainter(),
    'sofa'      => _SofaPainter(),
    'desk'      => _DeskPainter(),
    'chair'     => _ChairPainter(),
    'bookshelf' => _BookshelfPainter(),
    'tv'        => _TvPainter(),
    'fridge'    => _FridgePainter(),
    'table'     => _TablePainter(),
    'dresser'   => _DresserPainter(),
    'piano'     => _PianoPainter(),
    'bathtub'   => _BathtubPainter(),
    'lamp'      => _LampPainter(),
    'clock'     => _ClockPainter(),
    'closet'    => _ClosetPainter(),
    'plant1'    => _PlantPainter(potColor: const Color(0xFFD84315), leafColor: const Color(0xFF43A047)),
    'cactus'    => _CactusPainter(),
    'tree'      => _TreePainter(),
    'flower'    => _FlowerPainter(),
    'dog'       => _DogPainter(),
    'cat'       => _CatPainter(),
    'hamster'   => _HamsterPainter(),
    'rabbit'    => _RabbitPainter(),
    'picture'   => _PicturePainter(),
    'cushion'   => _CushionPainter(),
    'fishtank'  => _FishtankPainter(),
    'trophy'    => _TrophyPainter(),
    'gamepad'   => _GamepadPainter(),
    'guitar'    => _GuitarPainter(),
    'carpet'    => _CarpetPainter(),
    'mirror'    => _MirrorPainter(),
    _           => _DefaultPainter(id),
  };
}

// ── 도우미 ─────────────────────────────────────────────────
Paint _fill(Color c) => Paint()..color = c..style = PaintingStyle.fill;
Paint _stroke(Color c, double w) => Paint()..color = c..style = PaintingStyle.stroke..strokeWidth = w..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;

// ══ 가구 ══════════════════════════════════════════════════

class _BedPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final w = s.width; final h = s.height;
    // 프레임
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.05, h*.35, w*.9, h*.55), const Radius.circular(6)), _fill(const Color(0xFF8D6E63)));
    // 이불
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.1, h*.38, w*.8, h*.4), const Radius.circular(8)), _fill(const Color(0xFF64B5F6)));
    // 이불 줄무늬
    for (var i = 0; i < 3; i++) {
      c.drawLine(Offset(w*.25+i*w*.2, h*.42), Offset(w*.25+i*w*.2, h*.74), _stroke(const Color(0xFF42A5F5), w*.02));
    }
    // 베개
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.12, h*.42, w*.3, h*.18), const Radius.circular(6)), _fill(Colors.white));
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.12, h*.42, w*.3, h*.18), const Radius.circular(6)), _stroke(const Color(0xFFBBDEFB), w*.02));
    // 헤드보드
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.05, h*.22, w*.9, h*.16), const Radius.circular(8)), _fill(const Color(0xFF6D4C41)));
    // 다리
    c.drawRect(Rect.fromLTWH(w*.08, h*.88, w*.1, h*.08), _fill(const Color(0xFF5D4037)));
    c.drawRect(Rect.fromLTWH(w*.82, h*.88, w*.1, h*.08), _fill(const Color(0xFF5D4037)));
  }
  @override bool shouldRepaint(_) => false;
}

class _SofaPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final w = s.width; final h = s.height;
    final color = const Color(0xFF7B1FA2);
    final dark = const Color(0xFF4A148C);
    // 등받이
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.05, h*.3, w*.9, h*.35), const Radius.circular(10)), _fill(color));
    // 방석
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.05, h*.6, w*.9, h*.25), const Radius.circular(8)), _fill(const Color(0xFF9C27B0)));
    // 팔걸이 좌
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.02, h*.4, w*.1, h*.4), const Radius.circular(6)), _fill(dark));
    // 팔걸이 우
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.88, h*.4, w*.1, h*.4), const Radius.circular(6)), _fill(dark));
    // 쿠션 2개
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.15, h*.35, w*.28, h*.22), const Radius.circular(8)), _fill(const Color(0xFFCE93D8)));
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.57, h*.35, w*.28, h*.22), const Radius.circular(8)), _fill(const Color(0xFFCE93D8)));
    // 다리
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.1, h*.83, w*.08, h*.12), const Radius.circular(3)), _fill(const Color(0xFF4E342E)));
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.82, h*.83, w*.08, h*.12), const Radius.circular(3)), _fill(const Color(0xFF4E342E)));
  }
  @override bool shouldRepaint(_) => false;
}

class _DeskPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final w = s.width; final h = s.height;
    // 상판
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.05, h*.35, w*.9, h*.12), const Radius.circular(4)), _fill(const Color(0xFFD7CCC8)));
    // 서랍장
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.62, h*.47, w*.3, h*.42), const Radius.circular(4)), _fill(const Color(0xFFBCAAA4)));
    // 서랍 손잡이
    c.drawCircle(Offset(w*.77, h*.6), w*.03, _fill(const Color(0xFF8D6E63)));
    c.drawCircle(Offset(w*.77, h*.76), w*.03, _fill(const Color(0xFF8D6E63)));
    // 모니터
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.12, h*.08, w*.4, h*.28), const Radius.circular(4)), _fill(const Color(0xFF37474F)));
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.15, h*.11, w*.34, h*.22), const Radius.circular(2)), _fill(const Color(0xFF4FC3F7)));
    c.drawRect(Rect.fromLTWH(w*.29, h*.36, w*.06, h*.08), _fill(const Color(0xFF546E7A)));
    // 다리
    c.drawRect(Rect.fromLTWH(w*.08, h*.47, w*.06, h*.42), _fill(const Color(0xFF8D6E63)));
    c.drawRect(Rect.fromLTWH(w*.6, h*.47, w*.06, h*.42), _fill(const Color(0xFF8D6E63)));
  }
  @override bool shouldRepaint(_) => false;
}

class _ChairPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final w = s.width; final h = s.height;
    // 등받이
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.2, h*.1, w*.6, h*.38), const Radius.circular(8)), _fill(const Color(0xFF1565C0)));
    // 방석
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.15, h*.46, w*.7, h*.22), const Radius.circular(8)), _fill(const Color(0xFF1976D2)));
    // 다리
    c.drawLine(Offset(w*.22, h*.68), Offset(w*.15, h*.95), _stroke(const Color(0xFF424242), w*.05));
    c.drawLine(Offset(w*.78, h*.68), Offset(w*.85, h*.95), _stroke(const Color(0xFF424242), w*.05));
    c.drawLine(Offset(w*.3, h*.68), Offset(w*.25, h*.95), _stroke(const Color(0xFF424242), w*.05));
    c.drawLine(Offset(w*.7, h*.68), Offset(w*.75, h*.95), _stroke(const Color(0xFF424242), w*.05));
  }
  @override bool shouldRepaint(_) => false;
}

class _BookshelfPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final w = s.width; final h = s.height;
    // 선반 틀
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.05, h*.05, w*.9, h*.9), const Radius.circular(4)), _fill(const Color(0xFF8D6E63)));
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.1, h*.08, w*.8, h*.84), const Radius.circular(2)), _fill(const Color(0xFFF5F5F5)));
    // 선반 판
    for (var i = 0; i < 3; i++) {
      c.drawRect(Rect.fromLTWH(w*.08, h*.08+i*h*.28, w*.84, h*.04), _fill(const Color(0xFF8D6E63)));
    }
    // 책들
    final bookColors = [const Color(0xFFEF5350), const Color(0xFF42A5F5), const Color(0xFF66BB6A), const Color(0xFFFFCA28), const Color(0xFFAB47BC)];
    for (var row = 0; row < 3; row++) {
      var x = w*.12;
      for (var i = 0; i < 5; i++) {
        final bw = w*.12 + (i%2)*w*.03;
        c.drawRect(Rect.fromLTWH(x, h*.12+row*h*.28, bw, h*.2), _fill(bookColors[(i+row)%5]));
        x += bw + w*.02;
      }
    }
  }
  @override bool shouldRepaint(_) => false;
}

class _TvPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final w = s.width; final h = s.height;
    // TV 테두리
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.05, h*.1, w*.9, h*.62), const Radius.circular(8)), _fill(const Color(0xFF212121)));
    // 화면
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.08, h*.13, w*.84, h*.56), const Radius.circular(4)), _fill(const Color(0xFF263238)));
    // 화면 내용 (그라데이션 느낌)
    c.drawRect(Rect.fromLTWH(w*.1, h*.15, w*.5, h*.52), _fill(const Color(0xFF1A237E)));
    c.drawRect(Rect.fromLTWH(w*.6, h*.15, w*.3, h*.52), _fill(const Color(0xFF880E4F)));
    // 스탠드
    c.drawRect(Rect.fromLTWH(w*.43, h*.72, w*.14, h*.1), _fill(const Color(0xFF424242)));
    c.drawRect(Rect.fromLTWH(w*.3, h*.82, w*.4, h*.06), _fill(const Color(0xFF424242)));
  }
  @override bool shouldRepaint(_) => false;
}

class _FridgePainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final w = s.width; final h = s.height;
    // 본체
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.1, h*.04, w*.8, h*.92), const Radius.circular(8)), _fill(const Color(0xFFEEEEEE)));
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.1, h*.04, w*.8, h*.92), const Radius.circular(8)), _stroke(const Color(0xFFBDBDBD), w*.02));
    // 냉동칸 구분선
    c.drawLine(Offset(w*.1, h*.35), Offset(w*.9, h*.35), _stroke(const Color(0xFFBDBDBD), w*.02));
    // 손잡이 (냉동)
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.72, h*.1, w*.06, h*.18), const Radius.circular(3)), _fill(const Color(0xFFB0BEC5)));
    // 손잡이 (냉장)
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.72, h*.42, w*.06, h*.28), const Radius.circular(3)), _fill(const Color(0xFFB0BEC5)));
    // 포인트 색
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.12, h*.06, w*.76, h*.27), const Radius.circular(6)), _fill(const Color(0xFF90CAF9).withValues(alpha: 0.3)));
  }
  @override bool shouldRepaint(_) => false;
}

class _TablePainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final w = s.width; final h = s.height;
    // 상판
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.05, h*.3, w*.9, h*.1), const Radius.circular(6)), _fill(const Color(0xFFA1887F)));
    // 다리
    c.drawRect(Rect.fromLTWH(w*.1, h*.4, w*.08, h*.52), _fill(const Color(0xFF8D6E63)));
    c.drawRect(Rect.fromLTWH(w*.82, h*.4, w*.08, h*.52), _fill(const Color(0xFF8D6E63)));
    // 테이블보
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.03, h*.3, w*.94, h*.12), const Radius.circular(4)), _fill(const Color(0xFFEF9A9A).withValues(alpha: 0.5)));
    // 위에 물건 (커피잔)
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.35, h*.14, w*.18, h*.18), const Radius.circular(4)), _fill(Colors.white));
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.35, h*.14, w*.18, h*.18), const Radius.circular(4)), _stroke(const Color(0xFFBCAAA4), w*.02));
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.38, h*.17, w*.12, h*.1), const Radius.circular(2)), _fill(const Color(0xFF795548)));
  }
  @override bool shouldRepaint(_) => false;
}

class _DresserPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final w = s.width; final h = s.height;
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.08, h*.08, w*.84, h*.88), const Radius.circular(6)), _fill(const Color(0xFFFFCC80)));
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.08, h*.08, w*.84, h*.88), const Radius.circular(6)), _stroke(const Color(0xFFFF8C00), w*.02));
    for (var i = 0; i < 3; i++) {
      c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.14, h*.15+i*h*.27, w*.72, h*.22), const Radius.circular(4)), _fill(const Color(0xFFFFE0B2)));
      c.drawCircle(Offset(w*.5, h*.26+i*h*.27), w*.04, _fill(const Color(0xFFFF8C00)));
    }
  }
  @override bool shouldRepaint(_) => false;
}

class _PianoPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final w = s.width; final h = s.height;
    // 몸체
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.05, h*.1, w*.9, h*.7), const Radius.circular(4)), _fill(const Color(0xFF212121)));
    // 건반부
    c.drawRect(Rect.fromLTWH(w*.08, h*.55, w*.84, h*.2), _fill(Colors.white));
    c.drawRect(Rect.fromLTWH(w*.08, h*.55, w*.84, h*.2), _stroke(const Color(0xFF424242), w*.015));
    // 흰건반 선
    for (var i = 1; i < 7; i++) {
      c.drawLine(Offset(w*.08+i*w*.12, h*.55), Offset(w*.08+i*w*.12, h*.75), _stroke(const Color(0xFFBDBDBD), w*.01));
    }
    // 검은건반
    final blackKeys = [0.16, 0.28, 0.52, 0.64, 0.76];
    for (var x in blackKeys) {
      c.drawRect(Rect.fromLTWH(w*x, h*.55, w*.07, h*.12), _fill(const Color(0xFF212121)));
    }
    // 다리
    c.drawRect(Rect.fromLTWH(w*.1, h*.8, w*.1, h*.16), _fill(const Color(0xFF424242)));
    c.drawRect(Rect.fromLTWH(w*.8, h*.8, w*.1, h*.16), _fill(const Color(0xFF424242)));
  }
  @override bool shouldRepaint(_) => false;
}

class _BathtubPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final w = s.width; final h = s.height;
    // 욕조 외부
    final path = Path()
      ..moveTo(w*.05, h*.35)
      ..lineTo(w*.05, h*.78)
      ..quadraticBezierTo(w*.05, h*.88, w*.15, h*.88)
      ..lineTo(w*.85, h*.88)
      ..quadraticBezierTo(w*.95, h*.88, w*.95, h*.78)
      ..lineTo(w*.95, h*.35)
      ..close();
    c.drawPath(path, _fill(const Color(0xFFE3F2FD)));
    c.drawPath(path, _stroke(const Color(0xFF90CAF9), w*.03));
    // 물
    c.drawRect(Rect.fromLTWH(w*.08, h*.5, w*.84, h*.35), _fill(const Color(0xFF64B5F6).withValues(alpha: 0.5)));
    // 수도꼭지
    c.drawRect(Rect.fromLTWH(w*.42, h*.2, w*.16, h*.18), _fill(const Color(0xFFB0BEC5)));
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.35, h*.18, w*.08, h*.06), const Radius.circular(3)), _fill(const Color(0xFFEF9A9A)));
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.57, h*.18, w*.08, h*.06), const Radius.circular(3)), _fill(const Color(0xFF90CAF9)));
    // 다리
    c.drawRect(Rect.fromLTWH(w*.1, h*.86, w*.08, h*.1), _fill(const Color(0xFFB0BEC5)));
    c.drawRect(Rect.fromLTWH(w*.82, h*.86, w*.08, h*.1), _fill(const Color(0xFFB0BEC5)));
  }
  @override bool shouldRepaint(_) => false;
}

class _LampPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final w = s.width; final h = s.height;
    // 갓
    final path = Path()
      ..moveTo(w*.25, h*.35)
      ..lineTo(w*.1, h*.62)
      ..lineTo(w*.9, h*.62)
      ..lineTo(w*.75, h*.35)
      ..close();
    c.drawPath(path, _fill(const Color(0xFFFFF176)));
    c.drawPath(path, _stroke(const Color(0xFFFDD835), w*.02));
    // 발광 효과
    c.drawCircle(Offset(w*.5, h*.48), w*.12, Paint()..color = const Color(0xFFFFF9C4).withValues(alpha: 0.6));
    // 기둥
    c.drawRect(Rect.fromLTWH(w*.46, h*.62, w*.08, h*.25), _fill(const Color(0xFFBCAAA4)));
    // 받침
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.28, h*.85, w*.44, h*.08), const Radius.circular(4)), _fill(const Color(0xFFA1887F)));
  }
  @override bool shouldRepaint(_) => false;
}

class _ClockPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final w = s.width; final h = s.height;
    final cx = w*.5; final cy = h*.5; final r = w*.42;
    c.drawCircle(Offset(cx, cy), r, _fill(const Color(0xFFFFF9C4)));
    c.drawCircle(Offset(cx, cy), r, _stroke(const Color(0xFF8D6E63), w*.05));
    c.drawCircle(Offset(cx, cy), w*.04, _fill(const Color(0xFF5D4037)));
    // 시침
    c.drawLine(Offset(cx, cy), Offset(cx - r*.2, cy - r*.45), _stroke(const Color(0xFF212121), w*.04));
    // 분침
    c.drawLine(Offset(cx, cy), Offset(cx + r*.4, cy - r*.25), _stroke(const Color(0xFF424242), w*.03));
    // 눈금
    for (var i = 0; i < 12; i++) {
      final angle = i * math.pi / 6;
      final x1 = cx + (r*.82) * math.sin(angle);
      final y1 = cy - (r*.82) * math.cos(angle);
      final x2 = cx + (r*.92) * math.sin(angle);
      final y2 = cy - (r*.92) * math.cos(angle);
      c.drawLine(Offset(x1, y1), Offset(x2, y2), _stroke(const Color(0xFF8D6E63), w*.03));
    }
  }
  @override bool shouldRepaint(_) => false;
}

class _ClosetPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final w = s.width; final h = s.height;
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.05, h*.04, w*.9, h*.92), const Radius.circular(6)), _fill(const Color(0xFFD7CCC8)));
    c.drawRect(Rect.fromLTWH(w*.5, h*.04, w*.02, h*.92), _fill(const Color(0xFFBCAAA4)));
    // 왼쪽 문
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.07, h*.06, w*.4, h*.88), const Radius.circular(4)), _fill(const Color(0xFFEFEBE9)));
    // 오른쪽 문
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.53, h*.06, w*.4, h*.88), const Radius.circular(4)), _fill(const Color(0xFFEFEBE9)));
    // 손잡이
    c.drawCircle(Offset(w*.44, h*.5), w*.03, _fill(const Color(0xFFBCAAA4)));
    c.drawCircle(Offset(w*.56, h*.5), w*.03, _fill(const Color(0xFFBCAAA4)));
  }
  @override bool shouldRepaint(_) => false;
}

// ══ 식물 ══════════════════════════════════════════════════

class _PlantPainter extends CustomPainter {
  final Color potColor;
  final Color leafColor;
  const _PlantPainter({required this.potColor, required this.leafColor});

  @override
  void paint(Canvas c, Size s) {
    final w = s.width; final h = s.height;
    // 잎
    for (var i = -1; i <= 1; i++) {
      final path = Path()
        ..moveTo(w*.5, h*.35)
        ..quadraticBezierTo(w*.5+i*w*.4, h*.1, w*.5+i*w*.35, h*.55);
      c.drawPath(path, _stroke(leafColor, w*.06));
    }
    // 줄기
    c.drawLine(Offset(w*.5, h*.35), Offset(w*.5, h*.6), _stroke(const Color(0xFF388E3C), w*.04));
    // 화분
    final pot = Path()
      ..moveTo(w*.25, h*.6)
      ..lineTo(w*.3, h*.88)
      ..lineTo(w*.7, h*.88)
      ..lineTo(w*.75, h*.6)
      ..close();
    c.drawPath(pot, _fill(potColor));
    c.drawRect(Rect.fromLTWH(w*.2, h*.56, w*.6, h*.08), _fill(const Color(0xFF8D6E63)));
  }
  @override bool shouldRepaint(_) => false;
}

class _CactusPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final w = s.width; final h = s.height;
    // 몸통
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.38, h*.12, w*.24, h*.5), const Radius.circular(12)), _fill(const Color(0xFF66BB6A)));
    // 왼팔
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.2, h*.28, w*.2, h*.14), const Radius.circular(10)), _fill(const Color(0xFF66BB6A)));
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.2, h*.18, w*.14, h*.14), const Radius.circular(10)), _fill(const Color(0xFF66BB6A)));
    // 오른팔
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.6, h*.32, w*.2, h*.14), const Radius.circular(10)), _fill(const Color(0xFF66BB6A)));
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.66, h*.22, w*.14, h*.14), const Radius.circular(10)), _fill(const Color(0xFF66BB6A)));
    // 가시
    for (var i = 0; i < 4; i++) {
      c.drawLine(Offset(w*.5, h*.2+i*h*.1), Offset(w*.56, h*.18+i*h*.1), _stroke(Colors.white, w*.015));
      c.drawLine(Offset(w*.5, h*.2+i*h*.1), Offset(w*.44, h*.18+i*h*.1), _stroke(Colors.white, w*.015));
    }
    // 화분
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.28, h*.6, w*.44, h*.3), const Radius.circular(4)), _fill(const Color(0xFFD84315)));
    c.drawRect(Rect.fromLTWH(w*.24, h*.58, w*.52, h*.06), _fill(const Color(0xFFBF360C)));
    // 흙
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.3, h*.6, w*.4, h*.08), const Radius.circular(2)), _fill(const Color(0xFF795548)));
  }
  @override bool shouldRepaint(_) => false;
}

class _TreePainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final w = s.width; final h = s.height;
    // 줄기
    c.drawRect(Rect.fromLTWH(w*.43, h*.55, w*.14, h*.4), _fill(const Color(0xFF8D6E63)));
    // 잎 3겹
    c.drawOval(Rect.fromLTWH(w*.15, h*.38, w*.7, h*.32), _fill(const Color(0xFF388E3C)));
    c.drawOval(Rect.fromLTWH(w*.2, h*.22, w*.6, h*.28), _fill(const Color(0xFF43A047)));
    c.drawOval(Rect.fromLTWH(w*.28, h*.08, w*.44, h*.24), _fill(const Color(0xFF66BB6A)));
    // 열매
    c.drawCircle(Offset(w*.35, h*.3), w*.04, _fill(const Color(0xFFEF5350)));
    c.drawCircle(Offset(w*.65, h*.35), w*.04, _fill(const Color(0xFFEF5350)));
    c.drawCircle(Offset(w*.5, h*.2), w*.04, _fill(const Color(0xFFFFCA28)));
  }
  @override bool shouldRepaint(_) => false;
}

class _FlowerPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final w = s.width; final h = s.height;
    // 줄기
    c.drawLine(Offset(w*.5, h*.45), Offset(w*.5, h*.7), _stroke(const Color(0xFF66BB6A), w*.05));
    // 잎
    c.drawOval(Rect.fromLTWH(w*.28, h*.52, w*.22, h*.14), _fill(const Color(0xFF66BB6A)));
    // 꽃잎
    const petalColors = [Color(0xFFFF80AB), Color(0xFFFF4081), Color(0xFFFF80AB), Color(0xFFFF4081), Color(0xFFFF80AB)];
    for (var i = 0; i < 5; i++) {
      final angle = i * 2 * math.pi / 5;
      c.drawOval(
        Rect.fromCenter(center: Offset(w*.5 + w*.18*math.cos(angle), h*.3 + h*.15*math.sin(angle)), width: w*.2, height: h*.2),
        _fill(petalColors[i]),
      );
    }
    // 수술
    c.drawCircle(Offset(w*.5, h*.3), w*.1, _fill(const Color(0xFFFFCA28)));
    // 화병
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.35, h*.68, w*.3, h*.24), const Radius.circular(8)), _fill(const Color(0xFF80DEEA)));
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.35, h*.68, w*.3, h*.24), const Radius.circular(8)), _stroke(const Color(0xFF4DD0E1), w*.02));
  }
  @override bool shouldRepaint(_) => false;
}

// ══ 동물 ══════════════════════════════════════════════════

class _DogPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final w = s.width; final h = s.height;
    const body = Color(0xFFD4A056);
    const dark = Color(0xFFC8883A);
    // 몸통
    c.drawOval(Rect.fromLTWH(w*.2, h*.42, w*.6, h*.42), _fill(body));
    // 머리
    c.drawCircle(Offset(w*.5, h*.34), w*.26, _fill(body));
    // 귀
    c.drawOval(Rect.fromLTWH(w*.18, h*.12, w*.18, h*.24), _fill(dark));
    c.drawOval(Rect.fromLTWH(w*.64, h*.12, w*.18, h*.24), _fill(dark));
    // 눈
    c.drawCircle(Offset(w*.4, h*.3), w*.05, _fill(Colors.white));
    c.drawCircle(Offset(w*.6, h*.3), w*.05, _fill(Colors.white));
    c.drawCircle(Offset(w*.41, h*.3), w*.03, _fill(const Color(0xFF212121)));
    c.drawCircle(Offset(w*.61, h*.3), w*.03, _fill(const Color(0xFF212121)));
    // 코
    c.drawOval(Rect.fromLTWH(w*.43, h*.38, w*.14, h*.09), _fill(const Color(0xFF5D4037)));
    // 입
    c.drawArc(Rect.fromLTWH(w*.4, h*.44, w*.2, h*.1), 0, math.pi, false, _stroke(const Color(0xFF5D4037), w*.025));
    // 꼬리
    final tail = Path()
      ..moveTo(w*.8, h*.55)
      ..quadraticBezierTo(w*.98, h*.4, w*.92, h*.65);
    c.drawPath(tail, _stroke(body, w*.07));
    // 발
    c.drawOval(Rect.fromLTWH(w*.22, h*.78, w*.18, h*.14), _fill(body));
    c.drawOval(Rect.fromLTWH(w*.6, h*.78, w*.18, h*.14), _fill(body));
  }
  @override bool shouldRepaint(_) => false;
}

class _CatPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final w = s.width; final h = s.height;
    const body = Color(0xFF9E9E9E);
    const dark = Color(0xFF757575);
    // 몸통
    c.drawOval(Rect.fromLTWH(w*.2, h*.44, w*.6, h*.42), _fill(body));
    // 머리
    c.drawCircle(Offset(w*.5, h*.36), w*.24, _fill(body));
    // 귀 (뾰족)
    final earL = Path()..moveTo(w*.28, h*.2)..lineTo(w*.2, h*.06)..lineTo(w*.38, h*.18)..close();
    final earR = Path()..moveTo(w*.72, h*.2)..lineTo(w*.8, h*.06)..lineTo(w*.62, h*.18)..close();
    c.drawPath(earL, _fill(dark));
    c.drawPath(earR, _fill(dark));
    // 귀 안쪽
    final earL2 = Path()..moveTo(w*.29, h*.2)..lineTo(w*.23, h*.1)..lineTo(w*.35, h*.19)..close();
    final earR2 = Path()..moveTo(w*.71, h*.2)..lineTo(w*.77, h*.1)..lineTo(w*.65, h*.19)..close();
    c.drawPath(earL2, _fill(const Color(0xFFF48FB1)));
    c.drawPath(earR2, _fill(const Color(0xFFF48FB1)));
    // 눈 (고양이 눈)
    c.drawOval(Rect.fromLTWH(w*.36, h*.28, w*.1, h*.1), _fill(const Color(0xFF4CAF50)));
    c.drawOval(Rect.fromLTWH(w*.54, h*.28, w*.1, h*.1), _fill(const Color(0xFF4CAF50)));
    c.drawOval(Rect.fromLTWH(w*.39, h*.29, w*.04, h*.08), _fill(const Color(0xFF212121)));
    c.drawOval(Rect.fromLTWH(w*.57, h*.29, w*.04, h*.08), _fill(const Color(0xFF212121)));
    // 코
    final nose = Path()..moveTo(w*.5, h*.4)..lineTo(w*.46, h*.44)..lineTo(w*.54, h*.44)..close();
    c.drawPath(nose, _fill(const Color(0xFFF48FB1)));
    // 수염
    c.drawLine(Offset(w*.3, h*.42), Offset(w*.46, h*.43), _stroke(Colors.white, w*.015));
    c.drawLine(Offset(w*.3, h*.44), Offset(w*.46, h*.45), _stroke(Colors.white, w*.015));
    c.drawLine(Offset(w*.7, h*.42), Offset(w*.54, h*.43), _stroke(Colors.white, w*.015));
    c.drawLine(Offset(w*.7, h*.44), Offset(w*.54, h*.45), _stroke(Colors.white, w*.015));
    // 꼬리 (둥글게)
    final tail = Path()..moveTo(w*.75, h*.6)..quadraticBezierTo(w*.96, h*.7, w*.88, h*.88)..quadraticBezierTo(w*.8, h*.96, w*.72, h*.88);
    c.drawPath(tail, _stroke(body, w*.07));
    // 발
    c.drawOval(Rect.fromLTWH(w*.22, h*.8, w*.18, h*.13), _fill(body));
    c.drawOval(Rect.fromLTWH(w*.6, h*.8, w*.18, h*.13), _fill(body));
  }
  @override bool shouldRepaint(_) => false;
}

class _HamsterPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final w = s.width; final h = s.height;
    const body = Color(0xFFFFCC80);
    // 볼
    c.drawCircle(Offset(w*.3, h*.48), w*.18, _fill(const Color(0xFFFFE0B2)));
    c.drawCircle(Offset(w*.7, h*.48), w*.18, _fill(const Color(0xFFFFE0B2)));
    // 몸통
    c.drawOval(Rect.fromLTWH(w*.22, h*.45, w*.56, h*.42), _fill(body));
    // 머리
    c.drawCircle(Offset(w*.5, h*.38), w*.22, _fill(body));
    // 귀
    c.drawCircle(Offset(w*.3, h*.22), w*.1, _fill(body));
    c.drawCircle(Offset(w*.7, h*.22), w*.1, _fill(body));
    c.drawCircle(Offset(w*.3, h*.22), w*.06, _fill(const Color(0xFFF48FB1)));
    c.drawCircle(Offset(w*.7, h*.22), w*.06, _fill(const Color(0xFFF48FB1)));
    // 눈
    c.drawCircle(Offset(w*.42, h*.35), w*.04, _fill(const Color(0xFF212121)));
    c.drawCircle(Offset(w*.58, h*.35), w*.04, _fill(const Color(0xFF212121)));
    // 코
    c.drawOval(Rect.fromLTWH(w*.46, h*.4, w*.08, h*.05), _fill(const Color(0xFFF48FB1)));
    // 발
    c.drawOval(Rect.fromLTWH(w*.25, h*.82, w*.18, h*.12), _fill(body));
    c.drawOval(Rect.fromLTWH(w*.57, h*.82, w*.18, h*.12), _fill(body));
  }
  @override bool shouldRepaint(_) => false;
}

class _RabbitPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final w = s.width; final h = s.height;
    const body = Color(0xFFEEEEEE);
    // 귀
    c.drawOval(Rect.fromLTWH(w*.25, h*.04, w*.16, h*.36), _fill(body));
    c.drawOval(Rect.fromLTWH(w*.59, h*.04, w*.16, h*.36), _fill(body));
    c.drawOval(Rect.fromLTWH(w*.28, h*.06, w*.1, h*.3), _fill(const Color(0xFFF48FB1)));
    c.drawOval(Rect.fromLTWH(w*.62, h*.06, w*.1, h*.3), _fill(const Color(0xFFF48FB1)));
    // 몸통
    c.drawOval(Rect.fromLTWH(w*.18, h*.5, w*.64, h*.44), _fill(body));
    // 머리
    c.drawCircle(Offset(w*.5, h*.42), w*.24, _fill(body));
    // 눈
    c.drawCircle(Offset(w*.41, h*.38), w*.05, _fill(const Color(0xFFEC407A)));
    c.drawCircle(Offset(w*.59, h*.38), w*.05, _fill(const Color(0xFFEC407A)));
    // 코
    final nose = Path()..moveTo(w*.5, h*.45)..lineTo(w*.46, h*.49)..lineTo(w*.54, h*.49)..close();
    c.drawPath(nose, _fill(const Color(0xFFF48FB1)));
    // 꼬리
    c.drawCircle(Offset(w*.78, h*.68), w*.07, _fill(Colors.white));
  }
  @override bool shouldRepaint(_) => false;
}

// ══ 소품 ══════════════════════════════════════════════════

class _PicturePainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final w = s.width; final h = s.height;
    // 액자
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.05, h*.05, w*.9, h*.88), const Radius.circular(4)), _fill(const Color(0xFF8D6E63)));
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.12, h*.12, w*.76, h*.74), const Radius.circular(2)), _fill(Colors.white));
    // 그림 (간단한 풍경)
    c.drawRect(Rect.fromLTWH(w*.12, h*.5, w*.76, h*.36), _fill(const Color(0xFF81C784)));
    c.drawRect(Rect.fromLTWH(w*.12, h*.12, w*.76, h*.38), _fill(const Color(0xFF64B5F6)));
    c.drawCircle(Offset(w*.65, h*.28), w*.15, _fill(const Color(0xFFFFEE58)));
    // 산
    final mtn = Path()..moveTo(w*.15, h*.5)..lineTo(w*.35, h*.25)..lineTo(w*.55, h*.5);
    c.drawPath(mtn, _fill(Colors.white));
  }
  @override bool shouldRepaint(_) => false;
}

class _CushionPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final w = s.width; final h = s.height;
    c.drawOval(Rect.fromLTWH(w*.08, h*.12, w*.84, h*.76), _fill(const Color(0xFFEF5350)));
    c.drawOval(Rect.fromLTWH(w*.08, h*.12, w*.84, h*.76), _stroke(const Color(0xFFC62828), w*.025));
    // 십자 재봉선
    c.drawLine(Offset(w*.5, h*.12), Offset(w*.5, h*.88), _stroke(const Color(0xFFC62828), w*.02));
    c.drawLine(Offset(w*.08, h*.5), Offset(w*.92, h*.5), _stroke(const Color(0xFFC62828), w*.02));
    c.drawOval(Rect.fromLTWH(w*.35, h*.35, w*.3, h*.3), _fill(const Color(0xFFFFCDD2)));
  }
  @override bool shouldRepaint(_) => false;
}

class _FishtankPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final w = s.width; final h = s.height;
    // 어항
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.08, h*.12, w*.84, h*.75), const Radius.circular(8)), _fill(const Color(0xFFB3E5FC)));
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.08, h*.12, w*.84, h*.75), const Radius.circular(8)), _stroke(const Color(0xFF29B6F6), w*.03));
    // 모래
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.1, h*.75, w*.8, h*.1), const Radius.circular(4)), _fill(const Color(0xFFFFCC80)));
    // 물고기
    _drawFish(c, Offset(w*.3, h*.4), w*.22, const Color(0xFFFF7043));
    _drawFish(c, Offset(w*.65, h*.55), w*.18, const Color(0xFF66BB6A));
    // 거품
    c.drawCircle(Offset(w*.5, h*.22), w*.03, _fill(Colors.white.withValues(alpha: 0.7)));
    c.drawCircle(Offset(w*.55, h*.16), w*.02, _fill(Colors.white.withValues(alpha: 0.7)));
    // 뚜껑
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.06, h*.08, w*.88, h*.06), const Radius.circular(4)), _fill(const Color(0xFF546E7A)));
  }

  void _drawFish(Canvas c, Offset pos, double size, Color color) {
    final body = Path()
      ..moveTo(pos.dx, pos.dy)
      ..quadraticBezierTo(pos.dx + size*.5, pos.dy - size*.2, pos.dx + size, pos.dy)
      ..quadraticBezierTo(pos.dx + size*.5, pos.dy + size*.2, pos.dx, pos.dy)
      ..close();
    c.drawPath(body, _fill(color));
    // 꼬리
    final tail = Path()
      ..moveTo(pos.dx, pos.dy - size*.15)
      ..lineTo(pos.dx - size*.2, pos.dy - size*.25)
      ..lineTo(pos.dx - size*.2, pos.dy + size*.25)
      ..lineTo(pos.dx, pos.dy + size*.15)
      ..close();
    c.drawPath(tail, _fill(color.withValues(alpha: 0.7)));
    // 눈
    c.drawCircle(Offset(pos.dx + size*.8, pos.dy - size*.05), size*.06, _fill(Colors.white));
    c.drawCircle(Offset(pos.dx + size*.82, pos.dy - size*.05), size*.03, _fill(Colors.black));
  }
  @override bool shouldRepaint(_) => false;
}

class _TrophyPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final w = s.width; final h = s.height;
    // 컵
    final cup = Path()
      ..moveTo(w*.25, h*.08)
      ..lineTo(w*.75, h*.08)
      ..quadraticBezierTo(w*.82, h*.08, w*.82, h*.16)
      ..quadraticBezierTo(w*.88, h*.4, w*.62, h*.55)
      ..lineTo(w*.38, h*.55)
      ..quadraticBezierTo(w*.12, h*.4, w*.18, h*.16)
      ..quadraticBezierTo(w*.18, h*.08, w*.25, h*.08)
      ..close();
    c.drawPath(cup, _fill(const Color(0xFFFFD700)));
    c.drawPath(cup, _stroke(const Color(0xFFFFA000), w*.025));
    // 별
    _drawStar(c, Offset(w*.5, h*.3), w*.15, const Color(0xFFFFF9C4));
    // 손잡이
    c.drawPath(Path()..moveTo(w*.18, h*.2)..quadraticBezierTo(w*.06, h*.2, w*.06, h*.38)..quadraticBezierTo(w*.06, h*.5, w*.2, h*.48), _stroke(const Color(0xFFFFD700), w*.04));
    c.drawPath(Path()..moveTo(w*.82, h*.2)..quadraticBezierTo(w*.94, h*.2, w*.94, h*.38)..quadraticBezierTo(w*.94, h*.5, w*.8, h*.48), _stroke(const Color(0xFFFFD700), w*.04));
    // 기둥
    c.drawRect(Rect.fromLTWH(w*.44, h*.55, w*.12, h*.2), _fill(const Color(0xFFFFCC80)));
    // 받침
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.22, h*.74, w*.56, h*.14), const Radius.circular(4)), _fill(const Color(0xFFFF8F00)));
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.18, h*.86, w*.64, h*.1), const Radius.circular(4)), _fill(const Color(0xFFFFA000)));
  }

  void _drawStar(Canvas c, Offset center, double r, Color color) {
    final path = Path();
    for (var i = 0; i < 5; i++) {
      final a = i * 2 * math.pi / 5 - math.pi / 2;
      final ia = a + math.pi / 5;
      final x = center.dx + r * math.cos(a); final y = center.dy + r * math.sin(a);
      final ix = center.dx + r*.4 * math.cos(ia); final iy = center.dy + r*.4 * math.sin(ia);
      if (i == 0) { path.moveTo(x, y); } else { path.lineTo(x, y); }
      path.lineTo(ix, iy);
    }
    path.close();
    c.drawPath(path, _fill(color));
  }
  @override bool shouldRepaint(_) => false;
}

class _GamepadPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final w = s.width; final h = s.height;
    // 본체
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.06, h*.2, w*.88, h*.6), const Radius.circular(14)), _fill(const Color(0xFF37474F)));
    // 십자키
    c.drawRect(Rect.fromLTWH(w*.2, h*.36, w*.14, h*.28), _fill(const Color(0xFF546E7A)));
    c.drawRect(Rect.fromLTWH(w*.13, h*.43, w*.28, h*.14), _fill(const Color(0xFF546E7A)));
    // 버튼 4개
    c.drawCircle(Offset(w*.72, h*.38), w*.05, _fill(const Color(0xFFF44336)));
    c.drawCircle(Offset(w*.82, h*.48), w*.05, _fill(const Color(0xFF4CAF50)));
    c.drawCircle(Offset(w*.72, h*.58), w*.05, _fill(const Color(0xFF2196F3)));
    c.drawCircle(Offset(w*.62, h*.48), w*.05, _fill(const Color(0xFFFFEB3B)));
    // 아날로그 스틱
    c.drawCircle(Offset(w*.35, h*.62), w*.07, _fill(const Color(0xFF546E7A)));
    c.drawCircle(Offset(w*.6, h*.38), w*.07, _fill(const Color(0xFF546E7A)));
  }
  @override bool shouldRepaint(_) => false;
}

class _GuitarPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final w = s.width; final h = s.height;
    // 바디 아랫부분
    c.drawOval(Rect.fromLTWH(w*.2, h*.52, w*.6, h*.44), _fill(const Color(0xFFC8883A)));
    // 바디 윗부분
    c.drawOval(Rect.fromLTWH(w*.26, h*.32, w*.48, h*.36), _fill(const Color(0xFFC8883A)));
    // 사운드홀
    c.drawCircle(Offset(w*.5, h*.65), w*.12, _fill(const Color(0xFF5D4037)));
    // 넥
    c.drawRect(Rect.fromLTWH(w*.44, h*.04, w*.12, h*.5), _fill(const Color(0xFF8D6E63)));
    // 헤드
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.38, h*.02, w*.24, h*.1), const Radius.circular(4)), _fill(const Color(0xFF6D4C41)));
    // 줄
    for (var i = 0; i < 3; i++) {
      c.drawLine(Offset(w*.46+i*w*.04, h*.06), Offset(w*.46+i*w*.04, h*.76), _stroke(const Color(0xFFBDBDBD), w*.008));
    }
  }
  @override bool shouldRepaint(_) => false;
}

class _CarpetPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final w = s.width; final h = s.height;
    // 메인 카펫
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.04, h*.3, w*.92, h*.42), const Radius.circular(8)), _fill(const Color(0xFFB71C1C)));
    // 가장자리 패턴
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.08, h*.34, w*.84, h*.34), const Radius.circular(6)), _fill(const Color(0xFFE53935)));
    // 중앙 문양
    c.drawOval(Rect.fromLTWH(w*.3, h*.37, w*.4, h*.28), _fill(const Color(0xFFFFCC80).withValues(alpha: 0.5)));
    c.drawOval(Rect.fromLTWH(w*.38, h*.41, w*.24, h*.2), _fill(const Color(0xFFFFD54F).withValues(alpha: 0.6)));
    // 술
    for (var i = 0; i < 8; i++) {
      c.drawLine(Offset(w*.08+i*w*.12, h*.3), Offset(w*.08+i*w*.12, h*.2), _stroke(const Color(0xFFFFD54F), w*.015));
      c.drawLine(Offset(w*.08+i*w*.12, h*.72), Offset(w*.08+i*w*.12, h*.82), _stroke(const Color(0xFFFFD54F), w*.015));
    }
  }
  @override bool shouldRepaint(_) => false;
}

class _MirrorPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final w = s.width; final h = s.height;
    c.drawOval(Rect.fromLTWH(w*.12, h*.06, w*.76, h*.82), _fill(const Color(0xFFB0BEC5)));
    c.drawOval(Rect.fromLTWH(w*.12, h*.06, w*.76, h*.82), _stroke(const Color(0xFF8D6E63), w*.06));
    c.drawOval(Rect.fromLTWH(w*.18, h*.12, w*.64, h*.7), _fill(const Color(0xFFE1F5FE)));
    // 반사 하이라이트
    c.drawOval(Rect.fromLTWH(w*.25, h*.18, w*.2, h*.3), _fill(Colors.white.withValues(alpha: 0.4)));
    // 받침
    c.drawRect(Rect.fromLTWH(w*.42, h*.86, w*.16, h*.1), _fill(const Color(0xFF8D6E63)));
    c.drawRect(Rect.fromLTWH(w*.3, h*.94, w*.4, h*.04), _fill(const Color(0xFF6D4C41)));
  }
  @override bool shouldRepaint(_) => false;
}

class _DefaultPainter extends CustomPainter {
  final String id;
  const _DefaultPainter(this.id);
  @override
  void paint(Canvas c, Size s) {
    c.drawCircle(Offset(s.width*.5, s.height*.5), s.width*.4, _fill(Colors.grey.shade300));
    final tp = TextPainter(text: TextSpan(text: '?', style: TextStyle(fontSize: s.width*.4, color: Colors.grey.shade600)), textDirection: TextDirection.ltr)..layout();
    tp.paint(c, Offset(s.width*.5 - tp.width*.5, s.height*.5 - tp.height*.5));
  }
  @override bool shouldRepaint(_) => false;
}
