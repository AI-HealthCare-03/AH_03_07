// 웹 전용 카드 사운드 구현
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

class CardSoundImpl {
  static void call(String fn) {
    try { js.context.callMethod(fn, []); } catch (_) {}
  }
}
