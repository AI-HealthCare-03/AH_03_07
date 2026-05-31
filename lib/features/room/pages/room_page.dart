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
  late AnimationController _petController;
  double _petX = 0.3;
  bool _petGoingRight = true;

  @override
  void initState() {
    super.initState();
    _petController = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..addListener(_movePet)
      ..repeat();
    _load();
  }

  @override
  void dispose() {
    _petController.dispose();
    super.dispose();
  }

  void _movePet() {
    if (!mounted) return;
    setState(() {
      if (_petGoingRight) {
        _petX += 0.002;
        if (_petX > 0.75) _petGoingRight = false;
      } else {
        _petX -= 0.002;
        if (_petX < 0.1) _petGoingRight = true;
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
      // 포인트 차감
      await widget.gamificationService.purchaseReward(def.id, currentPoints: _points);
      final pts = await widget.gamificationService.getPoints();
      if (!mounted) return;
      setState(() {
        _state.ownedItemIds.add(def.id);
        _points = pts.totalPoints;
      });
      _snack('${def.emoji} ${def.name} 구매 완료!');
    }
  }

  void _placeItem(String defId) {
    final placed = PlacedItem(defId: defId, x: 0.4, y: 0.5);
    setState(() => _state.placedItems.add(placed));
    _roomService.save(_state);
  }

  void _removeItem(int index) {
    setState(() => _state.placedItems.removeAt(index));
    _roomService.save(_state);
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
  }

  bool get _hasPet => _state.placedItems.any((p) {
    final def = allRoomItems.where((d) => d.id == p.defId).firstOrNull;
    return def?.category == RoomItemCategory.pet;
  });

  String get _petEmoji {
    final pet = _state.placedItems
        .where((p) {
          final def = allRoomItems.where((d) => d.id == p.defId).firstOrNull;
          return def?.category == RoomItemCategory.pet;
        })
        .firstOrNull;
    if (pet == null) return '🐶';
    return allRoomItems.firstWhere((d) => d.id == pet.defId).emoji;
  }

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
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8C00).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('⭐ $_points P',
                    style: const TextStyle(
                        color: Color(0xFFFF8C00), fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.store_outlined),
            onPressed: _showShop,
            tooltip: '상점',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 조작 안내
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.touch_app, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      const Text('아이템을 드래그해 위치 조정 • 길게 누르면 삭제',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: _showWallFloorPicker,
                        icon: const Icon(Icons.format_paint, size: 16),
                        label: const Text('벽지/바닥'),
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            foregroundColor: const Color(0xFFFF8C00)),
                      ),
                    ],
                  ),
                ),
                // 방
                Expanded(child: _buildRoom()),
              ],
            ),
    );
  }

  Widget _buildRoom() {
    return LayoutBuilder(builder: (context, constraints) {
      final W = constraints.maxWidth;
      final H = constraints.maxHeight;
      final wp = roomWallpapers[_state.wallpaperIndex];
      final fl = roomFloors[_state.floorIndex];
      final floorH = H * 0.3;

      return Stack(
        children: [
          // ── 벽 배경 ──
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(wp.color1), Color(wp.color2)],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
          ),
          // ── 바닥 ──
          Positioned(
            left: 0, right: 0, bottom: 0,
            height: floorH,
            child: CustomPaint(painter: _FloorPainter(fl.color, fl.pattern)),
          ),
          // ── 걸레받이 ──
          Positioned(
            left: 0, right: 0,
            bottom: floorH - 8,
            height: 14,
            child: Container(
              decoration: BoxDecoration(
                color: Color(fl.color).withValues(alpha: 0.6),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ),
          ),
          // ── 배치된 아이템 ──
          ..._state.placedItems.asMap().entries.map((entry) {
            final i = entry.key;
            final placed = entry.value;
            final def = allRoomItems.firstWhere(
              (d) => d.id == placed.defId,
              orElse: () => allRoomItems.first,
            );
            if (def.category == RoomItemCategory.pet) return const SizedBox();
            final itemSize = W * def.defaultSize;
            return _DraggableItem(
              key: ValueKey('item_$i'),
              emoji: def.emoji,
              size: itemSize,
              x: placed.x * W,
              y: placed.y * H,
              maxW: W,
              maxH: H,
              onMove: (nx, ny) {
                setState(() {
                  placed.x = nx / W;
                  placed.y = ny / H;
                });
                _roomService.save(_state);
              },
              onDelete: () => _showDeleteConfirm(i, def.name),
            );
          }),
          // ── 헬씨 (항상 방 안에) ──
          Positioned(
            left: W * 0.35,
            bottom: floorH - 5,
            child: HelcyWidget(
              level: math.min(5, 1 + _state.ownedItemIds.length ~/ 5),
              mood: _hasPet ? HelcyMood.excited : HelcyMood.happy,
              size: H * 0.22,
            ),
          ),
          // ── 움직이는 펫 ──
          if (_hasPet)
            Positioned(
              left: _petX * W,
              bottom: floorH,
              child: Transform.scale(
                scaleX: _petGoingRight ? 1 : -1,
                child: Text(_petEmoji, style: TextStyle(fontSize: H * 0.07)),
              ),
            ),
          // ── 상점 FAB ──
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.extended(
              onPressed: _showShop,
              backgroundColor: const Color(0xFFFF8C00),
              icon: const Icon(Icons.store, color: Colors.white),
              label: const Text('상점', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      );
    });
  }

  void _showDeleteConfirm(int index, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('$name 제거'),
        content: const Text('이 아이템을 방에서 제거할까요?'),
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
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: roomWallpapers.length,
                itemBuilder: (_, i) {
                  final wp = roomWallpapers[i];
                  final sel = _state.wallpaperIndex == i;
                  return GestureDetector(
                    onTap: () {
                      setSheet(() {});
                      setState(() => _state.wallpaperIndex = i);
                      _roomService.save(_state);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(wp.color1), Color(wp.color2)],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: sel ? const Color(0xFFFF8C00) : Colors.transparent,
                            width: 3),
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
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: roomFloors.length,
                itemBuilder: (_, i) {
                  final fl = roomFloors[i];
                  final sel = _state.floorIndex == i;
                  return GestureDetector(
                    onTap: () {
                      setSheet(() {});
                      setState(() => _state.floorIndex = i);
                      _roomService.save(_state);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: 60,
                      decoration: BoxDecoration(
                        color: Color(fl.color),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: sel ? const Color(0xFFFF8C00) : Colors.transparent,
                            width: 3),
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
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (ctx, scroll) => _ShopSheet(
          state: _state,
          points: _points,
          onBuy: _buy,
          onPlace: _placeItem,
          scrollController: scroll,
        ),
      ),
    );
  }
}

// ── 드래그 가능한 아이템 ───────────────────────────────────
class _DraggableItem extends StatefulWidget {
  final String emoji;
  final double size;
  final double x;
  final double y;
  final double maxW;
  final double maxH;
  final void Function(double nx, double ny) onMove;
  final VoidCallback onDelete;

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
  });

  @override
  State<_DraggableItem> createState() => _DraggableItemState();
}

class _DraggableItemState extends State<_DraggableItem> {
  late double _x;
  late double _y;

  @override
  void initState() {
    super.initState();
    _x = widget.x;
    _y = widget.y;
  }

  @override
  void didUpdateWidget(_DraggableItem old) {
    super.didUpdateWidget(old);
    _x = widget.x;
    _y = widget.y;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: (_x - widget.size / 2).clamp(0, widget.maxW - widget.size),
      top: (_y - widget.size / 2).clamp(0, widget.maxH - widget.size),
      child: GestureDetector(
        onLongPress: widget.onDelete,
        onPanUpdate: (d) {
          setState(() {
            _x = (_x + d.delta.dx).clamp(widget.size / 2, widget.maxW - widget.size / 2);
            _y = (_y + d.delta.dy).clamp(widget.size / 2, widget.maxH - widget.size / 2);
          });
          widget.onMove(_x, _y);
        },
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: Center(
            child: Text(widget.emoji,
                style: TextStyle(fontSize: widget.size * 0.75)),
          ),
        ),
      ),
    );
  }
}

