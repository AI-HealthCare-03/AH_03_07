import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/room_models.dart';
import '../services/room_service.dart';
import '../../../widgets/helcy_widget.dart';
import '../../../features/gamification/services/gamification_service.dart';

class RoomPage extends StatefulWidget {
  final GamificationService gamificationService;
  const RoomPage({super.key, required this.gamificationService});

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> with TickerProviderStateMixin {
  final _roomService = RoomService();
  RoomState _state = RoomState();
  int _points = 0;
  bool _loading = true;

  // 헬씨 애니메이션
  late AnimationController _helcyController;
  late Animation<double> _helcyBounce; // 위아래
  late Animation<double> _helcySway;  // 좌우

  // 펫 이동
  late AnimationController _petController;
  double _petX = 0.25;
  bool _petGoingRight = true;

  @override
  void initState() {
    super.initState();

    // 헬씨 통통 + 흔들기
    _helcyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _helcyBounce = Tween<double>(begin: 0, end: -12).animate(
      CurvedAnimation(parent: _helcyController, curve: Curves.easeInOut),
    );
    _helcySway = Tween<double>(begin: -4, end: 4).animate(
      CurvedAnimation(parent: _helcyController, curve: Curves.easeInOut),
    );

    // 펫 이동
    _petController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(_movePet)..repeat();

    _load();
  }

  @override
  void dispose() {
    _helcyController.dispose();
    _petController.dispose();
    super.dispose();
  }

  void _movePet() {
    if (!mounted) return;
    setState(() {
      if (_petGoingRight) {
        _petX += 0.002;
        if (_petX > 0.72) _petGoingRight = false;
      } else {
        _petX -= 0.002;
        if (_petX < 0.08) _petGoingRight = true;
      }
    });
  }

  Future<void> _load() async {
    final state = await _roomService.load();
    final points = await widget.gamificationService.getPoints();
    if (!mounted) return;
    setState(() {
      _state = state;
      _points = points.totalPoints;
      _loading = false;
    });
  }

  Future<void> _buy(RoomItemDef def) async {
    if (_points < def.cost) {
      _snack('포인트가 부족합니다. (${def.cost}P 필요)');
      return;
    }
    final ok = await _roomService.buyItem(def.id, _points);
    if (ok) {
      final pts = await widget.gamificationService.getPoints();
      if (!mounted) return;
      setState(() {
        if (!_state.ownedItemIds.contains(def.id)) {
          _state.ownedItemIds.add(def.id);
        }
        _points = pts.totalPoints - def.cost;
      });
      _snack('${def.emoji} ${def.name} 구매 완료!');
    }
  }

  void _placeItem(String defId) {
    setState(() => _state.placedItems.add(
      PlacedItem(defId: defId, x: 0.4, y: 0.45),
    ));
    _roomService.save(_state);
  }

  void _removeItem(int index) {
    setState(() => _state.placedItems.removeAt(index));
    _roomService.save(_state);
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  bool get _hasPet => _state.placedItems.any((p) {
    final def = allRoomItems.where((d) => d.id == p.defId).firstOrNull;
    return def?.category == RoomItemCategory.pet;
  });

  String get _petEmoji {
    final pet = _state.placedItems.firstWhere(
      (p) {
        final def = allRoomItems.where((d) => d.id == p.defId).firstOrNull;
        return def?.category == RoomItemCategory.pet;
      },
      orElse: () => PlacedItem(defId: '', x: 0, y: 0),
    );
    if (pet.defId.isEmpty) return '🐶';
    return allRoomItems.firstWhere((d) => d.id == pet.defId).emoji;
  }

  int get _helcyLevel => math.min(5, 1 + _state.ownedItemIds.length ~/ 4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('내 방 꾸미기'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8C00).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('⭐ $_points P',
                    style: const TextStyle(
                        color: Color(0xFFFF8C00), fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.format_paint_outlined),
            tooltip: '벽지/바닥',
            onPressed: _showWallFloorPicker,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 안내
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: const Row(
                    children: [
                      Icon(Icons.touch_app, size: 14, color: Colors.grey),
                      SizedBox(width: 6),
                      Text('드래그 이동  •  길게 누르면 제거',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                // 방 (70%)
                Expanded(flex: 7, child: _buildRoom()),
                // 인벤토리 패널 (30%)
                _buildInventoryPanel(),
              ],
            ),
    );
  }

  // ── 방 ─────────────────────────────────────────────────
  Widget _buildRoom() {
    return LayoutBuilder(builder: (context, constraints) {
      final W = constraints.maxWidth;
      final H = constraints.maxHeight;
      final wp = roomWallpapers[_state.wallpaperIndex];
      final fl = roomFloors[_state.floorIndex];
      final floorH = H * 0.32;
      final helcySize = H * 0.28;

      return Stack(
        children: [
          // 벽
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(wp.color1), Color(wp.color2)],
                  stops: const [0.0, 0.68],
                ),
              ),
            ),
          ),
          // 바닥
          Positioned(
            left: 0, right: 0, bottom: 0, height: floorH,
            child: CustomPaint(painter: _FloorPainter(fl.color, fl.pattern)),
          ),
          // 걸레받이
          Positioned(
            left: 0, right: 0, bottom: floorH - 8, height: 12,
            child: Container(
              decoration: BoxDecoration(
                color: Color(fl.color).withValues(alpha: 0.55),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
              ),
            ),
          ),
          // 배치 아이템 (펫 제외)
          ..._state.placedItems.asMap().entries.map((entry) {
            final i = entry.key;
            final placed = entry.value;
            final def = allRoomItems.firstWhere(
              (d) => d.id == placed.defId,
              orElse: () => allRoomItems.first,
            );
            if (def.category == RoomItemCategory.pet) return const SizedBox();
            final sz = W * def.defaultSize;
            return _DraggableItem(
              key: ValueKey('item_$i'),
              emoji: def.emoji,
              size: sz,
              x: placed.x * W,
              y: placed.y * H,
              maxW: W,
              maxH: H,
              bgColor: Color(def.category.bgColor),
              borderColor: Color(def.category.borderColor),
              onMove: (nx, ny) {
                setState(() { placed.x = nx / W; placed.y = ny / H; });
                _roomService.save(_state);
              },
              onDelete: () => _confirmDelete(i, def.name),
            );
          }),
          // 헬씨 — 애니메이션 적용
          AnimatedBuilder(
            animation: _helcyController,
            builder: (_, __) => Positioned(
              left: W * 0.38 + _helcySway.value,
              bottom: floorH - 4 + _helcyBounce.value.abs(),
              child: HelcyWidget(
                level: _helcyLevel,
                mood: _hasPet ? HelcyMood.excited : HelcyMood.happy,
                size: helcySize,
              ),
            ),
          ),
          // 움직이는 펫
          if (_hasPet)
            Positioned(
              left: _petX * W,
              bottom: floorH,
              child: Transform.scale(
                scaleX: _petGoingRight ? 1 : -1,
                child: Text(_petEmoji, style: TextStyle(fontSize: H * 0.08)),
              ),
            ),
        ],
      );
    });
  }

  // ── 인벤토리 패널 ──────────────────────────────────────
  Widget _buildInventoryPanel() {
    final owned = allRoomItems.where((d) => _state.ownedItemIds.contains(d.id)).toList();
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Row(
              children: [
                const Text('🎒 인벤토리',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const Spacer(),
                TextButton.icon(
                  onPressed: _showShop,
                  icon: const Icon(Icons.store, size: 16),
                  label: const Text('상점'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFFF8C00),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: owned.isEmpty
                ? const Center(
                    child: Text('상점에서 아이템을 구매하세요!',
                        style: TextStyle(color: Colors.grey, fontSize: 13)),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: owned.length,
                    itemBuilder: (_, i) {
                      final def = owned[i];
                      return GestureDetector(
                        onTap: () {
                          _placeItem(def.id);
                          _snack('${def.emoji} ${def.name} 배치!');
                        },
                        child: Container(
                          width: 72,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: Color(def.category.bgColor),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Color(def.category.borderColor), width: 1.5),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(def.emoji, style: const TextStyle(fontSize: 28)),
                              const SizedBox(height: 4),
                              Text(def.name,
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                                  textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(int index, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('$name 제거'),
        content: const Text('방에서 제거할까요?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          TextButton(
            onPressed: () { Navigator.pop(context); _removeItem(index); },
            child: const Text('제거', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showWallFloorPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(builder: (ctx, setSheet) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('벽지', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            SizedBox(
              height: 64,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: roomWallpapers.length,
                itemBuilder: (_, i) {
                  final wp = roomWallpapers[i];
                  final sel = _state.wallpaperIndex == i;
                  return GestureDetector(
                    onTap: () { setSheet(() {}); setState(() => _state.wallpaperIndex = i); _roomService.save(_state); },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Color(wp.color1), Color(wp.color2)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: sel ? const Color(0xFFFF8C00) : Colors.transparent, width: 3),
                      ),
                      child: Center(child: Text(wp.name, style: const TextStyle(fontSize: 10), textAlign: TextAlign.center)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text('바닥', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            SizedBox(
              height: 64,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: roomFloors.length,
                itemBuilder: (_, i) {
                  final fl = roomFloors[i];
                  final sel = _state.floorIndex == i;
                  return GestureDetector(
                    onTap: () { setSheet(() {}); setState(() => _state.floorIndex = i); _roomService.save(_state); },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: 64,
                      decoration: BoxDecoration(
                        color: Color(fl.color),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: sel ? const Color(0xFFFF8C00) : Colors.transparent, width: 3),
                      ),
                      child: Center(child: Text(fl.name, style: const TextStyle(fontSize: 10), textAlign: TextAlign.center)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ]),
        );
      }),
    );
  }

  void _showShop() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        maxChildSize: 0.9,
        builder: (ctx, scroll) => _ShopSheet(
          state: _state,
          points: _points,
          onBuy: (def) async {
            await _buy(def);
            if (mounted) setState(() {});
          },
          onPlace: (id) { _placeItem(id); Navigator.pop(context); },
          scrollController: scroll,
        ),
      ),
    );
  }
}

// ── 드래그 아이템 ─────────────────────────────────────────
class _DraggableItem extends StatefulWidget {
  final String emoji;
  final double size;
  final double x;
  final double y;
  final double maxW;
  final double maxH;
  final void Function(double, double) onMove;
  final VoidCallback onDelete;
  final Color bgColor;
  final Color borderColor;

  const _DraggableItem({
    super.key,
    required this.emoji,
    required this.size,
    required this.x,
    required this.y,
    required this.maxW,
    required this.maxH,
    required this.onMove,
    required this.onDelete,
    required this.bgColor,
    required this.borderColor,
  });

  @override
  State<_DraggableItem> createState() => _DraggableItemState();
}

class _DraggableItemState extends State<_DraggableItem> {
  late double _x;
  late double _y;

  @override
  void initState() { super.initState(); _x = widget.x; _y = widget.y; }

  @override
  void didUpdateWidget(_DraggableItem old) {
    super.didUpdateWidget(old);
    _x = widget.x; _y = widget.y;
  }

  @override
  Widget build(BuildContext context) {
    final half = widget.size / 2;
    return Positioned(
      left: (_x - half).clamp(0, widget.maxW - widget.size),
      top: (_y - half).clamp(0, widget.maxH - widget.size),
      child: GestureDetector(
        onLongPress: widget.onDelete,
        onPanUpdate: (d) {
          setState(() {
            _x = (_x + d.delta.dx).clamp(half, widget.maxW - half);
            _y = (_y + d.delta.dy).clamp(half, widget.maxH - half);
          });
          widget.onMove(_x, _y);
        },
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: Center(
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.bgColor,
                shape: BoxShape.circle,
                border: Border.all(color: widget.borderColor, width: 2),
                boxShadow: [BoxShadow(color: widget.borderColor.withValues(alpha: 0.4), blurRadius: 6, offset: const Offset(0, 3))],
              ),
              child: Center(
                child: Text(widget.emoji,
                    style: TextStyle(fontSize: widget.size * 0.55)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── 상점 ─────────────────────────────────────────────────
class _ShopSheet extends StatefulWidget {
  final RoomState state;
  final int points;
  final Future<void> Function(RoomItemDef) onBuy;
  final void Function(String) onPlace;
  final ScrollController scrollController;

  const _ShopSheet({
    required this.state,
    required this.points,
    required this.onBuy,
    required this.onPlace,
    required this.scrollController,
  });

  @override
  State<_ShopSheet> createState() => _ShopSheetState();
}

class _ShopSheetState extends State<_ShopSheet> with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _cats = ['전체', '가구', '식물', '동물', '소품'];

  @override
  void initState() { super.initState(); _tab = TabController(length: _cats.length, vsync: this); }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  List<RoomItemDef> get _filtered {
    if (_tab.index == 0) return allRoomItems;
    final cats = [null, RoomItemCategory.furniture, RoomItemCategory.plant, RoomItemCategory.pet, RoomItemCategory.prop];
    return allRoomItems.where((i) => i.category == cats[_tab.index]).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(height: 8),
      Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        child: Row(children: [
          const Text('🏪 상점', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const Spacer(),
          Text('⭐ ${widget.points} P', style: const TextStyle(color: Color(0xFFFF8C00), fontWeight: FontWeight.bold)),
        ]),
      ),
      TabBar(
        controller: _tab,
        isScrollable: true,
        labelColor: const Color(0xFFFF8C00),
        unselectedLabelColor: Colors.grey,
        indicatorColor: const Color(0xFFFF8C00),
        tabs: _cats.map((c) => Tab(text: c)).toList(),
        onTap: (_) => setState(() {}),
      ),
      Expanded(
        child: AnimatedBuilder(
          animation: _tab,
          builder: (_, __) => GridView.builder(
            controller: widget.scrollController,
            padding: const EdgeInsets.all(14),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.85),
            itemCount: _filtered.length,
            itemBuilder: (_, i) {
              final def = _filtered[i];
              final owned = widget.state.ownedItemIds.contains(def.id);
              final canAfford = widget.points >= def.cost;
              return GestureDetector(
                onTap: () async {
                  if (owned) { widget.onPlace(def.id); }
                  else { await widget.onBuy(def); setState(() {}); }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: owned ? Color(def.category.bgColor) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: owned ? Color(def.category.borderColor) : Colors.grey.shade200,
                      width: owned ? 2 : 1,
                    ),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        color: Color(def.category.bgColor),
                        shape: BoxShape.circle,
                        border: Border.all(color: Color(def.category.borderColor), width: 1.5),
                      ),
                      child: Center(child: Text(def.emoji, style: const TextStyle(fontSize: 26))),
                    ),
                    const SizedBox(height: 5),
                    Text(def.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                    const SizedBox(height: 2),
                    if (owned)
                      Text('배치하기', style: TextStyle(fontSize: 11, color: Color(def.category.borderColor), fontWeight: FontWeight.bold))
                    else
                      Text('${def.cost} P',
                          style: TextStyle(fontSize: 11, color: canAfford ? const Color(0xFFFF8C00) : Colors.grey, fontWeight: FontWeight.bold)),
                  ]),
                ),
              );
            },
          ),
        ),
      ),
    ]);
  }
}

// ── 바닥 페인터 ───────────────────────────────────────────
class _FloorPainter extends CustomPainter {
  final int color;
  final String pattern;
  const _FloorPainter(this.color, this.pattern);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Color(color));
    if (pattern == 'wood') {
      final p = Paint()..color = Color(color).withValues(alpha: 0.4)..strokeWidth = 1.5;
      for (double y = 0; y < size.height; y += size.height / 4) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
      }
      final v = Paint()..color = Color(color).withValues(alpha: 0.25)..strokeWidth = 1;
      for (double x = 0; x < size.width; x += size.width / 5) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), v);
      }
    } else if (pattern == 'tile') {
      final p = Paint()..color = Colors.grey.withValues(alpha: 0.25)..strokeWidth = 1;
      final s = size.width / 6;
      for (double x = 0; x < size.width; x += s) { canvas.drawLine(Offset(x, 0), Offset(x, size.height), p); }
      for (double y = 0; y < size.height; y += s) { canvas.drawLine(Offset(0, y), Offset(size.width, y), p); }
    } else if (pattern == 'marble') {
      final p = Paint()..color = Colors.grey.withValues(alpha: 0.12)..strokeWidth = 2;
      canvas.drawLine(const Offset(0, 0), Offset(size.width, size.height), p);
      canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.8, size.height), p);
    }
  }

  @override
  bool shouldRepaint(_FloorPainter o) => o.color != color || o.pattern != pattern;
}
