import 'dart:convert';

enum RoomItemCategory { furniture, plant, pet, prop }

extension RoomItemCategoryColor on RoomItemCategory {
  // 배경색
  int get bgColor => switch (this) {
    RoomItemCategory.furniture => 0xFFFFE0B2, // 주황
    RoomItemCategory.plant     => 0xFFC8E6C9, // 초록
    RoomItemCategory.pet       => 0xFFF8BBD0, // 핑크
    RoomItemCategory.prop      => 0xFFBBDEFB, // 파랑
  };
  // 테두리색
  int get borderColor => switch (this) {
    RoomItemCategory.furniture => 0xFFFF8C00,
    RoomItemCategory.plant     => 0xFF43A047,
    RoomItemCategory.pet       => 0xFFE91E63,
    RoomItemCategory.prop      => 0xFF1976D2,
  };
}

class RoomItemDef {
  final String id;
  final String emoji;
  final String name;
  final int cost;
  final RoomItemCategory category;
  final double defaultSize; // 방 너비 대비 비율

  const RoomItemDef({
    required this.id,
    required this.emoji,
    required this.name,
    required this.cost,
    required this.category,
    this.defaultSize = 0.13,
  });
}

class PlacedItem {
  final String defId;
  double x; // 방 너비 대비 0.0~1.0
  double y; // 방 높이 대비 0.0~1.0

  PlacedItem({required this.defId, required this.x, required this.y});

  Map<String, dynamic> toJson() => {'defId': defId, 'x': x, 'y': y};
  factory PlacedItem.fromJson(Map<String, dynamic> j) =>
      PlacedItem(defId: j['defId'], x: j['x'], y: j['y']);
}

class RoomState {
  int wallpaperIndex;
  int floorIndex;
  List<String> ownedItemIds;
  List<PlacedItem> placedItems;

  RoomState({
    this.wallpaperIndex = 0,
    this.floorIndex = 0,
    List<String>? ownedItemIds,
    List<PlacedItem>? placedItems,
  })  : ownedItemIds = ownedItemIds ?? [],
        placedItems = placedItems ?? [];

  Map<String, dynamic> toJson() => {
        'wallpaperIndex': wallpaperIndex,
        'floorIndex': floorIndex,
        'ownedItemIds': ownedItemIds,
        'placedItems': placedItems.map((e) => e.toJson()).toList(),
      };

  factory RoomState.fromJson(Map<String, dynamic> j) => RoomState(
        wallpaperIndex: j['wallpaperIndex'] ?? 0,
        floorIndex: j['floorIndex'] ?? 0,
        ownedItemIds: List<String>.from(j['ownedItemIds'] ?? []),
        placedItems: (j['placedItems'] as List? ?? [])
            .map((e) => PlacedItem.fromJson(e))
            .toList(),
      );

  String toJsonString() => jsonEncode(toJson());
  factory RoomState.fromJsonString(String s) =>
      RoomState.fromJson(jsonDecode(s));
}

// ── 벽지 ──────────────────────────────────────────────────
const roomWallpapers = [
  (name: '베이지', color1: 0xFFFFF8F0, color2: 0xFFFFEDD8),
  (name: '민트', color1: 0xFFE0F7FA, color2: 0xFFB2EBF2),
  (name: '라벤더', color1: 0xFFEDE7F6, color2: 0xFFD1C4E9),
  (name: '피치', color1: 0xFFFCE4EC, color2: 0xFFF8BBD0),
  (name: '스카이블루', color1: 0xFFE3F2FD, color2: 0xFFBBDEFB),
  (name: '연두', color1: 0xFFF1F8E9, color2: 0xFFDCEDC8),
  (name: '화이트', color1: 0xFFFFFFFF, color2: 0xFFF5F5F5),
  (name: '그레이', color1: 0xFFEEEEEE, color2: 0xFFE0E0E0),
];

// ── 바닥 ──────────────────────────────────────────────────
const roomFloors = [
  (name: '원목', color: 0xFFD7A46F, pattern: 'wood'),
  (name: '밝은 원목', color: 0xFFEBC98A, pattern: 'wood'),
  (name: '흰 타일', color: 0xFFF5F5F5, pattern: 'tile'),
  (name: '대리석', color: 0xFFECEFF1, pattern: 'marble'),
  (name: '베이지 카펫', color: 0xFFD7CCC8, pattern: 'carpet'),
];

