import 'dart:math';

import '../models/quiz_question.dart';
import '../models/verse.dart';

class QuizService {
  final _random = Random();

  List<QuizQuestion> generateFromChapter(List<Verse> verses) {
    if (verses.length < 4) {
      return [
        _buildQuestion(
          '¿Cuántos versículos tiene este capítulo?',
          '${verses.length}',
          [
            '${verses.length + 2}',
            '${verses.length + 5}',
            '${verses.length + 10}',
          ],
        ),
      ];
    }

    final questions = <QuizQuestion>[];
    final target = verses[_random.nextInt(verses.length)];
    final distractors = _pickDistractors(verses, target);

    questions.add(
      _buildQuestion(
        '¿Cuál de estos textos corresponde al versículo ${target.number}?',
        target.text,
        distractors.map((v) => v.text).toList(),
      ),
    );

    if (verses.length >= 8) {
      final second = verses[_random.nextInt(verses.length)];
      if (second.number != target.number) {
        questions.add(
          _buildQuestion(
            'Completa la idea del versículo ${second.number}:',
            _snippet(second.text),
            _pickDistractors(verses, second).map((v) => _snippet(v.text)).toList(),
          ),
        );
      }
    }

    return questions;
  }

  QuizQuestion _buildQuestion(String prompt, String correct, List<String> wrong) {
    final options = [correct, ...wrong.take(3)];
    options.shuffle(_random);
    return QuizQuestion(
      prompt: prompt,
      options: options,
      correctIndex: options.indexOf(correct),
    );
  }

  List<Verse> _pickDistractors(List<Verse> verses, Verse exclude) {
    final pool = verses.where((v) => v.number != exclude.number).toList()
      ..shuffle(_random);
    return pool.take(3).toList();
  }

  String _snippet(String text) {
    final clean = text.replaceAll('\n', ' ').trim();
    if (clean.length <= 80) return clean;
    return '${clean.substring(0, 77)}...';
  }
}
