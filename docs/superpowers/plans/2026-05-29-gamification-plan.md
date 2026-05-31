# REQ-GAME-002 포인트·뱃지·보상 시스템 구현 플랜

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 마이페이지에 포인트·레벨·뱃지·보상 시스템을 더미 데이터로 구현하고, 나중에 API 연동으로 교체하기 쉬운 구조를 만든다.

**Architecture:** GamificationService가 더미 데이터를 반환하며, 추후 ApiClient 주입으로 실제 API 교체 가능. 마이페이지 상단에 PointCardWidget 추가, GamificationPage에서 뱃지/보상 탭 표시.

**Tech Stack:** Flutter, Dart, 기존 lib/features/ 도메인 구조 유지

---

## 파일 목록

| 파일 | 역할 |
|---|---|
| `lib/features/gamification/models/gamification_models.dart` | 모델 (UserPoints, Badge, Reward) |
| `lib/features/gamification/services/gamification_service.dart` | 더미 데이터 서비스 |
| `lib/features/gamification/widgets/point_card_widget.dart` | 포인트·레벨 카드 위젯 |
| `lib/features/gamification/widgets/badge_grid_widget.dart` | 뱃지 그리드 위젯 |
| `lib/features/gamification/widgets/reward_shop_widget.dart` | 보상 상점 위젯 |
| `lib/features/gamification/pages/gamification_page.dart` | 뱃지/보상 탭 페이지 |
| `lib/my_page.dart` | 포인트 카드 + 게임화 버튼 추가 |
| `test/features/gamification/gamification_models_test.dart` | 모델 단위 테스트 |
| `test/features/gamification/gamification_service_test.dart` | 서비스 단위 테스트 |

---

### Task 1: 모델 정의

**Files:**
- Create: `lib/features/gamification/models/gamification_models.dart`
- Create: `test/features/gamification/gamification_models_test.dart`

- [ ] **Step 1: 테스트 파일 작성**

`test/features/gamification/gamification_models_test.dart`:
```dart
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
      final b = Badge(
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
```

- [ ] **Step 2: 테스트 실행 — 실패 확인**

```bash
flutter test test/features/gamification/gamification_models_test.dart
```
Expected: FAIL (파일 없음)

- [ ] **Step 3: 모델 구현**

`lib/features/gamification/models/gamification_models.dart`:
```dart
enum RewardType { title, theme }

class UserPoints {
  final int totalPoints;
  final bool todayCheckedIn;

  const UserPoints({
    required this.totalPoints,
    required this.todayCheckedIn,
  });

  static const _levels = [
    (points: 0,    name: '건강 새싹'),
    (points: 100,  name: '건강 관리자'),
    (points: 300,  name: '건강 지킴이'),
    (points: 600,  name: '건강 전문가'),
    (points: 1000, name: '건강 마스터'),
  ];

  int get level {
    for (int i = _levels.length - 1; i >= 0; i--) {
      if (totalPoints >= _levels[i].points) return i + 1;
    }
    return 1;
  }

  String get levelName => _levels[level - 1].name;

  int get nextLevelPoints {
    if (level >= _levels.length) return _levels.last.points;
    return _levels[level].points;
  }

  int get currentLevelPoints => _levels[level - 1].points;

  double get progressRatio {
    if (level >= _levels.length) return 1.0;
    final range = nextLevelPoints - currentLevelPoints;
    if (range == 0) return 1.0;
    return ((totalPoints - currentLevelPoints) / range).clamp(0.0, 1.0);
  }

  factory UserPoints.dummy() => const UserPoints(
        totalPoints: 240,
        todayCheckedIn: false,
      );
}

class Badge {
  final String id;
  final String name;
  final String description;
  final String icon;
  final bool isEarned;

  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.isEarned,
  });

  static List<Badge> dummyList() => [
        const Badge(id: 'first_record',  name: '첫 기록',      description: '검사결과 첫 등록',   icon: '🏅', isEarned: true),
        const Badge(id: 'streak_7',      name: '7일 연속',      description: '7일 연속 출석',     icon: '🔥', isEarned: true),
        const Badge(id: 'streak_30',     name: '한 달 개근',    description: '30일 연속 출석',    icon: '🌟', isEarned: false),
        const Badge(id: 'med_10',        name: '복약 습관',     description: '복약 체크 10회',   icon: '💊', isEarned: true),
        const Badge(id: 'med_30',        name: '복약 마스터',   description: '복약 체크 30회',   icon: '🏆', isEarned: false),
        const Badge(id: 'chat_10',       name: '챗봇 친구',     description: '챗봇 10회 이용',   icon: '🤖', isEarned: false),
        const Badge(id: 'guide_reader',  name: '가이드 탐험가', description: '가이드 5개 읽기',  icon: '📖', isEarned: false),
        const Badge(id: 'lab_5',         name: '검사 기록왕',   description: '검사결과 5개 등록', icon: '🔬', isEarned: false),
      ];
}

class Reward {
  final String id;
  final String name;
  final RewardType type;
  final int requiredPoints;
  final bool isOwned;

  const Reward({
    required this.id,
    required this.name,
    required this.type,
    required this.requiredPoints,
    required this.isOwned,
  });

  bool canAfford(int userPoints) => userPoints >= requiredPoints;

  static List<Reward> dummyList() => [
        const Reward(id: 'title_guardian', name: '건강 지킴이', type: RewardType.title, requiredPoints: 200, isOwned: true),
        const Reward(id: 'title_master',   name: '복약 마스터', type: RewardType.title, requiredPoints: 300, isOwned: false),
        const Reward(id: 'title_explorer', name: '가이드 탐험가', type: RewardType.title, requiredPoints: 150, isOwned: false),
        const Reward(id: 'theme_green',    name: '그린 테마',   type: RewardType.theme, requiredPoints: 500, isOwned: false),
        const Reward(id: 'theme_blue',     name: '블루 테마',   type: RewardType.theme, requiredPoints: 500, isOwned: false),
        const Reward(id: 'theme_purple',   name: '퍼플 테마',   type: RewardType.theme, requiredPoints: 800, isOwned: false),
      ];
}
```

