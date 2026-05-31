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
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('구매'),
          ),
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${reward.name} 획득! -${reward.requiredPoints}P')),
        );
      }
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
          const _SectionHeader(title: '칭호', icon: '🏷️'),
          const SizedBox(height: 8),
          ...titles.map((r) => _RewardTile(
                reward: r,
                currentPoints: widget.currentPoints,
                onBuy: () => _purchase(r),
              )),
          const SizedBox(height: 20),
          const _SectionHeader(title: '테마', icon: '🎨'),
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

  const _RewardTile({
    required this.reward,
    required this.currentPoints,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final canAfford = reward.canAfford(currentPoints);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(reward.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${reward.requiredPoints}P 필요'),
        trailing: reward.isOwned
            ? const Chip(
                label: Text('보유중'),
                backgroundColor: Color(0xFFE8F8F0),
              )
            : ElevatedButton(
                onPressed: canAfford ? onBuy : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('교환'),
              ),
      ),
    );
  }
}