// ── 아이템 목록 ────────────────────────────────────────────
const allRoomItems = [
  // 가구
  RoomItemDef(id: 'bed',      emoji: '🛏️', name: '침대',    cost: 100, category: RoomItemCategory.furniture, defaultSize: 0.22),
  RoomItemDef(id: 'sofa',     emoji: '🛋️', name: '소파',    cost: 80,  category: RoomItemCategory.furniture, defaultSize: 0.20),
  RoomItemDef(id: 'desk',     emoji: '🖥️', name: '책상',    cost: 70,  category: RoomItemCategory.furniture, defaultSize: 0.16),
  RoomItemDef(id: 'chair',    emoji: '🪑', name: '의자',    cost: 40,  category: RoomItemCategory.furniture, defaultSize: 0.11),
  RoomItemDef(id: 'bookshelf',emoji: '📚', name: '책장',    cost: 60,  category: RoomItemCategory.furniture, defaultSize: 0.14),
  RoomItemDef(id: 'tv',       emoji: '📺', name: 'TV',      cost: 90,  category: RoomItemCategory.furniture, defaultSize: 0.16),
  RoomItemDef(id: 'fridge',   emoji: '🧊', name: '냉장고',  cost: 80,  category: RoomItemCategory.furniture, defaultSize: 0.13),
  RoomItemDef(id: 'table',    emoji: '🪞', name: '탁자',    cost: 50,  category: RoomItemCategory.furniture, defaultSize: 0.14),
  RoomItemDef(id: 'dresser',  emoji: '🪟', name: '서랍장',  cost: 60,  category: RoomItemCategory.furniture, defaultSize: 0.13),
  RoomItemDef(id: 'piano',    emoji: '🎹', name: '피아노',  cost: 150, category: RoomItemCategory.furniture, defaultSize: 0.18),
  RoomItemDef(id: 'bathtub',  emoji: '🛁', name: '욕조',    cost: 120, category: RoomItemCategory.furniture, defaultSize: 0.18),
  RoomItemDef(id: 'lamp',     emoji: '🪔', name: '스탠드',  cost: 30,  category: RoomItemCategory.furniture, defaultSize: 0.09),
  RoomItemDef(id: 'clock',    emoji: '🕰️', name: '시계',    cost: 40,  category: RoomItemCategory.furniture, defaultSize: 0.10),
  RoomItemDef(id: 'mirror',   emoji: '🪞', name: '거울',    cost: 50,  category: RoomItemCategory.furniture, defaultSize: 0.12),
  RoomItemDef(id: 'closet',   emoji: '🗄️', name: '옷장',    cost: 90,  category: RoomItemCategory.furniture, defaultSize: 0.15),
  // 식물
  RoomItemDef(id: 'plant1',   emoji: '🪴', name: '화분',    cost: 30,  category: RoomItemCategory.plant, defaultSize: 0.10),
  RoomItemDef(id: 'cactus',   emoji: '🌵', name: '선인장',  cost: 25,  category: RoomItemCategory.plant, defaultSize: 0.09),
  RoomItemDef(id: 'tree',     emoji: '🌳', name: '나무',    cost: 60,  category: RoomItemCategory.plant, defaultSize: 0.15),
  RoomItemDef(id: 'flower',   emoji: '🌸', name: '꽃',      cost: 20,  category: RoomItemCategory.plant, defaultSize: 0.09),
  // 동물
  RoomItemDef(id: 'dog',      emoji: '🐶', name: '강아지',  cost: 200, category: RoomItemCategory.pet, defaultSize: 0.12),
  RoomItemDef(id: 'cat',      emoji: '🐱', name: '고양이',  cost: 200, category: RoomItemCategory.pet, defaultSize: 0.12),
  RoomItemDef(id: 'hamster',  emoji: '🐹', name: '햄스터',  cost: 150, category: RoomItemCategory.pet, defaultSize: 0.09),
  RoomItemDef(id: 'rabbit',   emoji: '🐰', name: '토끼',    cost: 150, category: RoomItemCategory.pet, defaultSize: 0.10),
  // 소품
  RoomItemDef(id: 'picture',  emoji: '🖼️', name: '액자',    cost: 30,  category: RoomItemCategory.prop, defaultSize: 0.10),
  RoomItemDef(id: 'cushion',  emoji: '🧸', name: '쿠션',    cost: 20,  category: RoomItemCategory.prop, defaultSize: 0.09),
  RoomItemDef(id: 'fishtank', emoji: '🐠', name: '어항',    cost: 80,  category: RoomItemCategory.prop, defaultSize: 0.13),
  RoomItemDef(id: 'trophy',   emoji: '🏆', name: '트로피',  cost: 100, category: RoomItemCategory.prop, defaultSize: 0.10),
  RoomItemDef(id: 'gamepad',  emoji: '🎮', name: '게임기',  cost: 60,  category: RoomItemCategory.prop, defaultSize: 0.10),
  RoomItemDef(id: 'guitar',   emoji: '🎸', name: '기타',    cost: 80,  category: RoomItemCategory.prop, defaultSize: 0.13),
  RoomItemDef(id: 'carpet',   emoji: '🟫', name: '러그',    cost: 40,  category: RoomItemCategory.prop, defaultSize: 0.20),
];
