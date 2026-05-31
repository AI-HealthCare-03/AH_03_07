// REQ-HEALTH: 건강 수치 수동 기록
enum HealthMetricType {
  weight,
  bloodPressure,
  heartRate,
  temperature,
  bloodSugar,
  painLevel,
}

extension HealthMetricTypeExt on HealthMetricType {
  String get label => switch (this) {
        HealthMetricType.weight => '체중',
        HealthMetricType.bloodPressure => '혈압',
        HealthMetricType.heartRate => '심박수',
        HealthMetricType.temperature => '체온',
        HealthMetricType.bloodSugar => '혈당',
        HealthMetricType.painLevel => '통증 수치',
      };

  String get unit => switch (this) {
        HealthMetricType.weight => 'kg',
        HealthMetricType.bloodPressure => 'mmHg',
        HealthMetricType.heartRate => 'bpm',
        HealthMetricType.temperature => '°C',
        HealthMetricType.bloodSugar => 'mg/dL',
        HealthMetricType.painLevel => '/10',
      };

  String get apiKey => switch (this) {
        HealthMetricType.weight => 'weight',
        HealthMetricType.bloodPressure => 'blood_pressure',
        HealthMetricType.heartRate => 'heart_rate',
        HealthMetricType.temperature => 'temperature',
        HealthMetricType.bloodSugar => 'blood_sugar',
        HealthMetricType.painLevel => 'pain_level',
      };

  static HealthMetricType fromApi(String key) => switch (key) {
        'weight' => HealthMetricType.weight,
        'blood_pressure' => HealthMetricType.bloodPressure,
        'heart_rate' => HealthMetricType.heartRate,
        'temperature' => HealthMetricType.temperature,
        'blood_sugar' => HealthMetricType.bloodSugar,
        _ => HealthMetricType.painLevel,
      };
}

class HealthRecord {
  final int id;
  final HealthMetricType type;
  final double value;
  final double? value2; // 혈압 이완기
  final DateTime recordedAt;
  final String? notes;

  const HealthRecord({
    required this.id,
    required this.type,
    required this.value,
    this.value2,
    required this.recordedAt,
    this.notes,
  });

  factory HealthRecord.fromJson(Map<String, dynamic> json) => HealthRecord(
        id: json['id'] as int,
        type: HealthMetricTypeExt.fromApi(json['metric_type'] as String),
        value: (json['value'] as num).toDouble(),
        value2: (json['value2'] as num?)?.toDouble(),
        recordedAt: DateTime.parse(json['recorded_at'] as String),
        notes: json['notes'] as String?,
      );

  String get displayValue {
    if (type == HealthMetricType.bloodPressure && value2 != null) {
      return '${value.toStringAsFixed(0)}/${value2!.toStringAsFixed(0)} ${type.unit}';
    }
    return '${value.toStringAsFixed(1)} ${type.unit}';
  }
}

class HealthRecordInput {
  final HealthMetricType type;
  final double value;
  final double? value2;
  final DateTime recordedAt;
  final String? notes;

  const HealthRecordInput({
    required this.type,
    required this.value,
    this.value2,
    required this.recordedAt,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'metric_type': type.apiKey,
        'value': value,
        if (value2 != null) 'value2': value2,
        'recorded_at': recordedAt.toIso8601String(),
        if (notes != null) 'notes': notes,
      };
}
