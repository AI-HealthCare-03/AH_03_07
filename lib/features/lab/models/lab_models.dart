// 백엔드 LabResultResponse 스키마 기준
// id, test_date, test_type, user_recorded_value, reference_range, unit, memo
class LabResult {
  final int id;
  final DateTime testDate;
  final String testType;
  final String userRecordedValue;
  final String? referenceRange;
  final String? unit;
  final String? memo;
  final DateTime createdAt;

  const LabResult({
    required this.id,
    required this.testDate,
    required this.testType,
    required this.userRecordedValue,
    this.referenceRange,
    this.unit,
    this.memo,
    required this.createdAt,
  });

  factory LabResult.fromJson(Map<String, dynamic> json) => LabResult(
        id: json['id'] as int,
        testDate: DateTime.parse(json['test_date'] as String),
        testType: json['test_type'] as String,
        userRecordedValue: json['user_recorded_value'] as String,
        referenceRange: json['reference_range'] as String?,
        unit: json['unit'] as String?,
        memo: json['memo'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  String get displayValue =>
      unit != null ? '$userRecordedValue $unit' : userRecordedValue;
}

class LabResultInput {
  final DateTime testDate;
  final String testType;
  final String userRecordedValue;
  final String? referenceRange;
  final String? unit;
  final String? memo;

  const LabResultInput({
    required this.testDate,
    required this.testType,
    required this.userRecordedValue,
    this.referenceRange,
    this.unit,
    this.memo,
  });

  Map<String, dynamic> toJson() => {
        'test_date':
            '${testDate.year}-${testDate.month.toString().padLeft(2, '0')}-${testDate.day.toString().padLeft(2, '0')}',
        'test_type': testType,
        'user_recorded_value': userRecordedValue,
        if (referenceRange != null) 'reference_range': referenceRange,
        if (unit != null) 'unit': unit,
        if (memo != null) 'memo': memo,
      };
}
