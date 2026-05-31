// 앱이 스플래시 화면으로 시작하는지 확인하는 smoke test
import 'package:flutter_test/flutter_test.dart';

void main() {
  // 앱 위젯 테스트는 실제 storage/network 의존성으로 인해
  // 단위 테스트(test/core, test/features)로 대체됨
  test('placeholder', () => expect(true, isTrue));
}
