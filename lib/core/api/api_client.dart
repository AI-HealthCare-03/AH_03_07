// NFR-SCAL-001: 도메인 모듈 구조 기반 중앙 API 클라이언트
// NFR-SEC-001: JWT 자동 갱신 인터셉터 포함
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';
import '../../services/ocr_service.dart';

class ApiClient {
  final http.Client _client;
  final TokenStorage _storage;
  bool _isRefreshing = false;

  ApiClient({required TokenStorage storage, http.Client? client})
      : _storage = storage,
        _client = client ?? http.Client();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _storage.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  bool _isExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final exp = (jsonDecode(payload) as Map)['exp'] as int?;
      if (exp == null) return true;
      return DateTime.now().millisecondsSinceEpoch ~/ 1000 >= exp - 30;
    } catch (_) {
      return true;
    }
  }

  Future<void> _refreshIfNeeded() async {
    if (_isRefreshing) return;
    final token = await _storage.getAccessToken();
    if (token == null || !_isExpired(token)) return;

    _isRefreshing = true;
    try {
      final refresh = await _storage.getRefreshToken();
      if (refresh == null) throw const AuthException('리프레시 토큰 없음');
      final res = await _client.post(
        Uri.parse('${OcrConfig.baseUrl}/v1/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refresh}),
      ).timeout(OcrConfig.timeoutDuration);
      if (res.statusCode == 200) {
        final newToken = (jsonDecode(res.body) as Map)['access_token'] as String?;
        if (newToken != null) await _storage.saveAccessToken(newToken);
      } else {
        await _storage.deleteAll();
        throw const AuthException('세션이 만료됐습니다. 다시 로그인하세요.');
      }
    } finally {
      _isRefreshing = false;
    }
  }

  // 백엔드가 JSON 배열([])을 직접 반환하는 엔드포인트용
  Future<ApiResponse<List<Map<String, dynamic>>>> getList(String path) async {
    await _refreshIfNeeded();
    final res = await _client.get(
      Uri.parse('${OcrConfig.baseUrl}$path'),
      headers: await _authHeaders(),
    ).timeout(OcrConfig.timeoutDuration);
    try {
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final body = jsonDecode(res.body) as List;
        return ApiResponse.success(
          body.cast<Map<String, dynamic>>(),
          res.statusCode,
        );
      }
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final detail = body['detail'];
      final msg = detail is String ? detail : '오류가 발생했습니다.';
      return ApiResponse.failure(msg, res.statusCode);
    } catch (_) {
      return ApiResponse.failure('서버 응답을 처리할 수 없습니다.', res.statusCode);
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> get(String path) async {
    await _refreshIfNeeded();
    final res = await _client.get(
      Uri.parse('${OcrConfig.baseUrl}$path'),
      headers: await _authHeaders(),
    ).timeout(OcrConfig.timeoutDuration);
    return _parse(res);
  }

  Future<ApiResponse<Map<String, dynamic>>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    await _refreshIfNeeded();
    final res = await _client.post(
      Uri.parse('${OcrConfig.baseUrl}$path'),
      headers: await _authHeaders(),
      body: body != null ? jsonEncode(body) : null,
    ).timeout(OcrConfig.timeoutDuration);
    return _parse(res);
  }

  Future<ApiResponse<Map<String, dynamic>>> put(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    await _refreshIfNeeded();
    final res = await _client.put(
      Uri.parse('${OcrConfig.baseUrl}$path'),
      headers: await _authHeaders(),
      body: body != null ? jsonEncode(body) : null,
    ).timeout(OcrConfig.timeoutDuration);
    return _parse(res);
  }

  Future<ApiResponse<Map<String, dynamic>>> delete(String path) async {
    await _refreshIfNeeded();
    final res = await _client.delete(
      Uri.parse('${OcrConfig.baseUrl}$path'),
      headers: await _authHeaders(),
    ).timeout(OcrConfig.timeoutDuration);
    return _parse(res);
  }

  ApiResponse<Map<String, dynamic>> _parse(http.Response res) {
    try {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return ApiResponse.success(body, res.statusCode);
      }
      final detail = body['detail'];
      String msg;
      if (detail is String) {
        msg = detail;
      } else if (detail is List && detail.isNotEmpty) {
        // 422 Pydantic 유효성 오류: [{msg: '...', loc: [...]}]
        final first = detail.first;
        msg = (first is Map ? first['msg'] as String? : null) ?? '입력값을 확인해주세요.';
        // "Value error, " 접두사 제거
        msg = msg.replaceFirst('Value error, ', '');
      } else if (detail is Map) {
        msg = detail['message'] as String? ?? '오류가 발생했습니다.';
      } else {
        msg = '오류가 발생했습니다.';
      }
      return ApiResponse.failure(msg, res.statusCode);
    } catch (_) {
      return ApiResponse.failure('서버 응답을 처리할 수 없습니다.', res.statusCode);
    }
  }

  // NFR-AVAL-001: 헬스체크
  Future<bool> healthCheck() async {
    try {
      final res = await _client.get(
        Uri.parse('${OcrConfig.baseUrl}/health'),
      ).timeout(const Duration(seconds: 5));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  void dispose() => _client.close();
}
