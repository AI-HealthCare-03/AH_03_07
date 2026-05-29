// NFR-SEC-002: 사용자 역할 분리 테스트
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/auth/user_role.dart';

void main() {
  group('UserRoleHelper', () {
    test('patient 문자열을 UserRole.patient로 변환한다', () {
      expect(UserRoleHelper.fromString('patient'), UserRole.patient);
    });

    test('general 문자열을 UserRole.general로 변환한다', () {
      expect(UserRoleHelper.fromString('general'), UserRole.general);
    });

    test('null은 UserRole.general로 변환한다', () {
      expect(UserRoleHelper.fromString(null), UserRole.general);
    });

    test('알 수 없는 값은 UserRole.general로 변환한다', () {
      expect(UserRoleHelper.fromString('unknown'), UserRole.general);
    });

    group('canAccessMedical', () {
      test('patient는 의료 데이터에 접근 가능하다', () {
        expect(UserRoleHelper.canAccessMedical(UserRole.patient), isTrue);
      });

      test('general은 의료 데이터에 접근 불가하다', () {
        expect(UserRoleHelper.canAccessMedical(UserRole.general), isFalse);
      });
    });

    group('canAccessDiary', () {
      test('general은 증상일지에 접근 가능하다', () {
        expect(UserRoleHelper.canAccessDiary(UserRole.general), isTrue);
      });

      test('patient는 증상일지에 접근 불가하다', () {
        expect(UserRoleHelper.canAccessDiary(UserRole.patient), isFalse);
      });
    });

    test('toApi는 올바른 문자열을 반환한다', () {
      expect(UserRoleHelper.toApi(UserRole.patient), equals('patient'));
      expect(UserRoleHelper.toApi(UserRole.general), equals('general'));
    });
  });
}
