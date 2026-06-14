import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_theme.dart';
import '../providers/providers.dart';
import '../widgets/animated_sheepy.dart';
import '../widgets/path_chapter_node.dart';

class PathScreen extends ConsumerWidget {
  const PathScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final book = ref.watch(selectedBookProvider);
    final progress = ref.watch(userProgressProvider);
    final nav = ref.read(navigationProvider.notifier);

    final completed = progress.completedFor(book.id);
    final bookProgress = progress.bookProgress(book.id, book.chapters);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        Center(
          child: Column(
            children: [
              AnimatedSheepy(
                progress: bookProgress,
                woolColor: book.woolColor,
              ),
              const SizedBox(height: 8),
              Text(
                book.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryDark,
                    ),
              ),
              Text(
                '${completed.length} de ${book.chapters} capítulos',
                style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: bookProgress.clamp(0, 1),
                  minHeight: 8,
                  backgroundColor: Colors.grey.withValues(alpha: 0.2),
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).cardColor,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: () => ref.read(navigationProvider.notifier).setTab(1),
          icon: const Icon(Icons.menu_book, color: AppTheme.primary),
          label: Text('Cambiar libro · ${book.name}'),
        ),
        const SizedBox(height: 28),
        ...List.generate(book.chapters, (index) {
          final chapter = index + 1;
          final isCompleted = progress.isChapterCompleted(book.id, chapter);
          final isUnlocked = progress.isChapterUnlocked(book.id, chapter);
          return PathChapterNode(
            chapter: chapter,
            isCompleted: isCompleted,
            isUnlocked: isUnlocked,
            isLeft: index.isEven,
            onTap: () => nav.openChapter(chapter),
          );
        }),
      ],
    );
  }
}
