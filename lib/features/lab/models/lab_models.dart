// REQ-LAB 관련 모델 (API 명세서 LAB 카테고리)
class LabResult {
  final int id;
  final String testName;
  final String testCode;
  final double value;
  final String unit;
  final double? referenceMin;
  final double? referenceMax;
  final String status; // normal | low | high | critical
  final DateTime testedAt;
  final String? notes;

  const LabResult({
    required this.id,
    required this.testName,
    required this.testCode,
    required this.value,
    required this.unit,
    this.referenceMin,
    this.referenceMax,
    required this.status,
    required this.testedAt,
    this.notes,
  });

  factory LabResult.fromJson(Map<String, dynamic> json) => LabResult(
        id: json['id'] as int,
        testName: json['test_name'] as String,
        testCode: json['test_code'] as String,
        value: (json['value'] as num).toDouble(),
        unit: json['unit'] as String,
        referenceMin: (json['reference_min'] as num?)?.toDouble(),
        referenceMax: (json['reference_max'] as num?)?.toDouble(),
        status: json['status'] as String? ?? 'normal',
        testedAt: DateTime.parse(json['tested_at'] as String),
        notes: json['notes'] as String?,
      );

  bool get isAbnormal => status != 'normal';
  bool get isCritical => status == 'critical';
}

class LabResultInput {
  final String testName;
  final String testCode;
  final double value;
  final String unit;
  final DateTime testedAt;
  final String? notes;

  const LabResultInput({
    required this.testName,
    required this.testCode,
    required this.value,
    required this.unit,
    required this.testedAt,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'test_name': testName,
        'test_code': testCode,
        'value': value,
        'unit': unit,
        'tested_at': testedAt.toIso8601String(),
        if (notes != null) 'notes': notes,
      };
}
