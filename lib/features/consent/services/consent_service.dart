// NFR-COMPLI-001: 민감정보 처리·동의·삭제 정책
// NFR-COMPLI-004: 동의 이력·접근 통제
import '../../../core/api/api_client.dart';
import '../../../core/logging/app_logger.dart';

class ConsentItem {
  final int id;
  final String consentType;
  final bool agreed;
  final DateTime agreedAt;
  final String? ipAddress;

  const ConsentItem({
    required this.id,
    required this.consentType,
    required this.agreed,
    required this.agreedAt,
    this.ipAddress,
  });

  factory ConsentItem.fromJson(Map<String, dynamic> json) => ConsentItem(
        id: json['id'] as int? ?? 0,
        consentType: json['consent_type']?.toString() ?? '',
        agreed: json['agreed'] as bool? ?? false,
        agreedAt: DateTime.tryParse(json['agreed_at']?.toString() ?? '') ?? DateTime.now(),
        ipAddress: json['ip_address']?.toString(),
      );

  String get typeLabel => switch (consentType) {
    'terms'             => '서비스 이용약관',
    'privacy'           => '개인정보 처리방침',
    'sensitive_medical' => '민감 의료정보 처리',
    'marketing'         => '마케팅 정보 수신',
    _ => consentType,
  };
}

class ConsentService {
  final ApiClient _client;
  const ConsentService({required ApiClient client}) : _client = client;

  // 동의 이력 조회 (GET /api/v1/users/me/consents)
  Future<List<ConsentItem>> getConsentHistory() async {
    logger.info(LogCategory.consent, '동의 이력 조회');
    final res = await _client.getList('/v1/users/me/consents');
    if (!res.isSuccess) throw Exception(res.error ?? '동의 이력 조회 실패');
    return (res.data ?? []).map(ConsentItem.fromJson).toList();
  }

  // 동의 변경 (POST /api/v1/users/me/consents)
  Future<void> updateConsent(String consentType, bool agreed) async {
    logger.logConsentChanged(consentType, agreed);
    final res = await _client.post('/v1/users/me/consents', body: {
      'consent_type': consentType,
      'agreed': agreed,
    });
    if (!res.isSuccess) throw Exception(res.error ?? '동의 변경 실패');
  }
}
