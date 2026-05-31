import 'package:flutter/material.dart';
import 'helcy_widget.dart';

// 게임 화면 모서리에 표시되는 응원 헬씨
class HelcyCheerWidget extends StatelessWidget {
  final HelcyMood mood;
  final String message;
  final int level;

  const HelcyCheerWidget({
    super.key,
    required this.mood,
    required this.message,
    this.level = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        HelcyWidget(level: level, mood: mood, size: 70),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 6,
              ),
            ],
          ),
          child: Text(
            message,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
