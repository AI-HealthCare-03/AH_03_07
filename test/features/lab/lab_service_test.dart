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

  // 백엔드 LabResultResponse 스키마 기준
  final sampleJson = {
    'id': 1,
    'test_date': '2026-05-01',
    'test_type': 'CRP',
    'user_recorded_value': '5.2',
    'reference_range': '0~5 mg/L',
    'unit': 'mg/L',
    'memo': null,
    'created_at': '2026-05-01T09:00:00.000Z',
    'updated_at': '2026-05-01T09:00:00.000Z',
  };

  group('getResults', () {
    test('결과 목록을 반환한다', () async {
      when(() => mockClient.getList(any())).thenAnswer(
        (_) async => ApiResponse.success([sampleJson], 200),
      );

      final results = await service.getResults();

      expect(results, hasLength(1));
      expect(results.first.testType, equals('CRP'));
      expect(results.first.userRecordedValue, equals('5.2'));
      expect(results.first.displayValue, equals('5.2 mg/L'));
    });

    test('빈 목록을 반환한다', () async {
      when(() => mockClient.getList(any())).thenAnswer(
        (_) async => ApiResponse.success([], 200),
      );

      final results = await service.getResults();
      expect(results, isEmpty);
    });

    test('API 오류 시 Exception을 던진다', () async {
      when(() => mockClient.getList(any())).thenAnswer(
        (_) async => ApiResponse.failure('서버 오류', 500),
      );

      expect(() => service.getResults(), throwsException);
    });
  });

  group('addResult', () {
    test('검사 결과를 추가하고 LabResult를 반환한다', () async {
      when(() => mockClient.post(any(), body: any(named: 'body')))
          .thenAnswer((_) async => ApiResponse.success(sampleJson, 201));

      final input = LabResultInput(
        testDate: DateTime(2026, 5, 1),
        testType: 'CRP',
        userRecordedValue: '5.2',
        unit: 'mg/L',
      );

      final result = await service.addResult(input);
      expect(result.id, equals(1));
      expect(result.testType, equals('CRP'));
    });
  });

  group('LabResult 모델', () {
    test('fromJson으로 올바르게 파싱된다', () {
      final result = LabResult.fromJson(sampleJson);

      expect(result.id, equals(1));
      expect(result.testType, equals('CRP'));
      expect(result.userRecordedValue, equals('5.2'));
      expect(result.unit, equals('mg/L'));
      expect(result.referenceRange, equals('0~5 mg/L'));
    });

    test('displayValue는 값과 단위를 합친다', () {
      final result = LabResult.fromJson(sampleJson);
      expect(result.displayValue, equals('5.2 mg/L'));
    });

    test('단위 없는 경우 displayValue는 값만 반환한다', () {
      final result = LabResult.fromJson({...sampleJson, 'unit': null});
      expect(result.displayValue, equals('5.2'));
    });
  });

  group('LabResultInput', () {
    test('toJson은 올바른 날짜 포맷을 반환한다', () {
      final input = LabResultInput(
        testDate: DateTime(2026, 5, 1),
        testType: 'ESR',
        userRecordedValue: '10',
      );

      final json = input.toJson();
      expect(json['test_date'], equals('2026-05-01'));
      expect(json['test_type'], equals('ESR'));
      expect(json['user_recorded_value'], equals('10'));
      expect(json.containsKey('unit'), isFalse);
    });
  });
}
