import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/api_config.dart';
import '../models/bible_book.dart';
import '../models/verse.dart';

class BibleService {
  BibleService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<ChapterContent> fetchChapter(BibleBook book, int chapter) async {
    final url = ApiConfig.chapterUri(book.bookNumber, chapter);

    final response = await _client.get(url).timeout(
      const Duration(seconds: 20),
      onTimeout: () => throw BibleServiceException(
        'Tiempo de espera agotado. ¿Está activa la API en ${ApiConfig.bibleBaseUrl}?',
      ),
    );

    if (response.statusCode != 200) {
      throw BibleServiceException(
        'No se pudo cargar el capítulo (${response.statusCode}). '
        'Verifica que el libro ${book.bookNumber} y el capítulo $chapter existan.',
      );
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final rawVerses = data['verses'] as List<dynamic>? ?? [];

    final verses = rawVerses.map((v) {
      final map = v as Map<String, dynamic>;
      return Verse(
        number: map['verse'] as int? ?? 0,
        text: (map['text'] as String? ?? '').trim(),
      );
    }).toList();

    if (verses.isEmpty) {
      throw BibleServiceException('El capítulo no tiene versículos');
    }

    final bookName = data['book_name'] as String? ?? book.name;
    final chapterNum = data['chapter'] as int? ?? chapter;

    return ChapterContent(
      bookName: bookName,
      chapter: chapterNum,
      verses: verses,
      reference: '$bookName $chapterNum · Reina-Valera 1909',
    );
  }

  void dispose() => _client.close();
}

class BibleServiceException implements Exception {
  BibleServiceException(this.message);
  final String message;

  @override
  String toString() => message;
}