- [ ] **Step 4: 테스트 실행 — 통과 확인**

```bash
flutter test test/features/gamification/gamification_models_test.dart
```
Expected: All tests passed

- [ ] **Step 5: 커밋**

```bash
git add lib/features/gamification/models/gamification_models.dart test/features/gamification/gamification_models_test.dart
git commit -m "feat: gamification 모델 추가 (UserPoints, Badge, Reward)"
```

---

### Task 2: 서비스 구현

**Files:**
- Create: `lib/features/gamification/services/gamification_service.dart`
- Create: `test/features/gamification/gamification_service_test.dart`

- [ ] **Step 1: 테스트 작성**

`test/features/gamification/gamification_service_test.dart`:
```dart
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

  test('getBadges는 8개 뱃지를 반환한다', () async {
    final badges = await service.getBadges();
    expect(badges, hasLength(8));
  });

  test('getRewards는 6개 보상을 반환한다', () async {
    final rewards = await service.getRewards();
    expect(rewards, hasLength(6));
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
```

- [ ] **Step 2: 테스트 실행 — 실패 확인**

```bash
flutter test test/features/gamification/gamification_service_test.dart
```
Expected: FAIL

- [ ] **Step 3: 서비스 구현**

`lib/features/gamification/services/gamification_service.dart`:
```dart
import '../models/gamification_models.dart';

// API 연동 시 생성자에 ApiClient를 주입하고 더미 메서드를 실제 HTTP 호출로 교체
class GamificationService {
  UserPoints? _cachedPoints;
  List<Reward> _rewards = Reward.dummyList();

  Future<UserPoints> getPoints() async {
    _cachedPoints ??= UserPoints.dummy();
    return _cachedPoints!;
  }

  Future<List<Badge>> getBadges() async => Badge.dummyList();

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
    _rewards = List.of(_rewards)..[idx] = Reward(
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
```

- [ ] **Step 4: 테스트 실행 — 통과 확인**

```bash
flutter test test/features/gamification/gamification_service_test.dart
```
Expected: All tests passed

- [ ] **Step 5: 커밋**

```bash
git add lib/features/gamification/services/gamification_service.dart test/features/gamification/gamification_service_test.dart
git commit -m "feat: GamificationService 더미 데이터 구현"
```

---

### Task 3: 포인트 카드 위젯

**Files:**
- Create: `lib/features/gamification/widgets/point_card_widget.dart`

- [ ] **Step 1: 구현**

