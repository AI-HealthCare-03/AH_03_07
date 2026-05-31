import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:flutter_application_1/core/api/api_client.dart';
import 'package:flutter_application_1/services/ocr_service.dart';

class _MockClient extends Mock implements http.Client {}

class _MockTokenStorage extends Mock implements TokenStorage {}

void main() {
  late _MockClient mockHttp;
  late _MockTokenStorage mockStorage;
  late ApiClient client;

  setUpAll(() {
    registerFallbackValue(Uri.parse('http://localhost'));
    registerFallbackValue(<String, String>{});
  });

  setUp(() {
    mockHttp = _MockClient();
    mockStorage = _MockTokenStorage();
    client = ApiClient(storage: mockStorage, client: mockHttp);

    // 기본: 유효한 토큰 (만료시간 충분)
    final exp = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600;
    final payload = base64Url.encode(utf8.encode('{"exp":$exp}'));
    final token = 'header.$payload.sig';
    when(() => mockStorage.getAccessToken()).thenAnswer((_) async => token);
  });

  tearDown(() => client.dispose());

  group('GET 요청', () {
    test('200 응답을 ApiResponse.success로 파싱한다', () async {
      when(() => mockHttp.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('{"key":"value"}', 200));

      final res = await client.get('/v1/test');

      expect(res.isSuccess, isTrue);
      expect(res.data!['key'], equals('value'));
    });

    test('401 응답을 ApiResponse.failure로 파싱한다', () async {
      when(() => mockHttp.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async =>
              http.Response('{"detail":"Unauthorized"}', 401));

      final res = await client.get('/v1/test');

      expect(res.isSuccess, isFalse);
      expect(res.statusCode, equals(401));
      // ErrorMapper 적용: 401 → 로그인 필요 메시지
      expect(res.error, contains('로그인'));
    });

    test('잘못된 JSON 응답은 오류 메시지를 반환한다', () async {
      when(() => mockHttp.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('invalid json', 200));

      final res = await client.get('/v1/test');

      // JSON 파싱 실패 시 statusCode는 그대로 반환되므로 error 메시지만 확인
      expect(res.error, contains('서버 응답을 처리할 수 없습니다'));
    });
  });

  group('POST 요청', () {
    test('body와 함께 POST 요청이 성공한다', () async {
      when(() => mockHttp.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response('{"id":1}', 201));

      final res = await client.post('/v1/test', body: {'name': 'test'});

      expect(res.isSuccess, isTrue);
      expect(res.data!['id'], equals(1));
    });
  });

  group('헬스체크 (NFR-AVAL-001)', () {
    test('서버가 200을 반환하면 true', () async {
      when(() => mockHttp.get(any())).thenAnswer(
          (_) async => http.Response('{"status":"ok"}', 200));

      final ok = await client.healthCheck();
      expect(ok, isTrue);
    });

    test('서버가 500을 반환하면 false', () async {
      when(() => mockHttp.get(any()))
          .thenAnswer((_) async => http.Response('error', 500));

      final ok = await client.healthCheck();
      expect(ok, isFalse);
    });

    test('타임아웃 시 false', () async {
      when(() => mockHttp.get(any()))
          .thenThrow(Exception('connection timeout'));

      final ok = await client.healthCheck();
      expect(ok, isFalse);
    });
  });

  group('JWT 자동 갱신 (NFR-SEC-001)', () {
    test('토큰 만료 시 refresh 엔드포인트를 호출한다', () async {
      // 만료된 토큰
      final exp = (DateTime.now().millisecondsSinceEpoch ~/ 1000) - 10;
      final payload = base64Url.encode(utf8.encode('{"exp":$exp}'));
      final expiredToken = 'header.$payload.sig';

      when(() => mockStorage.getAccessToken())
          .thenAnswer((_) async => expiredToken);
      when(() => mockStorage.getRefreshToken())
          .thenAnswer((_) async => 'refresh-token');
      when(() => mockStorage.saveAccessToken(any()))
          .thenAnswer((_) async {});

      // refresh 성공 응답
      when(() => mockHttp.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer(
              (_) async => http.Response('{"access_token":"new-token"}', 200));

      // 이후 GET 요청
      when(() => mockHttp.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('{}', 200));

      await client.get('/v1/test');

      verify(() => mockStorage.saveAccessToken('new-token')).called(1);
    });
  });
}
