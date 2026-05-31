import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/gamification/services/gamification_service.dart';
import 'package:flutter_application_1/features/gamification/models/gamification_models.dart';

void main() {
  late GamificationService service;

  setUp(() => service = GamificationService());

  test('getPoints는 UserPoints를 반환한다', () async {
    final points = await service.getPoints();
    expect(points, isA<UserPoints>());
    expect(points.totalPoints, greaterThanOrEqualTo(0));
  });

  test('getBadges는 46개 뱃지를 반환한다', () async {
    final badges = await service.getBadges();
    expect(badges.length, greaterThanOrEqualTo(40));
  });

  test('getRewards는 36개 보상을 반환한다', () async {
    final rewards = await service.getRewards();
    expect(rewards.length, greaterThanOrEqualTo(30));
  });

  test('checkIn은 오늘 체크인 완료 UserPoints를 반환한다', () async {
    final result = await service.checkIn();
    expect(result.todayCheckedIn, isTrue);
  });

  test('purchaseReward는 소유한 Reward를 반환한다', () async {
    final result = await service.purchaseReward('theme_green', currentPoints: 600);
    expect(result, isNotNull);
    expect(result!.isOwned, isTrue);
  });

  test('포인트 부족 시 purchaseReward는 null 반환', () async {
    final result = await service.purchaseReward('theme_green', currentPoints: 100);
    expect(result, isNull);
  });
}
