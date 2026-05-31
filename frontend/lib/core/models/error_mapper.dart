// P3: 사용자 친화적 에러 메시지 매핑 레이어
class ErrorMapper {
  ErrorMapper._();

  static String toUserMessage(int? statusCode, String? rawMessage) {
    switch (statusCode) {
      case 400: return '입력값을 확인해주세요.';
      case 401: return '로그인이 필요합니다.';
      case 403: return '접근 권한이 없습니다.';
      case 404: return '요청한 정보를 찾을 수 없습니다.';
      case 409: return '이미 존재하는 데이터입니다.';
      case 422: return rawMessage?.replaceFirst('Value error, ', '') ?? '입력값을 확인해주세요.';
      case 429: return '요청이 너무 많습니다. 잠시 후 다시 시도해주세요.';
      case 500:
      case 502:
      case 503: return '서버에 일시적인 문제가 발생했습니다. 잠시 후 다시 시도해주세요.';
      default:
        if (rawMessage != null && rawMessage.isNotEmpty && !rawMessage.contains('Exception')) {
          return rawMessage;
        }
        return '오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
    }
  }
}
