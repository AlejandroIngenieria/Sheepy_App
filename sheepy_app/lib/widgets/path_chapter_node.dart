import 'package:flutter/material.dart';

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

    return Align(
      alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.only(
          left: isLeft ? 40 : 0,
          right: isLeft ? 0 : 40,
          bottom: 20,
        ),
        child: GestureDetector(
          onTap: isUnlocked ? onTap : null,
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isUnlocked
                      ? (isCompleted ? AppTheme.primaryDark : AppTheme.primary)
                      : (isDark ? Colors.grey[800] : Colors.grey[300]),
                  border: Border.all(
                    color: isUnlocked ? AppTheme.primaryDark : Colors.grey,
                    width: 4,
                  ),
                  boxShadow: isUnlocked
                      ? [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 30)
                      : isUnlocked
                          ? Text(
                              '$chapter',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : const Icon(Icons.lock, color: Colors.grey, size: 24),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Cap. $chapter',
                style: TextStyle(
                  color: isUnlocked ? AppTheme.primaryDark : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
