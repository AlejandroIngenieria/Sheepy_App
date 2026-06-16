import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/app_theme.dart';

class PathChapterNode extends StatelessWidget {
  const PathChapterNode({
    super.key,
    required this.chapter,
    required this.isCompleted,
    required this.isUnlocked,
    required this.isLeft,
    required this.onTap,
  });

  final int chapter;
  final bool isCompleted;
  final bool isUnlocked;
  final bool isLeft;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine colors based on state
    final Color bgColor;
    final Color borderColor;
    final Color iconColor;
    final List<BoxShadow>? shadows;

    if (isCompleted) {
      bgColor = AppTheme.success;
      borderColor = AppTheme.success;
      iconColor = Colors.white;
      shadows = [
        BoxShadow(
          color: AppTheme.success.withValues(alpha: 0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
    } else if (isUnlocked) {
      bgColor = AppTheme.primary;
      borderColor = AppTheme.primaryLight;
      iconColor = Colors.white;
      shadows = [
        BoxShadow(
          color: AppTheme.primary.withValues(alpha: 0.35),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];
    } else {
      bgColor = isDark ? const Color(0xFF2D2248) : const Color(0xFFE8E0F0);
      borderColor = isDark ? const Color(0xFF3D3058) : const Color(0xFFD0C4E0);
      iconColor = isDark ? Colors.grey.shade600 : Colors.grey.shade400;
      shadows = null;
    }

    Widget node = GestureDetector(
      onTap: isUnlocked ? onTap : null,
      child: Column(
        children: [
          // Connector line
          if (chapter > 1)
            Container(
              width: 3,
              height: 24,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    (isUnlocked ? AppTheme.primaryLight : borderColor).withValues(alpha: 0.4),
                    isUnlocked ? AppTheme.primaryLight : borderColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          // The node itself
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bgColor,
              border: Border.all(color: borderColor, width: 3),
              boxShadow: shadows,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 32)
                  : isUnlocked
                      ? Text(
                          '$chapter',
                          style: TextStyle(
                            color: iconColor,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        )
                      : Icon(Icons.lock_rounded, color: iconColor, size: 22),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Cap. $chapter',
            style: TextStyle(
              color: isUnlocked
                  ? (isDark ? AppTheme.primaryLight : AppTheme.primaryDark)
                  : Colors.grey,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );

    // Add glow pulse for the NEXT unlocked chapter
    if (isUnlocked && !isCompleted) {
      node = node
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.06, 1.06),
            duration: 1200.ms,
            curve: Curves.easeInOut,
          );
    }

    return Align(
      alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.only(
          left: isLeft ? 48 : 0,
          right: isLeft ? 0 : 48,
          bottom: 8,
        ),
        child: node,
      ),
    );
  }
}
