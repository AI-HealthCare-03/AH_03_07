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
  List<AppBadge> _badges = [];
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
      _badges = results[0] as List<AppBadge>;
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
