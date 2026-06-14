import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_theme.dart';
import '../models/quiz_question.dart';
import '../providers/providers.dart';
import '../widgets/lottie_feedback.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key, required this.chapter});

  final int chapter;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int _questionIndex = 0;
  int _correctCount = 0;
  List<QuizQuestion>? _questions;
  bool? _lastAnswerCorrect;

  @override
  Widget build(BuildContext context) {
    final book = ref.watch(selectedBookProvider);
    final key = (bookId: book.id, chapter: widget.chapter);
    final asyncChapter = ref.watch(chapterContentProvider(key));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => ref.read(navigationProvider.notifier).goHome(),
        ),
        title: Text('Quiz · ${book.name} ${widget.chapter}'),
      ),
      body: asyncChapter.when(
        loading: () => const LottieLoading(message: 'Preparando el quiz...'),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (content) {
          if (_questions == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted || _questions != null) return;
              setState(() {
                _questions = ref
                    .read(quizServiceProvider)
                    .generateFromChapter(content.verses);
              });
            });
            return const Center(child: CircularProgressIndicator());
          }

          if (_questions!.isEmpty) {
            return const Center(child: Text('No hay preguntas para este capítulo'));
          }

          if (_questionIndex >= _questions!.length) {
            return _buildResult(context, book.id);
          }

          final q = _questions![_questionIndex];
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LinearProgressIndicator(
                  value: (_questionIndex + 1) / _questions!.length,
                  color: AppTheme.primary,
                  backgroundColor: Colors.grey.withValues(alpha: 0.2),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pregunta ${_questionIndex + 1} de ${_questions!.length}',
                  style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),
                Text(
                  q.prompt,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: ListView(
                    children: [
                      for (var i = 0; i < q.options.length; i++)
                        _OptionButton(
                          text: q.options[i],
                          feedback: _lastAnswerCorrect,
                          onTap: _lastAnswerCorrect != null
                              ? null
                              : () => _answer(i == q.correctIndex),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _answer(bool correct) {
    setState(() {
      _lastAnswerCorrect = correct;
      if (correct) _correctCount++;
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() {
        _lastAnswerCorrect = null;
        _questionIndex++;
      });
    });
  }

  Widget _buildResult(BuildContext context, String bookId) {
    final passed = _correctCount >= (_questions!.length / 2).ceil();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (passed)
            const LottieCelebration()
          else
            const Icon(Icons.sentiment_dissatisfied, size: 72, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            passed ? '¡Capítulo completado!' : 'Sigue practicando',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '$_correctCount de ${_questions!.length} correctas',
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          if (passed)
            ElevatedButton(
              onPressed: () async {
                await ref
                    .read(userProgressProvider.notifier)
                    .completeChapter(bookId, widget.chapter);
                ref.read(navigationProvider.notifier).goHome();
              },
              child: const Text('Desbloquear siguiente capítulo'),
            )
          else
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _questionIndex = 0;
                  _correctCount = 0;
                  _questions = null;
                  _lastAnswerCorrect = null;
                });
              },
              child: const Text('Reintentar quiz'),
            ),
          TextButton(
            onPressed: () => ref.read(navigationProvider.notifier).goHome(),
            child: const Text('Volver al camino'),
          ),
        ],
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.text,
    required this.onTap,
    this.feedback,
  });

  final String text;
  final VoidCallback? onTap;
  final bool? feedback;

  @override
  Widget build(BuildContext context) {
    Color? bg;
    if (feedback == true) bg = Colors.green.withValues(alpha: 0.2);
    if (feedback == false) bg = Colors.red.withValues(alpha: 0.15);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: bg ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
