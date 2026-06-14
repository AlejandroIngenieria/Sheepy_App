import 'package:flutter/material.dart';

enum Testament { old, nuevo }

class BibleBook {
  const BibleBook({
    required this.id,
    required this.bookNumber,
    required this.name,
    required this.chapters,
    required this.woolColor,
    required this.testament,
  });

  final String id;
  /// Número canónico del libro (1 = Génesis … 66 = Apocalipsis).
  final int bookNumber;
  final String name;
  final int chapters;
  final Color woolColor;
  final Testament testament;
}
