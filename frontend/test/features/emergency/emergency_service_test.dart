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

  final sampleContactJson = {
    'id': 1,
    'guardian_name': '홍길동',
    'guardian_contact': '010-1234-5678',
    'is_revoked': false,
    'expires_at': DateTime.now().add(const Duration(days: 365)).toIso8601String(),
    'share_categories': ['medical_records'],
    'secure_link_token': 'token123',
    'created_at': '2026-05-01T09:00:00.000Z',
  };

  group('getContacts', () {
    test('보호자 목록을 반환한다', () async {
      when(() => mockClient.getList(any())).thenAnswer(
        (_) async => ApiResponse.success([sampleContactJson], 200),
      );

      final contacts = await service.getContacts();

      expect(contacts, hasLength(1));
      expect(contacts.first.name, equals('홍길동'));
      expect(contacts.first.phone, equals('010-1234-5678'));
      expect(contacts.first.isActive, isTrue);
    });

    test('API 오류 시 Exception을 던진다', () async {
      when(() => mockClient.getList(any())).thenAnswer(
        (_) async => ApiResponse.failure('서버 오류', 500),
      );

      expect(() => service.getContacts(), throwsException);
    });
  });

  group('addContact', () {
    test('보호자를 추가하고 GuardianContact를 반환한다', () async {
      when(() => mockClient.post(any(), body: any(named: 'body')))
          .thenAnswer((_) async => ApiResponse.success(sampleContactJson, 201));

      final contact = await service.addContact(
        name: '홍길동',
        phone: '010-1234-5678',
      );

      expect(contact.name, equals('홍길동'));
      expect(contact.phone, equals('010-1234-5678'));
    });
  });

  group('GuardianContact 모델', () {
    test('fromJson으로 올바르게 파싱된다', () {
      final contact = GuardianContact.fromJson(sampleContactJson);

      expect(contact.id, equals(1));
      expect(contact.name, equals('홍길동'));
      expect(contact.isRevoked, isFalse);
      expect(contact.isActive, isTrue);
    });

    test('철회된 보호자는 isActive가 false이다', () {
      final revoked = GuardianContact.fromJson({
        ...sampleContactJson,
        'is_revoked': true,
      });
      expect(revoked.isActive, isFalse);
    });

    test('만료된 보호자는 isActive가 false이다', () {
      final expired = GuardianContact.fromJson({
        ...sampleContactJson,
        'expires_at': DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String(),
      });
      expect(expired.isActive, isFalse);
    });
  });
}
