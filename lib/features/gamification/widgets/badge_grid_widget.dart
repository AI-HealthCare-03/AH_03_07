import 'package:flutter/material.dart';
import '../models/gamification_models.dart';

class BadgeGridWidget extends StatelessWidget {
  final List<AppBadge> badges;
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
  final AppBadge badge;
  const _BadgeTile({required this.badge});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('${badge.icon} ${badge.name}'),
          content: Text(
            badge.isEarned
                ? badge.description
                : '${badge.description}\n\n아직 획득하지 못했습니다.',
          ),
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
                fontWeight:
                    badge.isEarned ? FontWeight.w600 : FontWeight.normal,
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
