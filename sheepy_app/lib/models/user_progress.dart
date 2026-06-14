class UserProgress {
  const UserProgress({
    this.selectedBookId = 'genesis',
    this.completedChapters = const {},
    this.xp = 120,
    this.streak = 0,
    this.lives = 5,
    this.isDarkMode = false,
    this.lastActiveDate,
  });

  final String selectedBookId;
  final Map<String, List<int>> completedChapters;
  final int xp;
  final int streak;
  final int lives;
  final bool isDarkMode;
  final String? lastActiveDate;

  List<int> completedFor(String bookId) =>
      List<int>.from(completedChapters[bookId] ?? const []);

  bool isChapterCompleted(String bookId, int chapter) =>
      completedFor(bookId).contains(chapter);

  bool isChapterUnlocked(String bookId, int chapter) =>
      chapter == 1 || completedFor(bookId).contains(chapter - 1);

  double bookProgress(String bookId, int totalChapters) {
    if (totalChapters == 0) return 0;
    return completedFor(bookId).length / totalChapters;
  }

  UserProgress copyWith({
    String? selectedBookId,
    Map<String, List<int>>? completedChapters,
    int? xp,
    int? streak,
    int? lives,
    bool? isDarkMode,
    String? lastActiveDate,
  }) {
    return UserProgress(
      selectedBookId: selectedBookId ?? this.selectedBookId,
      completedChapters: completedChapters ?? this.completedChapters,
      xp: xp ?? this.xp,
      streak: streak ?? this.streak,
      lives: lives ?? this.lives,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'selectedBookId': selectedBookId,
        'completedChapters': completedChapters.map(
          (k, v) => MapEntry(k, v),
        ),
        'xp': xp,
        'streak': streak,
        'lives': lives,
        'isDarkMode': isDarkMode,
        'lastActiveDate': lastActiveDate,
      };

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    final raw = json['completedChapters'] as Map<String, dynamic>? ?? {};
    final chapters = raw.map(
      (key, value) => MapEntry(
        key,
        (value as List<dynamic>).map((e) => e as int).toList(),
      ),
    );
    return UserProgress(
      selectedBookId: json['selectedBookId'] as String? ?? 'genesis',
      completedChapters: chapters,
      xp: json['xp'] as int? ?? 0,
      streak: json['streak'] as int? ?? 0,
      lives: json['lives'] as int? ?? 5,
      isDarkMode: json['isDarkMode'] as bool? ?? false,
      lastActiveDate: json['lastActiveDate'] as String?,
    );
  }
}
