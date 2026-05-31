import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/gamification/models/gamification_models.dart';

void main() {
  group('UserPoints', () {
    test('레벨 1: 0포인트', () {
      final p = UserPoints(totalPoints: 0, todayCheckedIn: false);
      expect(p.level, equals(1));
      expect(p.levelName, equals('건강 새싹'));
      expect(p.nextLevelPoints, equals(100));
      expect(p.progressRatio, equals(0.0));
    });

    test('레벨 2: 100포인트', () {
      final p = UserPoints(totalPoints: 100, todayCheckedIn: false);
      expect(p.level, equals(2));
      expect(p.levelName, equals('건강 관리자'));
    });

    test('레벨 5: 1000포인트 이상', () {
      final p = UserPoints(totalPoints: 1000, todayCheckedIn: false);
      expect(p.level, equals(5));
      expect(p.levelName, equals('건강 마스터'));
      expect(p.progressRatio, equals(1.0));
    });

    test('progressRatio: 레벨 2(100) ~ 레벨 3(300) 사이 200포인트', () {
      final p = UserPoints(totalPoints: 200, todayCheckedIn: false);
      expect(p.progressRatio, closeTo(0.5, 0.001));
    });
  });

  group('Badge', () {
    test('획득한 뱃지는 isEarned true', () {
      final b = AppBadge(
        id: 'first_record',
        name: '첫 기록',
        description: '검사결과 첫 등록',
        icon: '🏅',
        isEarned: true,
      );
      expect(b.isEarned, isTrue);
    });
  });

  group('Reward', () {
    test('포인트 부족하면 canAfford false', () {
      final r = Reward(
        id: 'theme_green',
        name: '그린 테마',
        type: RewardType.theme,
        requiredPoints: 500,
        isOwned: false,
      );
      expect(r.canAfford(300), isFalse);
      expect(r.canAfford(500), isTrue);
    });
  });
}
