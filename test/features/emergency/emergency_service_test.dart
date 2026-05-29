import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_application_1/core/api/api_client.dart';
import 'package:flutter_application_1/core/models/api_response.dart';
import 'package:flutter_application_1/features/emergency/services/emergency_service.dart';

class _MockApiClient extends Mock implements ApiClient {}

void main() {
  late _MockApiClient mockClient;
  late EmergencyService service;

  setUp(() {
    mockClient = _MockApiClient();
    service = EmergencyService(client: mockClient);
  });

  group('sendSos', () {
    test('SOS 전송 성공 시 EmergencySosResult를 반환한다', () async {
      when(() => mockClient.post(any(), body: any(named: 'body')))
          .thenAnswer((_) async => ApiResponse.success(
                {
                  'sent': true,
                  'notified_count': 2,
                  'secure_link': 'https://example.com/sos/abc',
                },
                200,
              ));

      final result = await service.sendSos(message: '도움이 필요합니다');

      expect(result.sent, isTrue);
      expect(result.notifiedCount, equals(2));
      expect(result.secureLink, isNotNull);
    });

    test('API 오류 시 Exception을 던진다', () async {
      when(() => mockClient.post(any(), body: any(named: 'body')))
          .thenAnswer((_) async => ApiResponse.failure('서버 오류', 500));

      expect(() => service.sendSos(), throwsException);
    });
  });

  group('getContacts', () {
    test('보호자 목록을 반환한다', () async {
      when(() => mockClient.get(any())).thenAnswer(
        (_) async => ApiResponse.success(
          {
            'contacts': [
              {'id': 1, 'name': '홍길동', 'phone': '010-1234-5678', 'relation': '부모'},
              {'id': 2, 'name': '김철수', 'phone': '010-8765-4321'},
            ],
          },
          200,
        ),
      );

      final contacts = await service.getContacts();

      expect(contacts, hasLength(2));
      expect(contacts.first.name, equals('홍길동'));
      expect(contacts.first.relation, equals('부모'));
      expect(contacts.last.relation, isNull);
    });
  });

  group('addContact', () {
    test('보호자를 추가하고 EmergencyContact를 반환한다', () async {
      when(() => mockClient.post(any(), body: any(named: 'body')))
          .thenAnswer((_) async => ApiResponse.success(
                {'id': 3, 'name': '이순신', 'phone': '010-0000-0000', 'relation': '배우자'},
                201,
              ));

      final contact = await service.addContact(
        name: '이순신',
        phone: '010-0000-0000',
        relation: '배우자',
      );

      expect(contact.id, equals(3));
      expect(contact.name, equals('이순신'));
    });
  });
}
