// NFR-SEC-003: 민감정보 암호화 관리
// FlutterSecureStorage 기반 암호화 저장소 + 접근 감사 로그
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../logging/app_logger.dart';

class SecureDataManager {
  SecureDataManager._();
  static final SecureDataManager instance = SecureDataManager._();

  final _storage = const FlutterSecureStorage(
    webOptions: WebOptions(
      dbName: 'medapp_secure_v2',
      publicKey: 'medapp_sec_key',
    ),
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // 민감 데이터 키 목록 (감사 로그용)
  static const _sensitiveKeys = {
    'access_token', 'refresh_token', 'user_id', 'user_email',
    'medical_cache', 'consent_data',
  };

  Future<void> write(String key, String value) async {
    if (_sensitiveKeys.contains(key)) {
      logger.logSensitiveAccess('write:$key');
    }
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    if (_sensitiveKeys.contains(key)) {
      logger.logSensitiveAccess('read:$key');
    }
    return _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    if (_sensitiveKeys.contains(key)) {
      logger.logSensitiveAccess('delete:$key');
    }
    await _storage.delete(key: key);
  }

  Future<void> deleteAll() async {
    logger.warn(LogCategory.security, '전체 보안 데이터 삭제');
    await _storage.deleteAll();
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
