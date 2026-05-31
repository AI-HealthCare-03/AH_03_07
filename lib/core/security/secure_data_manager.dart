// NFR-SEC-003: 민감정보 암호화 관리
// P2: SecureTokenStorage 단일 인스턴스 사용으로 통합
import '../logging/app_logger.dart';
import '../../main.dart'; // SecureTokenStorage.readKey / writeKey

class SecureDataManager {
  SecureDataManager._();
  static final SecureDataManager instance = SecureDataManager._();

  static const _sensitiveKeys = {
    'access_token', 'refresh_token', 'user_id', 'user_email', 'is_logged_out',
    'consent_terms', 'consent_privacy', 'consent_sensitive_medical', 'consent_marketing',
  };

  Future<void> write(String key, String value) async {
    if (_sensitiveKeys.contains(key)) logger.logSensitiveAccess('write:$key');
    await SecureTokenStorage.writeKey(key, value);
  }

  Future<String?> read(String key) async {
    if (_sensitiveKeys.contains(key)) logger.logSensitiveAccess('read:$key');
    return SecureTokenStorage.readKey(key);
  }

  Future<void> delete(String key) async {
    if (_sensitiveKeys.contains(key)) logger.logSensitiveAccess('delete:$key');
    await SecureTokenStorage.deleteKey(key);
  }

  // 동의 데이터 저장 (NFR-COMPLI-001)
  Future<void> saveConsents(Map<String, bool> consents) async {
    for (final entry in consents.entries) {
      await write('consent_${entry.key}', entry.value.toString());
      logger.logConsentChanged(entry.key, entry.value);
    }
  }

  Future<Map<String, bool>> loadConsents() async {
    final keys = ['terms', 'privacy', 'sensitive_medical', 'marketing'];
    final result = <String, bool>{};
    for (final key in keys) {
      final v = await read('consent_$key');
      result[key] = v == 'true';
    }
    return result;
  }
}

final secureData = SecureDataManager.instance;
