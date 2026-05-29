import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_application_1/core/api/api_client.dart';
import 'package:flutter_application_1/core/models/api_response.dart';
import 'package:flutter_application_1/features/lab/services/lab_service.dart';
import 'package:flutter_application_1/features/lab/models/lab_models.dart';

class _MockApiClient extends Mock implements ApiClient {}

void main() {
  late _MockApiClient mockClient;
  late LabService service;

  setUp(() {
    mockClient = _MockApiClient();
    service = LabService(client: mockClient);
  });

  final sampleResultJson = {
    'id': 1,
    'test_name': 'CRP',
    'test_code': 'CRP',
    'value': 5.2,
    'unit': 'mg/L',
    'reference_min': 0.0,
    'reference_max': 5.0,
    'status': 'high',
    'tested_at': '2026-05-01T09:00:00.000Z',
  };

  group('getResults', () {
    test('결과 목록을 반환한다', () async {
      when(() => mockClient.get(any())).thenAnswer(
        (_) async => ApiResponse.success(
          {'results': [sampleResultJson]},
          200,
        ),
      );

      final results = await service.getResults();

      expect(results, hasLength(1));
      expect(results.first.testName, equals('CRP'));
      expect(results.first.value, equals(5.2));
      expect(results.first.isAbnormal, isTrue);
    });

    test('빈 목록을 반환한다', () async {
      when(() => mockClient.get(any())).thenAnswer(
        (_) async => ApiResponse.success({'results': []}, 200),
      );

      final results = await service.getResults();
      expect(results, isEmpty);
    });

    test('API 오류 시 Exception을 던진다', () async {
      when(() => mockClient.get(any())).thenAnswer(
        (_) async => ApiResponse.failure('서버 오류', 500),
      );

      expect(() => service.getResults(), throwsException);
    });
  });

  group('addResult', () {
    test('검사 결과를 추가하고 LabResult를 반환한다', () async {
      when(() => mockClient.post(any(), body: any(named: 'body')))
          .thenAnswer((_) async => ApiResponse.success(sampleResultJson, 201));

      final input = LabResultInput(
        testName: 'CRP',
        testCode: 'CRP',
        value: 5.2,
        unit: 'mg/L',
        testedAt: DateTime(2026, 5, 1),
      );

      final result = await service.addResult(input);
      expect(result.id, equals(1));
      expect(result.status, equals('high'));
    });
  });

  group('LabResult 모델', () {
    test('isAbnormal은 status가 normal이 아닐 때 true를 반환한다', () {
      final normalResult = LabResult.fromJson({
        ...sampleResultJson,
        'status': 'normal',
      });
      final highResult = LabResult.fromJson(sampleResultJson);

      expect(normalResult.isAbnormal, isFalse);
      expect(highResult.isAbnormal, isTrue);
    });

    test('isCritical은 status가 critical일 때만 true를 반환한다', () {
      final critical = LabResult.fromJson({
        ...sampleResultJson,
        'status': 'critical',
      });
      final high = LabResult.fromJson(sampleResultJson);

      expect(critical.isCritical, isTrue);
      expect(high.isCritical, isFalse);
    });
  });
}
