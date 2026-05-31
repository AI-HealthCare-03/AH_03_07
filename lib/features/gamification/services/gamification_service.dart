import '../models/gamification_models.dart';

// API 연동 시 생성자에 ApiClient를 주입하고 더미 메서드를 실제 HTTP 호출로 교체
class GamificationService {
  UserPoints? _cachedPoints;
  List<Reward> _rewards = Reward.dummyList();

  Future<UserPoints> getPoints() async {
    _cachedPoints ??= UserPoints.dummy();
    return _cachedPoints!;
  }

  Future<List<AppBadge>> getBadges() async => AppBadge.dummyList();

  Future<List<Reward>> getRewards() async => List.unmodifiable(_rewards);

  Future<UserPoints> checkIn() async {
    final current = await getPoints();
    if (current.todayCheckedIn) return current;
    _cachedPoints = UserPoints(
      totalPoints: current.totalPoints + 10,
      todayCheckedIn: true,
    );
    return _cachedPoints!;
  }

  Future<Reward?> purchaseReward(String rewardId, {required int currentPoints}) async {
    final idx = _rewards.indexWhere((r) => r.id == rewardId);
    if (idx == -1) return null;
    final reward = _rewards[idx];
    if (!reward.canAfford(currentPoints)) return null;
    _rewards = List.of(_rewards)
      ..[idx] = Reward(
        id: reward.id,
        name: reward.name,
        type: reward.type,
        requiredPoints: reward.requiredPoints,
        isOwned: true,
      );
    _cachedPoints = UserPoints(
      totalPoints: currentPoints - reward.requiredPoints,
      todayCheckedIn: _cachedPoints?.todayCheckedIn ?? false,
    );
    return _rewards[idx];
  }
}
