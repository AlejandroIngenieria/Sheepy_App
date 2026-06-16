import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_animate/flutter_animate.dart';

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
          icon: const Icon(Icons.close_rounded),
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
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (_questionIndex + 1) / _questions!.length,
                    minHeight: 10,
                    color: AppTheme.primary,
                    backgroundColor: AppTheme.primaryLight.withValues(alpha: 0.15),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pregunta ${_questionIndex + 1} de ${_questions!.length}',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
                // Question
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    q.prompt,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
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
      if (correct) {
        _correctCount++;
      } else {
        ref.read(gamificationServiceProvider).loseLife();
        ref.invalidate(userStatsProvider);
      }
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
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.sentiment_dissatisfied_rounded,
                size: 48,
                color: AppTheme.accent,
              ),
            ),
          const SizedBox(height: 20),
          Text(
            passed ? '🎉 ¡Capítulo completado!' : '😔 Sigue practicando',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '$_correctCount de ${_questions!.length} correctas',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 32),
          if (passed)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final book = ref.read(selectedBookProvider);
                  await ref.read(gamificationServiceProvider).saveProgress(
                    book.bookNumber,
                    widget.chapter
                  );
                  ref.invalidate(userStatsProvider);
                  
                  await ref
                      .read(userProgressProvider.notifier)
                      .completeChapter(bookId, widget.chapter);
                  ref.read(navigationProvider.notifier).goHome();
                },
                icon: const Icon(Icons.lock_open_rounded),
                label: const Text('Desbloquear siguiente capítulo'),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _questionIndex = 0;
                    _correctCount = 0;
                    _questions = null;
                    _lastAnswerCorrect = null;
                  });
                },
                icon: const Icon(Icons.replay_rounded),
                label: const Text('Reintentar quiz'),
              ),
            ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => ref.read(navigationProvider.notifier).goHome(),
            child: const Text(
              'Volver al camino',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
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
    Color borderColor = Colors.transparent;
    if (feedback == true) {
      bg = AppTheme.success.withValues(alpha: 0.12);
      borderColor = AppTheme.success;
    }
    if (feedback == false) {
      bg = AppTheme.accent.withValues(alpha: 0.1);
      borderColor = AppTheme.accent;
    }

    Widget child = Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: bg ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor == Colors.transparent
                    ? AppTheme.primaryLight.withValues(alpha: 0.2)
                    : borderColor,
                width: 2,
              ),
            ),
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );

    if (feedback == true) {
      return child.animate().shimmer(duration: 400.ms, color: AppTheme.success.withValues(alpha: 0.3));
    } else if (feedback == false) {
      return child.animate().shake(hz: 8, curve: Curves.easeInOutCubic, duration: 400.ms);
    }

    return child;
  }
}
