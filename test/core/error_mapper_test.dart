import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/models/error_mapper.dart';

void main() {
  group('ErrorMapper', () {
    test('401 → 로그인 필요 메시지', () {
      expect(ErrorMapper.toUserMessage(401, null), contains('로그인'));
    });

    test('422 Pydantic → Value error 접두사 제거', () {
      final msg = ErrorMapper.toUserMessage(422, 'Value error, 올바른 형식이 아닙니다.');
      expect(msg, equals('올바른 형식이 아닙니다.'));
      expect(msg, isNot(contains('Value error')));
    });

    test('500 → 서버 문제 안내', () {
      expect(ErrorMapper.toUserMessage(500, null), contains('서버'));
    });

    test('null statusCode + 빈 메시지 → 기본 메시지', () {
      final msg = ErrorMapper.toUserMessage(null, '');
      expect(msg, isNotEmpty);
    });

    test('사용자 친화적 메시지는 Exception 문자열 미포함', () {
      final msg = ErrorMapper.toUserMessage(400, 'Exception: bad request');
      expect(msg, isNot(contains('Exception')));
    });
  });
}