// ── 상점 시트 ─────────────────────────────────────────────
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

class _ShopSheetState extends State<_ShopSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _categories = ['전체', '가구', '식물', '동물', '소품'];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  List<RoomItemDef> _filtered(int tabIndex) {
    if (tabIndex == 0) return allRoomItems;
    final cat = [null, RoomItemCategory.furniture, RoomItemCategory.plant,
        RoomItemCategory.pet, RoomItemCategory.prop][tabIndex];
    return allRoomItems.where((i) => i.category == cat).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(height: 8),
      Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
        tabs: _categories.map((c) => Tab(text: c)).toList(),
        onTap: (_) => setState(() {}),
      ),
      Expanded(
        child: AnimatedBuilder(
          animation: _tab,
          builder: (_, __) {
            final items = _filtered(_tab.index);
            return GridView.builder(
              controller: widget.scrollController,
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.85),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final def = items[i];
                final owned = widget.state.ownedItemIds.contains(def.id);
                final canAfford = widget.points >= def.cost;
                return GestureDetector(
                  onTap: () async {
                    if (owned) {
                      widget.onPlace(def.id);
                      Navigator.pop(context);
                    } else {
                      await widget.onBuy(def);
                      setState(() {});
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: owned ? Colors.green.shade50 : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: owned ? Colors.green.shade200 : Colors.grey.shade200),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(def.emoji, style: const TextStyle(fontSize: 32)),
                      const SizedBox(height: 6),
                      Text(def.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      if (owned)
                        const Text('배치하기', style: TextStyle(fontSize: 11, color: Colors.green))
                      else
                        Text(
                          '${def.cost} P',
                          style: TextStyle(
                              fontSize: 11,
                              color: canAfford ? const Color(0xFFFF8C00) : Colors.grey,
                              fontWeight: FontWeight.bold),
                        ),
                    ]),
                  ),
                );
              },
            );
          },
        ),
      ),
    ]);
  }
}

