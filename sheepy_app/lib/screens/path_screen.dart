import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/app_theme.dart';
import '../providers/providers.dart';
import '../widgets/animated_sheepy.dart';
import '../widgets/lives_widget.dart';
import '../widgets/path_chapter_node.dart';

class PathScreen extends ConsumerWidget {
  const PathScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final book = ref.watch(selectedBookProvider);
    final progress = ref.watch(userProgressProvider);
    final nav = ref.read(navigationProvider.notifier);
    final userStatsAsync = ref.watch(userStatsProvider);

    final completed = progress.completedFor(book.id);
    final bookProgress = progress.bookProgress(book.id, book.chapters);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        if (userStatsAsync.hasError)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Error cargando perfil: ${userStatsAsync.error}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          )
        else if (userStatsAsync.hasValue && userStatsAsync.value != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Center(
              child: LivesWidget(
                userStats: userStatsAsync.value!,
                onZeroLives: () {
                  ref.invalidate(userStatsProvider);
                },
              ),
            ),
          ),
        // Hero section with sheep
        Center(
          child: Column(
            children: [
              AnimatedSheepy(
                progress: bookProgress,
                woolColor: book.woolColor,
              ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack).fadeIn(),
              const SizedBox(height: 12),
              Text(
                book.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primaryDark,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '${completed.length} de ${book.chapters} capítulos',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              // Progress bar
              Container(
                height: 12,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: AppTheme.primaryLight.withValues(alpha: 0.15),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: bookProgress.clamp(0.0, 1.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Change book button
        FilledButton.tonal(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () => ref.read(navigationProvider.notifier).setTab(1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_stories_rounded, size: 20),
              const SizedBox(width: 8),
              Text(
                'Cambiar libro',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Chapter nodes
        ...List.generate(book.chapters, (index) {
          final chapter = index + 1;
          final isCompleted = progress.isChapterCompleted(book.id, chapter);
          final isUnlocked = progress.isChapterUnlocked(book.id, chapter);
          return PathChapterNode(
            chapter: chapter,
            isCompleted: isCompleted,
            isUnlocked: isUnlocked,
            isLeft: index.isEven,
            onTap: () {
              if (isCompleted) {
                nav.openChapter(chapter);
                return;
              }

              final stats = userStatsAsync.valueOrNull;
              if (stats == null) return;

              if (stats.currentLives <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('💔 No tienes vidas. Espera a que se recarguen.'),
                    backgroundColor: AppTheme.accent,
                  ),
                );
                return;
              }
              
              nav.openChapter(chapter);
            },
          ).animate(delay: (index * 60).ms)
              .slideY(begin: 0.15, duration: 350.ms, curve: Curves.easeOutQuad)
              .fadeIn();
        }),
      ],
    );
  }
}
