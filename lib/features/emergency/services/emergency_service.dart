// REQ-EMRG-001: 응급 SOS — 보호자 공유 API 기반
// 자동 신고 절대 금지, 119 직접 발신 원칙
import '../../../core/api/api_client.dart';

class EmergencyService {
  final ApiClient _client;

  const EmergencyService({required ApiClient client}) : _client = client;

  // 보호자 목록 조회 (GET /v1/guardians/shares)
  Future<List<GuardianContact>> getContacts() async {
    final res = await _client.getList('/v1/guardians/shares');
    if (!res.isSuccess) throw Exception(_friendlyError(res.statusCode, res.error));
    return (res.data ?? []).map(GuardianContact.fromJson).toList();
  }

  // 보호자 추가 (POST /v1/guardians/shares)
  Future<GuardianContact> addContact({
    required String name,
    required String phone,
  }) async {
    // expires_at: 1년 후
    final expiresAt = DateTime.now().add(const Duration(days: 365));
    final res = await _client.post('/v1/guardians/shares', body: {
      'guardian_name': name,
      'guardian_contact': phone,
      'share_categories': ['medical_records'],
      'expires_at': expiresAt.toIso8601String(),
    });
    if (!res.isSuccess) throw Exception(_friendlyError(res.statusCode, res.error));
    return GuardianContact.fromJson(res.data!);
  }

  // 보호자 삭제 (DELETE /v1/guardians/shares/{id})
  Future<void> deleteContact(int id) async {
    final res = await _client.delete('/v1/guardians/shares/$id');
    if (!res.isSuccess) throw Exception(_friendlyError(res.statusCode, res.error));
  }

  String _friendlyError(int? statusCode, String? msg) {
    if (statusCode == 400) return msg ?? '보호자는 최대 3명까지 등록 가능합니다.';
    if (statusCode == 401) return '로그인이 필요합니다.';
    return msg ?? '오류가 발생했습니다.';
  }
}

class GuardianContact {
  final int id;
  final String name;
  final String phone;
  final bool isRevoked;
  final DateTime expiresAt;

  const GuardianContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.isRevoked,
    required this.expiresAt,
  });

  factory GuardianContact.fromJson(Map<String, dynamic> json) => GuardianContact(
        id: json['id'] as int,
        name: json['guardian_name'] as String,
        phone: json['guardian_contact'] as String,
        isRevoked: json['is_revoked'] as bool? ?? false,
        expiresAt: DateTime.parse(json['expires_at'] as String),
      );

  bool get isActive => !isRevoked && expiresAt.isAfter(DateTime.now());
}
