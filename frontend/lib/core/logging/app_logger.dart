// NFR-MNTN-001: 구조화 로그 서비스
// 장애 추적·감사 대응을 위한 구조화된 이벤트 로그
import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warn, error }

enum LogCategory {
  auth,       // 인증/인가
  api,        // API 호출
  consent,    // 동의 이력
  access,     // 접근 통제
  security,   // 보안 이벤트
  userAction, // 사용자 행동
  error,      // 에러
}

class LogEvent {
  final DateTime timestamp;
  final LogLevel level;
  final LogCategory category;
  final String message;
  final Map<String, dynamic>? data;

  const LogEvent({
    required this.timestamp,
    required this.level,
    required this.category,
    required this.message,
    this.data,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'level': level.name,
        'category': category.name,
        'message': message,
        if (data != null) 'data': data,
      };

  @override
  String toString() =>
      '[${timestamp.toIso8601String()}] [${level.name.toUpperCase()}] [${category.name}] $message'
      '${data != null ? ' | ${data.toString()}' : ''}';
}

class AppLogger {
  AppLogger._();
  static final AppLogger instance = AppLogger._();

  final List<LogEvent> _buffer = [];
  static const int _maxBuffer = 500;

  void _log(LogLevel level, LogCategory category, String message, [Map<String, dynamic>? data]) {
    final event = LogEvent(
      timestamp: DateTime.now(),
      level: level,
      category: category,
      message: message,
      data: data,
    );

    _buffer.add(event);
    if (_buffer.length > _maxBuffer) _buffer.removeAt(0);

    if (kDebugMode) {
      // ignore: avoid_print
      print(event.toString());
    }
  }

  // ── 레벨별 메서드 ──
  void debug(LogCategory cat, String msg, [Map<String, dynamic>? data]) =>
      _log(LogLevel.debug, cat, msg, data);
  void info(LogCategory cat, String msg, [Map<String, dynamic>? data]) =>
      _log(LogLevel.info, cat, msg, data);
  void warn(LogCategory cat, String msg, [Map<String, dynamic>? data]) =>
      _log(LogLevel.warn, cat, msg, data);
  void error(LogCategory cat, String msg, [Map<String, dynamic>? data]) =>
      _log(LogLevel.error, cat, msg, data);

  // ── 도메인별 편의 메서드 ──
  void logLogin(String method) =>
      info(LogCategory.auth, '로그인 성공', {'method': method});

  void logLogout() =>
      info(LogCategory.auth, '로그아웃');

  void logWithdraw(String? reason) =>
      warn(LogCategory.auth, '회원탈퇴', {'reason': reason ?? '미입력'});

  void logApiCall(String method, String path, int statusCode, int durationMs) =>
      info(LogCategory.api, 'API 호출', {
        'method': method,
        'path': path,
        'status': statusCode,
        'duration_ms': durationMs,
      });

  void logApiError(String method, String path, dynamic error) =>
      AppLogger.instance.error(LogCategory.api, 'API 오류', {
        'method': method,
        'path': path,
        'error': error.toString(),
      });

  void logConsentChanged(String consentType, bool agreed) =>
      info(LogCategory.consent, '동의 변경', {
        'type': consentType,
        'agreed': agreed,
      });

  void logAccessDenied(String feature, String reason) =>
      warn(LogCategory.access, '접근 거부', {
        'feature': feature,
        'reason': reason,
      });

  void logSensitiveAccess(String dataType) =>
      info(LogCategory.security, '민감정보 접근', {'data_type': dataType});

  // ── 로그 조회 ──
  List<LogEvent> getRecentLogs({int limit = 100, LogCategory? category, LogLevel? minLevel}) {
    var logs = _buffer.reversed.toList();
    if (category != null) logs = logs.where((l) => l.category == category).toList();
    if (minLevel != null) {
      logs = logs.where((l) => l.level.index >= minLevel.index).toList();
    }
    return logs.take(limit).toList();
  }

  void clearLogs() => _buffer.clear();
}

// 전역 편의 접근자
final logger = AppLogger.instance;
