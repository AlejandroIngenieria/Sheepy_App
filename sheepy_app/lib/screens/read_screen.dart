import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/app_theme.dart';
import '../providers/providers.dart';
import '../widgets/lives_widget.dart';
import '../widgets/lottie_feedback.dart';

class ReadScreen extends ConsumerWidget {
  const ReadScreen({super.key, required this.chapter});

  final int chapter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final book = ref.watch(selectedBookProvider);
    final key = (bookId: book.id, chapter: chapter);
    final asyncChapter = ref.watch(chapterContentProvider(key));
    final userStatsAsync = ref.watch(userStatsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => ref.read(navigationProvider.notifier).goHome(),
        ),
        title: Text('${book.name} $chapter'),
        actions: [
          if (userStatsAsync.hasValue && userStatsAsync.value != null)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: LivesWidget(userStats: userStatsAsync.value!),
              ),
            ),
        ],
      ),
      body: asyncChapter.when(
        loading: () => const LottieLoading(
          message: 'Cargando capítulo (RV1909)...',
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text(e.toString(), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(chapterContentProvider(key)),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
        data: (content) => Column(
          children: [
            if (content.reference != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  content.reference!,
                  style: const TextStyle(
                    color: AppTheme.primaryDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                itemCount: content.verses.length,
                itemBuilder: (_, i) {
                  final verse = content.verses[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${verse.number}',
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            verse.text,
                            style: const TextStyle(fontSize: 17, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Bottom CTA
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        ref.read(navigationProvider.notifier).openQuiz(),
                    icon: const Icon(Icons.quiz_rounded),
                    label: const Text(
                      'Continuar al quiz',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
