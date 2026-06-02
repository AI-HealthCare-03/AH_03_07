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
        // 출석
        const AppBadge(id: 'checkin_1',     name: '첫 출석',        description: '첫 출석체크 완료',         icon: '👋', isEarned: true),
        const AppBadge(id: 'streak_3',      name: '3일 연속',        description: '3일 연속 출석',            icon: '🌱', isEarned: true),
        const AppBadge(id: 'streak_7',      name: '7일 연속',        description: '7일 연속 출석',            icon: '🔥', isEarned: true),
        const AppBadge(id: 'streak_14',     name: '2주 개근',        description: '14일 연속 출석',           icon: '⚡', isEarned: false),
        const AppBadge(id: 'streak_30',     name: '한 달 개근',      description: '30일 연속 출석',           icon: '🌟', isEarned: false),
        const AppBadge(id: 'streak_60',     name: '두 달 개근',      description: '60일 연속 출석',           icon: '💫', isEarned: false),
        const AppBadge(id: 'streak_100',    name: '100일의 기적',    description: '100일 연속 출석',          icon: '🎯', isEarned: false),
        const AppBadge(id: 'streak_365',    name: '1년 개근왕',      description: '365일 연속 출석',          icon: '👑', isEarned: false),
        // 복약
        const AppBadge(id: 'med_1',         name: '첫 복약',         description: '복약 체크 첫 완료',        icon: '💊', isEarned: true),
        const AppBadge(id: 'med_10',        name: '복약 습관',        description: '복약 체크 10회',           icon: '🩺', isEarned: true),
        const AppBadge(id: 'med_30',        name: '복약 마스터',      description: '복약 체크 30회',           icon: '🏆', isEarned: false),
        const AppBadge(id: 'med_50',        name: '복약 전문가',      description: '복약 체크 50회',           icon: '🎖️', isEarned: false),
        const AppBadge(id: 'med_100',       name: '복약 레전드',      description: '복약 체크 100회',          icon: '🦸', isEarned: false),
        // 검사결과
        const AppBadge(id: 'lab_1',         name: '첫 기록',          description: '검사결과 첫 등록',         icon: '🏅', isEarned: true),
        const AppBadge(id: 'lab_5',         name: '검사 기록왕',      description: '검사결과 5개 등록',        icon: '🔬', isEarned: false),
        const AppBadge(id: 'lab_10',        name: '검사 전문가',      description: '검사결과 10개 등록',       icon: '🧬', isEarned: false),
        const AppBadge(id: 'lab_20',        name: '검사 마스터',      description: '검사결과 20개 등록',       icon: '🔭', isEarned: false),
        const AppBadge(id: 'lab_50',        name: '검사 레전드',      description: '검사결과 50개 등록',       icon: '🏰', isEarned: false),
        // 챗봇
        const AppBadge(id: 'chat_1',        name: '첫 대화',          description: '챗봇 첫 이용',             icon: '💬', isEarned: true),
        const AppBadge(id: 'chat_10',       name: '챗봇 친구',        description: '챗봇 10회 이용',           icon: '🤖', isEarned: false),
        const AppBadge(id: 'chat_30',       name: '챗봇 단골',        description: '챗봇 30회 이용',           icon: '🗣️', isEarned: false),
        const AppBadge(id: 'chat_50',       name: '챗봇 마스터',      description: '챗봇 50회 이용',           icon: '🧠', isEarned: false),
        const AppBadge(id: 'chat_100',      name: '챗봇 레전드',      description: '챗봇 100회 이용',          icon: '🌐', isEarned: false),
        // 가이드
        const AppBadge(id: 'guide_1',       name: '첫 가이드',        description: '가이드 첫 읽기',           icon: '📖', isEarned: true),
        const AppBadge(id: 'guide_5',       name: '가이드 탐험가',    description: '가이드 5개 읽기',          icon: '🗺️', isEarned: false),
        const AppBadge(id: 'guide_10',      name: '가이드 수집가',    description: '가이드 10개 읽기',         icon: '📚', isEarned: false),
        const AppBadge(id: 'guide_20',      name: '가이드 박사',      description: '가이드 20개 읽기',         icon: '🎓', isEarned: false),
        // 포인트
        const AppBadge(id: 'point_100',     name: '새싹 투자자',      description: '포인트 100P 달성',         icon: '🌿', isEarned: true),
        const AppBadge(id: 'point_300',     name: '성장하는 중',      description: '포인트 300P 달성',         icon: '🌳', isEarned: false),
        const AppBadge(id: 'point_500',     name: '포인트 수집가',    description: '포인트 500P 달성',         icon: '💰', isEarned: false),
        const AppBadge(id: 'point_1000',    name: '포인트 부자',      description: '포인트 1000P 달성',        icon: '💎', isEarned: false),
        const AppBadge(id: 'point_3000',    name: '포인트 왕',        description: '포인트 3000P 달성',        icon: '👸', isEarned: false),
        // 보상 교환
        const AppBadge(id: 'first_reward',  name: '첫 교환',          description: '보상 첫 교환 완료',        icon: '🎁', isEarned: false),
        const AppBadge(id: 'reward_3',      name: '쇼핑왕',           description: '보상 3개 교환',            icon: '🛍️', isEarned: false),
        const AppBadge(id: 'reward_10',     name: '수집 마니아',      description: '보상 10개 교환',           icon: '🗝️', isEarned: false),
        // 건강 기록
        const AppBadge(id: 'health_week',   name: '건강 일주일',      description: '7일간 건강기록 입력',      icon: '📅', isEarned: false),
        const AppBadge(id: 'health_month',  name: '건강 한 달',       description: '30일간 건강기록 입력',     icon: '📆', isEarned: false),
        // 특별
        const AppBadge(id: 'early_bird',    name: '얼리버드',         description: '오전 7시 이전 출석체크',   icon: '🌅', isEarned: false),
        const AppBadge(id: 'night_owl',     name: '야행성',           description: '오후 11시 이후 출석체크',  icon: '🦉', isEarned: false),
        const AppBadge(id: 'new_year',      name: '새해 다짐',        description: '1월 1일 출석체크',         icon: '🎆', isEarned: false),
        const AppBadge(id: 'comeback',      name: '컴백',             description: '7일 공백 후 복귀',         icon: '🔄', isEarned: false),
        const AppBadge(id: 'perfect_week',  name: '완벽한 일주일',    description: '7일 모든 미션 완료',       icon: '✨', isEarned: false),
        const AppBadge(id: 'all_rounder',   name: '올라운더',         description: '모든 카테고리 1회 이상',   icon: '🌈', isEarned: false),
        const AppBadge(id: 'social',        name: '소셜 버터플라이',  description: '챗봇·가이드·기록 같은 날', icon: '🦋', isEarned: false),
        const AppBadge(id: 'dedicated',     name: '헌신자',           description: '총 활동 50회 달성',        icon: '🎗️', isEarned: false),
        const AppBadge(id: 'legend',        name: '전설',             description: '모든 뱃지 80% 달성',       icon: '🌠', isEarned: false),
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
        // 칭호 — 입문
        const Reward(id: 'title_beginner',    name: '건강 입문자',    type: RewardType.title, requiredPoints: 50,   isOwned: true),
        const Reward(id: 'title_explorer',    name: '가이드 탐험가',  type: RewardType.title, requiredPoints: 100,  isOwned: true),
        const Reward(id: 'title_guardian',    name: '건강 지킴이',    type: RewardType.title, requiredPoints: 150,  isOwned: false),
        const Reward(id: 'title_diligent',    name: '성실한 관리자',  type: RewardType.title, requiredPoints: 200,  isOwned: false),
        const Reward(id: 'title_med_master',  name: '복약 마스터',    type: RewardType.title, requiredPoints: 250,  isOwned: false),
        const Reward(id: 'title_lab_king',    name: '검사 기록왕',    type: RewardType.title, requiredPoints: 300,  isOwned: false),
        const Reward(id: 'title_chat_friend', name: '챗봇 친구',      type: RewardType.title, requiredPoints: 300,  isOwned: false),
        const Reward(id: 'title_early_bird',  name: '얼리버드',       type: RewardType.title, requiredPoints: 350,  isOwned: false),
        const Reward(id: 'title_streak',      name: '연속 출석왕',    type: RewardType.title, requiredPoints: 400,  isOwned: false),
        const Reward(id: 'title_all_rounder', name: '올라운더',       type: RewardType.title, requiredPoints: 450,  isOwned: false),
        // 칭호 — 중급
        const Reward(id: 'title_expert',      name: '건강 전문가',    type: RewardType.title, requiredPoints: 500,  isOwned: false),
        const Reward(id: 'title_doctor',      name: '나만의 의사',    type: RewardType.title, requiredPoints: 550,  isOwned: false),
        const Reward(id: 'title_professor',   name: '건강 교수',      type: RewardType.title, requiredPoints: 600,  isOwned: false),
        const Reward(id: 'title_mentor',      name: '건강 멘토',      type: RewardType.title, requiredPoints: 650,  isOwned: false),
        const Reward(id: 'title_champion',    name: '건강 챔피언',    type: RewardType.title, requiredPoints: 700,  isOwned: false),
        const Reward(id: 'title_warrior',     name: '건강 전사',      type: RewardType.title, requiredPoints: 750,  isOwned: false),
        const Reward(id: 'title_hero',        name: '건강 영웅',      type: RewardType.title, requiredPoints: 800,  isOwned: false),
        const Reward(id: 'title_legend',      name: '건강 레전드',    type: RewardType.title, requiredPoints: 900,  isOwned: false),
        const Reward(id: 'title_myth',        name: '건강의 신화',    type: RewardType.title, requiredPoints: 1000, isOwned: false),
        const Reward(id: 'title_king',        name: '건강의 왕',      type: RewardType.title, requiredPoints: 1200, isOwned: false),
        // 칭호 — 고급
        const Reward(id: 'title_immortal',    name: '불멸의 건강인',  type: RewardType.title, requiredPoints: 1500, isOwned: false),
        const Reward(id: 'title_god',         name: '건강의 신',      type: RewardType.title, requiredPoints: 2000, isOwned: false),
        // 테마 — 기본
        const Reward(id: 'theme_green',       name: '그린 테마',      type: RewardType.theme, requiredPoints: 300,  isOwned: false),
        const Reward(id: 'theme_blue',        name: '블루 테마',      type: RewardType.theme, requiredPoints: 300,  isOwned: false),
        const Reward(id: 'theme_orange',      name: '오렌지 테마',    type: RewardType.theme, requiredPoints: 300,  isOwned: false),
        const Reward(id: 'theme_pink',        name: '핑크 테마',      type: RewardType.theme, requiredPoints: 400,  isOwned: false),
        const Reward(id: 'theme_yellow',      name: '옐로우 테마',    type: RewardType.theme, requiredPoints: 400,  isOwned: false),
        const Reward(id: 'theme_mint',        name: '민트 테마',      type: RewardType.theme, requiredPoints: 400,  isOwned: false),
        // 테마 — 프리미엄
        const Reward(id: 'theme_purple',      name: '퍼플 테마',      type: RewardType.theme, requiredPoints: 600,  isOwned: false),
        const Reward(id: 'theme_red',         name: '레드 테마',      type: RewardType.theme, requiredPoints: 600,  isOwned: false),
        const Reward(id: 'theme_dark',        name: '다크 테마',      type: RewardType.theme, requiredPoints: 700,  isOwned: false),
        const Reward(id: 'theme_gold',        name: '골드 테마',      type: RewardType.theme, requiredPoints: 800,  isOwned: false),
        const Reward(id: 'theme_rainbow',     name: '레인보우 테마',  type: RewardType.theme, requiredPoints: 1000, isOwned: false),
        const Reward(id: 'theme_galaxy',      name: '갤럭시 테마',    type: RewardType.theme, requiredPoints: 1200, isOwned: false),
        const Reward(id: 'theme_diamond',     name: '다이아 테마',    type: RewardType.theme, requiredPoints: 1500, isOwned: false),
        const Reward(id: 'theme_platinum',    name: '플래티넘 테마',  type: RewardType.theme, requiredPoints: 2000, isOwned: false),
      ];
}