`lib/features/gamification/widgets/point_card_widget.dart`:
```dart
import 'package:flutter/material.dart';
import '../models/gamification_models.dart';
import '../services/gamification_service.dart';

class PointCardWidget extends StatefulWidget {
  final GamificationService service;
  const PointCardWidget({super.key, required this.service});

  @override
  State<PointCardWidget> createState() => _PointCardWidgetState();
}

class _PointCardWidgetState extends State<PointCardWidget> {
  UserPoints? _points;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await widget.service.getPoints();
    if (mounted) setState(() { _points = p; _loading = false; });
  }

  Future<void> _checkIn() async {
    final p = await widget.service.checkIn();
    if (mounted) setState(() => _points = p);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('출석 체크! +10 포인트 획득')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
    final p = _points!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2ECC71).withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Lv.${p.level} ${p.levelName}',
                      style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('${p.totalPoints} P',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
              ElevatedButton(
                onPressed: p.todayCheckedIn ? null : _checkIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF2ECC71),
                  disabledBackgroundColor: Colors.white38,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(p.todayCheckedIn ? '출석완료' : '출석체크'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                p.level < 5
                    ? '다음 레벨까지 ${p.nextLevelPoints - p.totalPoints}P'
                    : '최고 레벨 달성!',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                'Lv.${p.level < 5 ? p.level + 1 : p.level}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: p.progressRatio,
              backgroundColor: Colors.white30,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: 분석 확인**

```bash
flutter analyze lib/features/gamification/widgets/point_card_widget.dart
```
Expected: No issues found

- [ ] **Step 3: 커밋**

```bash
git add lib/features/gamification/widgets/point_card_widget.dart
git commit -m "feat: PointCardWidget 구현"
```

---

### Task 4: 뱃지 그리드 위젯

**Files:**
- Create: `lib/features/gamification/widgets/badge_grid_widget.dart`

- [ ] **Step 1: 구현**

`lib/features/gamification/widgets/badge_grid_widget.dart`:
```dart
import 'package:flutter/material.dart';
import '../models/gamification_models.dart';

