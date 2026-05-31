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

  // 실제 백엔드 LabResultResponse 스키마 기준
  final sampleJson = {
    'id': 1,
    'test_date': '2026-05-01',
    'test_item': 'CRP',
    'value': '5.2 mg/L',
    'reference_range': '0~5 mg/L',
    'note': null,
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
      expect(results.first.testItem, equals('CRP'));
      expect(results.first.value, equals('5.2 mg/L'));
    });

    test('빈 목록을 반환한다', () async {
      when(() => mockClient.getList(any())).thenAnswer(
        (_) async => ApiResponse.success([], 200),
      );

      expect(await service.getResults(), isEmpty);
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

      final result = await service.addResult(LabResultInput(
        testDate: DateTime(2026, 5, 1),
        testItem: 'CRP',
        value: '5.2 mg/L',
      ));

      expect(result.id, equals(1));
      expect(result.testItem, equals('CRP'));
    });
  });

  group('updateResult', () {
    test('PATCH로 검사 결과를 수정한다', () async {
      when(() => mockClient.patch(any(), body: any(named: 'body')))
          .thenAnswer((_) async => ApiResponse.success(sampleJson, 200));

      final result = await service.updateResult(1, LabResultInput(
        testDate: DateTime(2026, 5, 1),
        testItem: 'CRP',
        value: '3.1 mg/L',
      ));

      expect(result.id, equals(1));
    });
  });

  group('LabResult 모델', () {
    test('fromJson으로 올바르게 파싱된다', () {
      final result = LabResult.fromJson(sampleJson);

      expect(result.id, equals(1));
      expect(result.testItem, equals('CRP'));
      expect(result.value, equals('5.2 mg/L'));
      expect(result.referenceRange, equals('0~5 mg/L'));
      expect(result.note, isNull);
    });
  });

  group('LabResultInput', () {
    test('toJson은 올바른 필드명을 사용한다', () {
      final input = LabResultInput(
        testDate: DateTime(2026, 5, 1),
        testItem: 'ESR',
        value: '10 mm/h',
      );

      final json = input.toJson();
      expect(json['test_date'], equals('2026-05-01'));
      expect(json['test_item'], equals('ESR'));
      expect(json['value'], equals('10 mm/h'));
      expect(json.containsKey('reference_range'), isFalse);
      expect(json.containsKey('note'), isFalse);
    });
  });
}
