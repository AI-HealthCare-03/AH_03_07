import '../../../core/api/api_client.dart';
import '../models/lab_models.dart';

class LabService {
  final ApiClient _client;

  const LabService({required ApiClient client}) : _client = client;

  Future<List<LabResult>> getResults() async {
    final res = await _client.getList('/v1/lab-results');
    if (!res.isSuccess) throw Exception(_friendlyError(res.statusCode, res.error));
    return (res.data ?? []).map(LabResult.fromJson).toList();
  }

  Future<LabResult> addResult(LabResultInput input) async {
    final res = await _client.post('/v1/lab-results', body: input.toJson());
    if (!res.isSuccess) throw Exception(_friendlyError(res.statusCode, res.error));
    return LabResult.fromJson(res.data!);
  }

  // 실제 API: PATCH (PUT 아님)
  Future<LabResult> updateResult(int id, LabResultInput input) async {
    final res = await _client.patch('/v1/lab-results/$id', body: input.toJson());
    if (!res.isSuccess) throw Exception(_friendlyError(res.statusCode, res.error));
    return LabResult.fromJson(res.data!);
  }

  Future<void> deleteResult(int id) async {
    final res = await _client.delete('/v1/lab-results/$id');
    if (!res.isSuccess) throw Exception(_friendlyError(res.statusCode, res.error));
  }

  String _friendlyError(int? statusCode, String? msg) {
    if (statusCode == 404) return '검사 결과를 찾을 수 없습니다.';
    if (statusCode == 401) return '로그인이 필요합니다.';
    return msg ?? '오류가 발생했습니다.';
  }
}
