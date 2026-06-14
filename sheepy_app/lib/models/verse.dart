class Verse {
  const Verse({required this.number, required this.text});

  final int number;
  final String text;
}

class ChapterContent {
  const ChapterContent({
    required this.bookName,
    required this.chapter,
    required this.verses,
    this.reference,
  });

  final String bookName;
  final int chapter;
  final List<Verse> verses;
  final String? reference;
}
