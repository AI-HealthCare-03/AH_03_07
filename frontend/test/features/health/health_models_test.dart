import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/health/models/health_models.dart';

void main() {
  group('HealthMetricType', () {
    test('fromApi는 올바른 타입을 반환한다', () {
      expect(HealthMetricTypeExt.fromApi('weight'), HealthMetricType.weight);
      expect(HealthMetricTypeExt.fromApi('blood_pressure'), HealthMetricType.bloodPressure);
      expect(HealthMetricTypeExt.fromApi('heart_rate'), HealthMetricType.heartRate);
      expect(HealthMetricTypeExt.fromApi('temperature'), HealthMetricType.temperature);
      expect(HealthMetricTypeExt.fromApi('blood_sugar'), HealthMetricType.bloodSugar);
    });

    test('알 수 없는 타입은 painLevel로 폴백한다', () {
      expect(HealthMetricTypeExt.fromApi('unknown'), HealthMetricType.painLevel);
    });

    test('apiKey가 올바른 문자열을 반환한다', () {
      expect(HealthMetricType.weight.apiKey, equals('weight'));
      expect(HealthMetricType.bloodPressure.apiKey, equals('blood_pressure'));
    });
  });

  group('HealthRecord', () {
    test('fromJson으로 파싱한다', () {
      final record = HealthRecord.fromJson({
        'id': 1,
        'metric_type': 'weight',
        'value': 65.5,
        'recorded_at': '2026-05-01T08:00:00.000Z',
      });

      expect(record.id, equals(1));
      expect(record.type, equals(HealthMetricType.weight));
      expect(record.value, equals(65.5));
    });

    test('혈압 displayValue는 수축기/이완기 형태로 표시된다', () {
      final bp = HealthRecord.fromJson({
        'id': 2,
        'metric_type': 'blood_pressure',
        'value': 120.0,
        'value2': 80.0,
        'recorded_at': '2026-05-01T08:00:00.000Z',
      });

      expect(bp.displayValue, contains('120'));
      expect(bp.displayValue, contains('80'));
      expect(bp.displayValue, contains('mmHg'));
    });

    test('단일 수치 displayValue는 단위를 포함한다', () {
      final weight = HealthRecord.fromJson({
        'id': 3,
        'metric_type': 'weight',
        'value': 65.5,
        'recorded_at': '2026-05-01T08:00:00.000Z',
      });

      expect(weight.displayValue, contains('65.5'));
      expect(weight.displayValue, contains('kg'));
    });
  });

  group('HealthRecordInput', () {
    test('toJson은 올바른 맵을 반환한다', () {
      final input = HealthRecordInput(
        type: HealthMetricType.temperature,
        value: 37.2,
        recordedAt: DateTime(2026, 5, 1, 8),
      );

      final json = input.toJson();
      expect(json['metric_type'], equals('temperature'));
      expect(json['value'], equals(37.2));
      expect(json.containsKey('value2'), isFalse);
      expect(json.containsKey('notes'), isFalse);
    });

    test('value2와 notes가 있으면 JSON에 포함된다', () {
      final input = HealthRecordInput(
        type: HealthMetricType.bloodPressure,
        value: 120,
        value2: 80,
        recordedAt: DateTime(2026, 5, 1),
        notes: '아침 측정',
      );

      final json = input.toJson();
      expect(json['value2'], equals(80));
      expect(json['notes'], equals('아침 측정'));
    });
  });
}
