// REQ-EMRG-001: 응급 SOS (보조 도구 — 119 직접 발신 원칙)
// 자동 신고 절대 금지, 사용자 직접 버튼 조작 트리거만 허용
import '../../../core/api/api_client.dart';

class EmergencyService {
  final ApiClient _client;

  const EmergencyService({required ApiClient client}) : _client = client;

  // 보호자에게 보안링크 전송 (사용자가 직접 버튼을 누른 경우에만 호출)
  Future<EmergencySosResult> sendSos({
    double? latitude,
    double? longitude,
    String? message,
  }) async {
    final res = await _client.post('/v1/emergency/sos', body: {
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (message != null && message.isNotEmpty) 'message': message,
    });
    if (!res.isSuccess) throw Exception(res.error);
    return EmergencySosResult.fromJson(res.data!);
  }

  Future<List<EmergencyContact>> getContacts() async {
    final res = await _client.get('/v1/emergency/contacts');
    if (!res.isSuccess) throw Exception(res.error);
    final items = (res.data!['contacts'] as List?) ?? [];
    return items.cast<Map<String, dynamic>>().map(EmergencyContact.fromJson).toList();
  }

  Future<EmergencyContact> addContact({
    required String name,
    required String phone,
    String? relation,
  }) async {
    final res = await _client.post('/v1/emergency/contacts', body: {
      'name': name,
      'phone': phone,
      if (relation != null) 'relation': relation,
    });
    if (!res.isSuccess) throw Exception(res.error);
    return EmergencyContact.fromJson(res.data!);
  }

  Future<void> deleteContact(int id) async {
    final res = await _client.delete('/v1/emergency/contacts/$id');
    if (!res.isSuccess) throw Exception(res.error);
  }
}

class EmergencyContact {
  final int id;
  final String name;
  final String phone;
  final String? relation;

  const EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    this.relation,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) => EmergencyContact(
        id: json['id'] as int,
        name: json['name'] as String,
        phone: json['phone'] as String,
        relation: json['relation'] as String?,
      );
}

class EmergencySosResult {
  final bool sent;
  final int notifiedCount;
  final String? secureLink;

  const EmergencySosResult({
    required this.sent,
    required this.notifiedCount,
    this.secureLink,
  });

  factory EmergencySosResult.fromJson(Map<String, dynamic> json) => EmergencySosResult(
        sent: json['sent'] as bool? ?? false,
        notifiedCount: json['notified_count'] as int? ?? 0,
        secureLink: json['secure_link'] as String?,
      );
}
