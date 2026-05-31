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
        id: (json['id'] as num?)?.toInt() ?? 0,
        testDate: _parseDate(json['test_date']),
        testItem: json['test_item']?.toString() ?? '',
        value: json['value']?.toString() ?? '',
        referenceRange: json['reference_range']?.toString(),
        note: json['note']?.toString(),
        createdAt: _parseDate(json['created_at']),
      );

  static DateTime _parseDate(dynamic v) {
    try { return DateTime.parse(v.toString()); } catch (_) { return DateTime.now(); }
  }
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
