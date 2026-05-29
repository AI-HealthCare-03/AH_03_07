import '../../../core/api/api_client.dart';
import '../models/health_models.dart';

class HealthService {
  final ApiClient _client;

  const HealthService({required ApiClient client}) : _client = client;

  Future<List<HealthRecord>> getRecords({
    HealthMetricType? type,
    DateTime? from,
    DateTime? to,
    int page = 1,
    int limit = 30,
  }) async {
    final params = StringBuffer('?page=$page&limit=$limit');
    if (type != null) params.write('&metric_type=${type.apiKey}');
    if (from != null) params.write('&from=${from.toIso8601String()}');
    if (to != null) params.write('&to=${to.toIso8601String()}');

    final res = await _client.get('/v1/health/records$params');
    if (!res.isSuccess) throw Exception(res.error);

    final items = (res.data!['records'] as List?) ?? [];
    return items.cast<Map<String, dynamic>>().map(HealthRecord.fromJson).toList();
  }

  Future<HealthRecord> addRecord(HealthRecordInput input) async {
    final res = await _client.post('/v1/health/records', body: input.toJson());
    if (!res.isSuccess) throw Exception(res.error);
    return HealthRecord.fromJson(res.data!);
  }

  Future<void> deleteRecord(int id) async {
    final res = await _client.delete('/v1/health/records/$id');
    if (!res.isSuccess) throw Exception(res.error);
  }

  // 최근 7일 요약 (대시보드용)
  Future<Map<HealthMetricType, HealthRecord?>> getLatestRecords() async {
    final res = await _client.get('/v1/health/records/latest');
    if (!res.isSuccess) return {};

    final data = res.data!['latest'] as Map<String, dynamic>? ?? {};
    return {
      for (final entry in data.entries)
        HealthMetricTypeExt.fromApi(entry.key):
            HealthRecord.fromJson(entry.value as Map<String, dynamic>),
    };
  }
}
