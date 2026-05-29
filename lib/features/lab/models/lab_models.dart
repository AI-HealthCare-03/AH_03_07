// 실제 백엔드 LabResultResponse 기준
// id, test_date, test_item, value, reference_range, note, created_at, updated_at
class LabResult {
  final int id;
  final DateTime testDate;
  final String testItem;
  final String value;
  final String? referenceRange;
  final String? note;
  final DateTime createdAt;

  const LabResult({
    required this.id,
    required this.testDate,
    required this.testItem,
    required this.value,
    this.referenceRange,
    this.note,
    required this.createdAt,
  });

  factory LabResult.fromJson(Map<String, dynamic> json) => LabResult(
        id: json['id'] as int,
        testDate: DateTime.parse(json['test_date'] as String),
        testItem: json['test_item'] as String,
        value: json['value'] as String,
        referenceRange: json['reference_range'] as String?,
        note: json['note'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

class LabResultInput {
  final DateTime testDate;
  final String testItem;
  final String value;
  final String? referenceRange;
  final String? note;

  const LabResultInput({
    required this.testDate,
    required this.testItem,
    required this.value,
    this.referenceRange,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'test_date':
            '${testDate.year}-${testDate.month.toString().padLeft(2, '0')}-${testDate.day.toString().padLeft(2, '0')}',
        'test_item': testItem,
        'value': value,
        if (referenceRange != null && referenceRange!.isNotEmpty)
          'reference_range': referenceRange,
        if (note != null && note!.isNotEmpty) 'note': note,
      };
}