class BadgeGridWidget extends StatelessWidget {
  final List<Badge> badges;
  const BadgeGridWidget({super.key, required this.badges});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: badges.length,
      itemBuilder: (_, i) => _BadgeTile(badge: badges[i]),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final Badge badge;
  const _BadgeTile({required this.badge});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('${badge.icon} ${badge.name}'),
          content: Text(badge.isEarned
              ? badge.description
              : '${badge.description}\n\n아직 획득하지 못했습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        ),
      ),
      child: Opacity(
        opacity: badge.isEarned ? 1.0 : 0.35,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: badge.isEarned
                    ? const Color(0xFFE8F8F0)
                    : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: badge.isEarned
                    ? Text(badge.icon, style: const TextStyle(fontSize: 26))
                    : const Icon(Icons.lock, color: Colors.grey, size: 22),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              badge.name,
              style: TextStyle(
                fontSize: 10,
                color: badge.isEarned ? Colors.black87 : Colors.grey,
                fontWeight: badge.isEarned ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: 분석 확인**

```bash
flutter analyze lib/features/gamification/widgets/badge_grid_widget.dart
```
Expected: No issues found

- [ ] **Step 3: 커밋**

```bash
git add lib/features/gamification/widgets/badge_grid_widget.dart
git commit -m "feat: BadgeGridWidget 구현 (획득=컬러, 미획득=흐릿+자물쇠)"
```

---

### Task 5: 보상 상점 위젯

**Files:**
- Create: `lib/features/gamification/widgets/reward_shop_widget.dart`

- [ ] **Step 1: 구현**

`lib/features/gamification/widgets/reward_shop_widget.dart`:
```dart
import 'package:flutter/material.dart';
import '../models/gamification_models.dart';
import '../services/gamification_service.dart';

class RewardShopWidget extends StatefulWidget {
  final GamificationService service;
  final int currentPoints;
  final VoidCallback onPurchased;
  const RewardShopWidget({
    super.key,
    required this.service,
    required this.currentPoints,
    required this.onPurchased,
  });

  @override
  State<RewardShopWidget> createState() => _RewardShopWidgetState();
}

class _RewardShopWidgetState extends State<RewardShopWidget> {
  List<Reward> _rewards = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await widget.service.getRewards();
    if (mounted) setState(() { _rewards = r; _loading = false; });
  }

  Future<void> _purchase(Reward reward) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(reward.name),
        content: Text('${reward.requiredPoints}P를 사용해 구매할까요?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('구매')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final result = await widget.service.purchaseReward(
      reward.id,
      currentPoints: widget.currentPoints,
    );
    if (!mounted) return;
    if (result != null) {
      widget.onPurchased();
      await _load();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${reward.name} 획득! -${reward.requiredPoints}P')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('포인트가 부족합니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final titles = _rewards.where((r) => r.type == RewardType.title).toList();
    final themes = _rewards.where((r) => r.type == RewardType.theme).toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: '칭호', icon: '🏷️'),
          const SizedBox(height: 8),
          ...titles.map((r) => _RewardTile(
                reward: r,
                currentPoints: widget.currentPoints,
                onBuy: () => _purchase(r),
              )),
          const SizedBox(height: 20),
          _SectionHeader(title: '테마', icon: '🎨'),
          const SizedBox(height: 8),
          ...themes.map((r) => _RewardTile(
                reward: r,
                currentPoints: widget.currentPoints,
                onBuy: () => _purchase(r),
              )),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) => Text(
        '$icon $title',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      );
}

class _RewardTile extends StatelessWidget {
  final Reward reward;
  final int currentPoints;
  final VoidCallback onBuy;
  const _RewardTile({required this.reward, required this.currentPoints, required this.onBuy});

  @override
  Widget build(BuildContext context) {
    final canAfford = reward.canAfford(currentPoints);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(reward.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${reward.requiredPoints}P 필요'),
        trailing: reward.isOwned
            ? const Chip(label: Text('보유중'), backgroundColor: Color(0xFFE8F8F0))
            : ElevatedButton(
                onPressed: canAfford ? onBuy : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('교환'),
              ),
      ),
    );
  }
}
```

- [ ] **Step 2: 분석 확인**

```bash
flutter analyze lib/features/gamification/widgets/reward_shop_widget.dart
```
Expected: No issues found

- [ ] **Step 3: 커밋**

```bash
git add lib/features/gamification/widgets/reward_shop_widget.dart
git commit -m "feat: RewardShopWidget 구현 (칭호·테마 교환)"
```

---

### Task 6: 게임화 페이지

**Files:**
- Create: `lib/features/gamification/pages/gamification_page.dart`

- [ ] **Step 1: 구현**

`lib/features/gamification/pages/gamification_page.dart`:
```dart
import 'package:flutter/material.dart';
import '../models/gamification_models.dart';
import '../services/gamification_service.dart';
import '../widgets/badge_grid_widget.dart';
import '../widgets/reward_shop_widget.dart';

class GamificationPage extends StatefulWidget {
  final GamificationService service;
  const GamificationPage({super.key, required this.service});

  @override
  State<GamificationPage> createState() => _GamificationPageState();
}

class _GamificationPageState extends State<GamificationPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<Badge> _badges = [];
  UserPoints? _points;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      widget.service.getBadges(),
      widget.service.getPoints(),
    ]);
    if (!mounted) return;
    setState(() {
      _badges = results[0] as List<Badge>;
      _points = results[1] as UserPoints;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('뱃지 · 보상'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2ECC71),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF2ECC71),
          tabs: const [
            Tab(text: '🏅 뱃지'),
            Tab(text: '🎁 보상'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                SingleChildScrollView(
                  child: BadgeGridWidget(badges: _badges),
                ),
                RewardShopWidget(
                  service: widget.service,
                  currentPoints: _points?.totalPoints ?? 0,
                  onPurchased: _load,
                ),
              ],
            ),
    );
  }
}
```

- [ ] **Step 2: 분석 확인**

```bash
flutter analyze lib/features/gamification/pages/gamification_page.dart
```
Expected: No issues found

- [ ] **Step 3: 커밋**

```bash
git add lib/features/gamification/pages/gamification_page.dart
git commit -m "feat: GamificationPage 뱃지·보상 탭 페이지 구현"
```

---

### Task 7: 마이페이지 연동

**Files:**
- Modify: `lib/my_page.dart`

- [ ] **Step 1: import 추가 및 service 인스턴스화**

`lib/my_page.dart` 상단 import에 추가:
```dart
import 'features/gamification/services/gamification_service.dart';
import 'features/gamification/widgets/point_card_widget.dart';
import 'features/gamification/pages/gamification_page.dart';
```

`_MyPageState` 필드에 추가:
```dart
final _gamificationService = GamificationService();
```

- [ ] **Step 2: _buildBody()에 PointCardWidget 추가**

`_buildBody()` 메서드의 `_buildProfileCard()` 바로 아래에 추가:
```dart
PointCardWidget(service: _gamificationService),
const SizedBox(height: 8),
```

- [ ] **Step 3: 뱃지·보상 메뉴 항목 추가**

`_buildBody()` 내 `_buildMenuCard(_healthMenuItems)` 위에 카드 추가:
```dart
_buildGamificationCard(),
const SizedBox(height: 16),
```

`_MyPageState`에 메서드 추가:
```dart
Widget _buildGamificationCard() {
  return GestureDetector(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GamificationPage(service: _gamificationService),
      ),
    ),
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8F8F0)),
      ),
      child: const Row(
        children: [
          Text('🏅', style: TextStyle(fontSize: 24)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('뱃지 · 보상',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text('획득한 뱃지와 포인트 보상을 확인하세요',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    ),
  );
}
```

- [ ] **Step 4: 전체 분석 확인**

```bash
flutter analyze lib/ test/
```
Expected: No issues found

- [ ] **Step 5: 커밋**

```bash
git add lib/my_page.dart
git commit -m "feat: 마이페이지에 포인트 카드 및 뱃지·보상 연동"
```

---

### Task 8: 최종 테스트 및 push

- [ ] **Step 1: 전체 테스트 실행**

```bash
flutter test
```
Expected: All tests passed

- [ ] **Step 2: push**

```bash
git push origin feature/이승혁-flutter
```
