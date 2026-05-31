import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/services/ocr_service.dart';

class _MockClient extends Mock implements http.Client {}
class _MockStorage extends Mock implements TokenStorage {}

void main() {
  late _MockClient mockHttp;
  late _MockStorage mockStorage;

  setUpAll(() {
    registerFallbackValue(Uri.parse('http://localhost'));
    registerFallbackValue(<String, String>{});
  });

  setUp(() {
    mockHttp = _MockClient();
    mockStorage = _MockStorage();
    when(() => mockStorage.getAccessToken()).thenAnswer((_) async => 'token');
    when(() => mockStorage.deleteAll()).thenAnswer((_) async {});
  });

  group('AuthService.withdraw()', () {
    test('서버 204 응답 시 토큰 삭제', () async {
      when(() => mockHttp.delete(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('', 204));

      final service = AuthService(tokenStorage: mockStorage, client: mockHttp);
      await service.withdraw();

      verify(() => mockStorage.deleteAll()).called(1);
      service.dispose();
    });

    test('서버 500 응답 시 AuthException 발생 — 토큰 삭제 안 함', () async {
      when(() => mockHttp.delete(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('{"detail":"server error"}', 500));

      final service = AuthService(tokenStorage: mockStorage, client: mockHttp);
      expect(() => service.withdraw(), throwsA(isA<AuthException>()));

      // 서버 실패 시 토큰 삭제하면 안 됨
      verifyNever(() => mockStorage.deleteAll());
      service.dispose();
    });

    test('네트워크 오류 시 AuthException 발생', () async {
      when(() => mockHttp.delete(any(), headers: any(named: 'headers')))
          .thenThrow(Exception('network error'));

      final service = AuthService(tokenStorage: mockStorage, client: mockHttp);
      expect(() => service.withdraw(), throwsA(isA<AuthException>()));
      service.dispose();
    });

    test('토큰 없으면 즉시 AuthException', () async {
      when(() => mockStorage.getAccessToken()).thenAnswer((_) async => null);

      final service = AuthService(tokenStorage: mockStorage, client: mockHttp);
      expect(() => service.withdraw(), throwsA(isA<AuthException>()));
      verifyNever(() => mockHttp.delete(any(), headers: any(named: 'headers')));
      service.dispose();
    });
  });
}
