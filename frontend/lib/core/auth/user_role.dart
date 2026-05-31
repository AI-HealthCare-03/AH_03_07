// NFR-SEC-002: 사용자별 권한 분리
enum UserRole { general, patient }

class UserRoleHelper {
  static UserRole fromString(String? value) {
    if (value == 'patient') return UserRole.patient;
    return UserRole.general;
  }

  static String toApi(UserRole role) =>
      role == UserRole.patient ? 'patient' : 'general';

  // 의료 데이터(검사결과, 자가면역 가이드) 접근 가능 여부
  static bool canAccessMedical(UserRole role) => role == UserRole.patient;

  // 일반 모드 전용 기능 (증상일지, 통합일정)
  static bool canAccessDiary(UserRole role) => role == UserRole.general;
}
