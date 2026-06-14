import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_config.dart';
import '../core/app_theme.dart';
import '../providers/providers.dart';
import '../widgets/lottie_feedback.dart';

class ReadScreen extends ConsumerWidget {
  const ReadScreen({super.key, required this.chapter});

  final int chapter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final book = ref.watch(selectedBookProvider);
    final key = (bookId: book.id, chapter: chapter);
    final asyncChapter = ref.watch(chapterContentProvider(key));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => ref.read(navigationProvider.notifier).goHome(),
        ),
        title: Text('${book.name} $chapter'),
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
                const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'API: ${ApiConfig.bibleBaseUrl}/api/book/{n}/chapter/{c}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(chapterContentProvider(key)),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
        data: (content) => Column(
          children: [
            if (content.reference != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  content.reference!,
                  style: const TextStyle(
                    color: AppTheme.primaryDark,
                    fontWeight: FontWeight.bold,
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
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${verse.number}. ',
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            verse.text,
                            style: const TextStyle(fontSize: 17, height: 1.45),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () =>
                        ref.read(navigationProvider.notifier).openQuiz(),
                    child: const Text(
                      'Continuar al quiz',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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