// ── 바닥 그리기 ───────────────────────────────────────────
class _FloorPainter extends CustomPainter {
  final int color;
  final String pattern;

  const _FloorPainter(this.color, this.pattern);

  @override
  void paint(Canvas canvas, Size size) {
    final base = Paint()..color = Color(color);
    canvas.drawRect(Offset.zero & size, base);

    if (pattern == 'wood') {
      final line = Paint()
        ..color = Color(color).withValues(alpha: 0.5)
        ..strokeWidth = 1.5;
      for (double y = 0; y < size.height; y += size.height / 5) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
      }
      final vline = Paint()
        ..color = Color(color).withValues(alpha: 0.3)
        ..strokeWidth = 1;
      for (double x = 0; x < size.width; x += size.width / 6) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), vline);
      }
    } else if (pattern == 'tile') {
      final line = Paint()
        ..color = Colors.grey.withValues(alpha: 0.3)
        ..strokeWidth = 1;
      final step = size.width / 6;
      for (double x = 0; x < size.width; x += step) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), line);
      }
      for (double y = 0; y < size.height; y += step) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
      }
    } else if (pattern == 'marble') {
      final vein = Paint()
        ..color = Colors.grey.withValues(alpha: 0.15)
        ..strokeWidth = 2;
      canvas.drawLine(const Offset(0, 0), Offset(size.width, size.height), vein);
      canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.8, size.height), vein);
    }
  }

  @override
  bool shouldRepaint(_FloorPainter old) => old.color != color || old.pattern != pattern;
}
