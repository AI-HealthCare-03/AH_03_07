import '../../../core/api/api_client.dart';
import '../models/lab_models.dart';

class LabService {
  final ApiClient _client;

  const LabService({required ApiClient client}) : _client = client;

  Future<List<LabResult>> getResults({
    DateTime? from,
    DateTime? to,
    int page = 1,
    int size = 20,
  }) async {
    final params = StringBuffer('?page=$page&size=$size');
    if (from != null) {
      params.write(
          '&date_from=${from.year}-${from.month.toString().padLeft(2, '0')}-${from.day.toString().padLeft(2, '0')}');
    }
    if (to != null) {
      params.write(
          '&date_to=${to.year}-${to.month.toString().padLeft(2, '0')}-${to.day.toString().padLeft(2, '0')}');
    }

    // 백엔드 엔드포인트: /v1/lab-results (List 반환)
    final res = await _client.getList('/v1/lab-results$params');
    if (!res.isSuccess) throw Exception(_friendlyError(res.statusCode, res.error));
    return (res.data ?? []).map(LabResult.fromJson).toList();
  }

  Future<LabResult> addResult(LabResultInput input) async {
    final res = await _client.post('/v1/lab-results', body: input.toJson());
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
