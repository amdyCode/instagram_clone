import 'package:flutter/material.dart';

class StoryProgressBars extends StatelessWidget {
  const StoryProgressBars({
    super.key,
    required this.itemCount,
    required this.activeIndex,
    required this.progress,
  });

  final int itemCount;
  final int activeIndex;
  final double progress;

  @override
  Widget build(BuildContext context) {
    if (itemCount <= 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: List.generate(itemCount, (index) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: SizedBox(height: 2.5, child: _buildBar(index)),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBar(int index) {
    if (index < activeIndex) {
      return const ColoredBox(color: Colors.white);
    } else if (index == activeIndex) {
      return LinearProgressIndicator(
        value: progress.clamp(0.0, 1.0),
        backgroundColor: Colors.white.withValues(alpha: 0.35),
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
      );
    } else {
      return ColoredBox(color: Colors.white.withValues(alpha: 0.35));
    }
  }
}
