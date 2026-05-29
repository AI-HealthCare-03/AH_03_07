import '../../../core/api/api_client.dart';
import '../models/lab_models.dart';

class LabService {
  final ApiClient _client;

  const LabService({required ApiClient client}) : _client = client;

  Future<List<LabResult>> getResults({
    String? testCode,
    DateTime? from,
    DateTime? to,
    int page = 1,
    int limit = 20,
  }) async {
    final params = StringBuffer('?page=$page&limit=$limit');
    if (testCode != null) params.write('&test_code=$testCode');
    if (from != null) params.write('&from=${from.toIso8601String()}');
    if (to != null) params.write('&to=${to.toIso8601String()}');

    final res = await _client.get('/v1/lab/results$params');
    if (!res.isSuccess) throw Exception(res.error);

    final items = (res.data!['results'] as List?) ?? [];
    return items
        .cast<Map<String, dynamic>>()
        .map(LabResult.fromJson)
        .toList();
  }

  Future<LabResult> addResult(LabResultInput input) async {
    final res = await _client.post(
      '/v1/lab/results',
      body: input.toJson(),
    );
    if (!res.isSuccess) throw Exception(res.error);
    return LabResult.fromJson(res.data!);
  }

  Future<LabResult> getResult(int id) async {
    final res = await _client.get('/v1/lab/results/$id');
    if (!res.isSuccess) throw Exception(res.error);
    return LabResult.fromJson(res.data!);
  }

  Future<void> deleteResult(int id) async {
    final res = await _client.delete('/v1/lab/results/$id');
    if (!res.isSuccess) throw Exception(res.error);
  }
}
