import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../theme/app_colors.dart';

class StoryBottomBar extends StatelessWidget {
  const StoryBottomBar({
    super.key,
    required this.isLiked,
    required this.onLikeToggle,
    this.onShareTap,
    this.onSendTap,
  });

  final bool isLiked;
  final VoidCallback onLikeToggle;
  final VoidCallback? onShareTap;
  final ValueChanged<String>? onSendTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              alignment: Alignment.centerLeft,
              child: Text(
                'Envoyer un message...',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          IconButton(
            tooltip: isLiked ? 'Je n’aime plus' : 'J’aime',
            onPressed: onLikeToggle,
            icon: AnimatedScale(
              scale: isLiked ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? AppColors.like : Colors.white,
                size: 28,
              ),
            ),
          ),

          IconButton(
            tooltip: 'Partager cette story',
            onPressed: onShareTap ?? () {},
            icon: const FaIcon(
              FontAwesomeIcons.paperPlane,
              color: Colors.white,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}
