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

class AppBadge {
  final String id;
  final String name;
  final String description;
  final String icon;
  final bool isEarned;

  const AppBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.isEarned,
  });

  static List<AppBadge> dummyList() => [
        const AppBadge(id: 'first_record',  name: '첫 기록',      description: '검사결과 첫 등록',    icon: '🏅', isEarned: true),
        const AppBadge(id: 'streak_7',      name: '7일 연속',      description: '7일 연속 출석',      icon: '🔥', isEarned: true),
        const AppBadge(id: 'streak_30',     name: '한 달 개근',    description: '30일 연속 출석',     icon: '🌟', isEarned: false),
        const AppBadge(id: 'med_10',        name: '복약 습관',     description: '복약 체크 10회',    icon: '💊', isEarned: true),
        const AppBadge(id: 'med_30',        name: '복약 마스터',   description: '복약 체크 30회',    icon: '🏆', isEarned: false),
        const AppBadge(id: 'chat_10',       name: '챗봇 친구',     description: '챗봇 10회 이용',    icon: '🤖', isEarned: false),
        const AppBadge(id: 'guide_reader',  name: '가이드 탐험가', description: '가이드 5개 읽기',   icon: '📖', isEarned: false),
        const AppBadge(id: 'lab_5',         name: '검사 기록왕',   description: '검사결과 5개 등록', icon: '🔬', isEarned: false),
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
        const Reward(id: 'title_guardian', name: '건강 지킴이',   type: RewardType.title, requiredPoints: 200, isOwned: true),
        const Reward(id: 'title_master',   name: '복약 마스터',   type: RewardType.title, requiredPoints: 300, isOwned: false),
        const Reward(id: 'title_explorer', name: '가이드 탐험가', type: RewardType.title, requiredPoints: 150, isOwned: false),
        const Reward(id: 'theme_green',    name: '그린 테마',     type: RewardType.theme, requiredPoints: 500, isOwned: false),
        const Reward(id: 'theme_blue',     name: '블루 테마',     type: RewardType.theme, requiredPoints: 500, isOwned: false),
        const Reward(id: 'theme_purple',   name: '퍼플 테마',     type: RewardType.theme, requiredPoints: 800, isOwned: false),
      ];
}
