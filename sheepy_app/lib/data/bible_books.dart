import 'package:flutter/material.dart';
import '../models/bible_book.dart';

const List<Color> _woolPalette = [
  Color(0xFFFFF8E7),
  Color(0xFFFFE4E1),
  Color(0xFFE0F7FA),
  Color(0xFFF3E5F5),
  Color(0xFFFFF9C4),
  Color(0xFFE8F5E9),
  Color(0xFFFFECB3),
  Color(0xFFE1BEE7),
  Color(0xFFBBDEFB),
  Color(0xFFFFCCBC),
  Color(0xFFC8E6C9),
  Color(0xFFD1C4E9),
  Color(0xFFB2DFDB),
  Color(0xFFFFE0B2),
  Color(0xFFCFD8DC),
  Color(0xFFF8BBD9),
  Color(0xFFB3E5FC),
  Color(0xFFDCEDC8),
  Color(0xFFFFCDD2),
  Color(0xFFD7CCC8),
  Color(0xFFC5CAE9),
  Color(0xFFB2EBF2),
];

Color _woolAt(int index) => _woolPalette[index % _woolPalette.length];

final List<BibleBook> allBibleBooks = [
  BibleBook(id: 'genesis', bookNumber: 1, name: 'Génesis', chapters: 50, woolColor: _woolAt(0), testament: Testament.old),
  BibleBook(id: 'exodus', bookNumber: 2, name: 'Éxodo', chapters: 40, woolColor: _woolAt(1), testament: Testament.old),
  BibleBook(id: 'leviticus', bookNumber: 3, name: 'Levítico', chapters: 27, woolColor: _woolAt(2), testament: Testament.old),
  BibleBook(id: 'numbers', bookNumber: 4, name: 'Números', chapters: 36, woolColor: _woolAt(3), testament: Testament.old),
  BibleBook(id: 'deuteronomy', bookNumber: 5, name: 'Deuteronomio', chapters: 34, woolColor: _woolAt(4), testament: Testament.old),
  BibleBook(id: 'joshua', bookNumber: 6, name: 'Josué', chapters: 24, woolColor: _woolAt(5), testament: Testament.old),
  BibleBook(id: 'judges', bookNumber: 7, name: 'Jueces', chapters: 21, woolColor: _woolAt(6), testament: Testament.old),
  BibleBook(id: 'ruth', bookNumber: 8, name: 'Rut', chapters: 4, woolColor: _woolAt(7), testament: Testament.old),
  BibleBook(id: '1_samuel', bookNumber: 9, name: '1 Samuel', chapters: 31, woolColor: _woolAt(8), testament: Testament.old),
  BibleBook(id: '2_samuel', bookNumber: 10, name: '2 Samuel', chapters: 24, woolColor: _woolAt(9), testament: Testament.old),
  BibleBook(id: '1_kings', bookNumber: 11, name: '1 Reyes', chapters: 22, woolColor: _woolAt(10), testament: Testament.old),
  BibleBook(id: '2_kings', bookNumber: 12, name: '2 Reyes', chapters: 25, woolColor: _woolAt(11), testament: Testament.old),
  BibleBook(id: '1_chronicles', bookNumber: 13, name: '1 Crónicas', chapters: 29, woolColor: _woolAt(12), testament: Testament.old),
  BibleBook(id: '2_chronicles', bookNumber: 14, name: '2 Crónicas', chapters: 36, woolColor: _woolAt(13), testament: Testament.old),
  BibleBook(id: 'ezra', bookNumber: 15, name: 'Esdras', chapters: 10, woolColor: _woolAt(14), testament: Testament.old),
  BibleBook(id: 'nehemiah', bookNumber: 16, name: 'Nehemías', chapters: 13, woolColor: _woolAt(15), testament: Testament.old),
  BibleBook(id: 'esther', bookNumber: 17, name: 'Ester', chapters: 10, woolColor: _woolAt(16), testament: Testament.old),
  BibleBook(id: 'job', bookNumber: 18, name: 'Job', chapters: 42, woolColor: _woolAt(17), testament: Testament.old),
  BibleBook(id: 'psalms', bookNumber: 19, name: 'Salmos', chapters: 150, woolColor: _woolAt(18), testament: Testament.old),
  BibleBook(id: 'proverbs', bookNumber: 20, name: 'Proverbios', chapters: 31, woolColor: _woolAt(19), testament: Testament.old),
  BibleBook(id: 'ecclesiastes', bookNumber: 21, name: 'Eclesiastés', chapters: 12, woolColor: _woolAt(20), testament: Testament.old),
  BibleBook(id: 'song_of_solomon', bookNumber: 22, name: 'Cantares', chapters: 8, woolColor: _woolAt(21), testament: Testament.old),
  BibleBook(id: 'isaiah', bookNumber: 23, name: 'Isaías', chapters: 66, woolColor: _woolAt(0), testament: Testament.old),
  BibleBook(id: 'jeremiah', bookNumber: 24, name: 'Jeremías', chapters: 52, woolColor: _woolAt(1), testament: Testament.old),
  BibleBook(id: 'lamentations', bookNumber: 25, name: 'Lamentaciones', chapters: 5, woolColor: _woolAt(2), testament: Testament.old),
  BibleBook(id: 'ezekiel', bookNumber: 26, name: 'Ezequiel', chapters: 48, woolColor: _woolAt(3), testament: Testament.old),
  BibleBook(id: 'daniel', bookNumber: 27, name: 'Daniel', chapters: 12, woolColor: _woolAt(4), testament: Testament.old),
  BibleBook(id: 'hosea', bookNumber: 28, name: 'Oseas', chapters: 14, woolColor: _woolAt(5), testament: Testament.old),
  BibleBook(id: 'joel', bookNumber: 29, name: 'Joel', chapters: 3, woolColor: _woolAt(6), testament: Testament.old),
  BibleBook(id: 'amos', bookNumber: 30, name: 'Amós', chapters: 9, woolColor: _woolAt(7), testament: Testament.old),
  BibleBook(id: 'obadiah', bookNumber: 31, name: 'Abdías', chapters: 1, woolColor: _woolAt(8), testament: Testament.old),
  BibleBook(id: 'jonah', bookNumber: 32, name: 'Jonás', chapters: 4, woolColor: _woolAt(9), testament: Testament.old),
  BibleBook(id: 'micah', bookNumber: 33, name: 'Miqueas', chapters: 7, woolColor: _woolAt(10), testament: Testament.old),
  BibleBook(id: 'nahum', bookNumber: 34, name: 'Nahúm', chapters: 3, woolColor: _woolAt(11), testament: Testament.old),
  BibleBook(id: 'habakkuk', bookNumber: 35, name: 'Habacuc', chapters: 3, woolColor: _woolAt(12), testament: Testament.old),
  BibleBook(id: 'zephaniah', bookNumber: 36, name: 'Sofonías', chapters: 3, woolColor: _woolAt(13), testament: Testament.old),
  BibleBook(id: 'haggai', bookNumber: 37, name: 'Hageo', chapters: 2, woolColor: _woolAt(14), testament: Testament.old),
  BibleBook(id: 'zechariah', bookNumber: 38, name: 'Zacarías', chapters: 14, woolColor: _woolAt(15), testament: Testament.old),
  BibleBook(id: 'malachi', bookNumber: 39, name: 'Malaquías', chapters: 4, woolColor: _woolAt(16), testament: Testament.old),
  BibleBook(id: 'matthew', bookNumber: 40, name: 'Mateo', chapters: 28, woolColor: _woolAt(17), testament: Testament.nuevo),
  BibleBook(id: 'mark', bookNumber: 41, name: 'Marcos', chapters: 16, woolColor: _woolAt(18), testament: Testament.nuevo),
  BibleBook(id: 'luke', bookNumber: 42, name: 'Lucas', chapters: 24, woolColor: _woolAt(19), testament: Testament.nuevo),
  BibleBook(id: 'john', bookNumber: 43, name: 'Juan', chapters: 21, woolColor: _woolAt(20), testament: Testament.nuevo),
  BibleBook(id: 'acts', bookNumber: 44, name: 'Hechos', chapters: 28, woolColor: _woolAt(21), testament: Testament.nuevo),
  BibleBook(id: 'romans', bookNumber: 45, name: 'Romanos', chapters: 16, woolColor: _woolAt(0), testament: Testament.nuevo),
  BibleBook(id: '1_corinthians', bookNumber: 46, name: '1 Corintios', chapters: 16, woolColor: _woolAt(1), testament: Testament.nuevo),
  BibleBook(id: '2_corinthians', bookNumber: 47, name: '2 Corintios', chapters: 13, woolColor: _woolAt(2), testament: Testament.nuevo),
  BibleBook(id: 'galatians', bookNumber: 48, name: 'Gálatas', chapters: 6, woolColor: _woolAt(3), testament: Testament.nuevo),
  BibleBook(id: 'ephesians', bookNumber: 49, name: 'Efesios', chapters: 6, woolColor: _woolAt(4), testament: Testament.nuevo),
  BibleBook(id: 'philippians', bookNumber: 50, name: 'Filipenses', chapters: 4, woolColor: _woolAt(5), testament: Testament.nuevo),
  BibleBook(id: 'colossians', bookNumber: 51, name: 'Colosenses', chapters: 4, woolColor: _woolAt(6), testament: Testament.nuevo),
  BibleBook(id: '1_thessalonians', bookNumber: 52, name: '1 Tesalonicenses', chapters: 5, woolColor: _woolAt(7), testament: Testament.nuevo),
  BibleBook(id: '2_thessalonians', bookNumber: 53, name: '2 Tesalonicenses', chapters: 3, woolColor: _woolAt(8), testament: Testament.nuevo),
  BibleBook(id: '1_timothy', bookNumber: 54, name: '1 Timoteo', chapters: 6, woolColor: _woolAt(9), testament: Testament.nuevo),
  BibleBook(id: '2_timothy', bookNumber: 55, name: '2 Timoteo', chapters: 4, woolColor: _woolAt(10), testament: Testament.nuevo),
  BibleBook(id: 'titus', bookNumber: 56, name: 'Tito', chapters: 3, woolColor: _woolAt(11), testament: Testament.nuevo),
  BibleBook(id: 'philemon', bookNumber: 57, name: 'Filemón', chapters: 1, woolColor: _woolAt(12), testament: Testament.nuevo),
  BibleBook(id: 'hebrews', bookNumber: 58, name: 'Hebreos', chapters: 13, woolColor: _woolAt(13), testament: Testament.nuevo),
  BibleBook(id: 'james', bookNumber: 59, name: 'Santiago', chapters: 5, woolColor: _woolAt(14), testament: Testament.nuevo),
  BibleBook(id: '1_peter', bookNumber: 60, name: '1 Pedro', chapters: 5, woolColor: _woolAt(15), testament: Testament.nuevo),
  BibleBook(id: '2_peter', bookNumber: 61, name: '2 Pedro', chapters: 3, woolColor: _woolAt(16), testament: Testament.nuevo),
  BibleBook(id: '1_john', bookNumber: 62, name: '1 Juan', chapters: 5, woolColor: _woolAt(17), testament: Testament.nuevo),
  BibleBook(id: '2_john', bookNumber: 63, name: '2 Juan', chapters: 1, woolColor: _woolAt(18), testament: Testament.nuevo),
  BibleBook(id: '3_john', bookNumber: 64, name: '3 Juan', chapters: 1, woolColor: _woolAt(19), testament: Testament.nuevo),
  BibleBook(id: 'jude', bookNumber: 65, name: 'Judas', chapters: 1, woolColor: _woolAt(20), testament: Testament.nuevo),
  BibleBook(id: 'revelation', bookNumber: 66, name: 'Apocalipsis', chapters: 22, woolColor: _woolAt(21), testament: Testament.nuevo),
];

BibleBook? bookById(String id) {
  for (final b in allBibleBooks) {
    if (b.id == id) return b;
  }
  return null;
}

BibleBook? bookByNumber(int number) {
  for (final b in allBibleBooks) {
    if (b.bookNumber == number) return b;
  }
  return null;
}

List<BibleBook> booksByTestament(Testament testament) =>
    allBibleBooks.where((b) => b.testament == testament).toList();
