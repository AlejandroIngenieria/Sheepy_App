import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/bible_books.dart';
import '../models/bible_book.dart';
import '../models/user_progress.dart';
import '../models/verse.dart';
import '../services/bible_service.dart';
import '../services/progress_storage.dart';
import '../services/gamification_service.dart';
import '../services/auth_service.dart';
import '../models/user_stats.dart';
import '../services/quiz_service.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences debe inyectarse en main()');
});

final progressStorageProvider = Provider<ProgressStorage>((ref) {
  return ProgressStorage(ref.watch(sharedPreferencesProvider));
});

final bibleServiceProvider = Provider<BibleService>((ref) {
  final service = BibleService();
  ref.onDispose(service.dispose);
  return service;
});

final gamificationServiceProvider = Provider<GamificationService>((ref) => GamificationService());

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final userStatsProvider = FutureProvider<UserStats>((ref) async {
  final stats = await ref.read(authServiceProvider).fetchMe();
  
  // Sincronizar capítulos completados en segundo plano
  try {
    final completed = await ref.read(gamificationServiceProvider).getCompletedChapters();
    ref.read(userProgressProvider.notifier).syncFromBackend(completed);
  } catch (e) {
    debugPrint('Error syncing progress: $e');
  }

  return stats;
});

final booksProgressProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return await ref.read(gamificationServiceProvider).getBooksProgress();
});

final leaderboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return await ref.read(gamificationServiceProvider).getLeaderboard();
});

final quizServiceProvider = Provider<QuizService>((ref) => QuizService());

final userProgressProvider =
    StateNotifierProvider<UserProgressNotifier, UserProgress>((ref) {
  return UserProgressNotifier(ref.watch(progressStorageProvider));
});

class UserProgressNotifier extends StateNotifier<UserProgress> {
  UserProgressNotifier(this._storage) : super(const UserProgress()) {
    _load();
  }

  final ProgressStorage _storage;

  Future<void> _load() async {
    state = await _storage.load();
  }

  Future<void> _persist() => _storage.save(state);

  void syncFromBackend(List<Map<String, dynamic>> completedRows) {
    final map = Map<String, List<int>>.from(state.completedChapters);
    for (var row in completedRows) {
      final bookRaw = row['book_number'];
      final chapterRaw = row['chapter'];
      
      final bookNum = bookRaw is int ? bookRaw : int.tryParse(bookRaw?.toString() ?? '') ?? 0;
      final chapter = chapterRaw is int ? chapterRaw : int.tryParse(chapterRaw?.toString() ?? '') ?? 0;
      
      // Convert bookNumber to bookId
      final book = allBibleBooks.where((b) => b.bookNumber == bookNum).firstOrNull;
      if (book != null) {
        final list = List<int>.from(map[book.id] ?? []);
        if (!list.contains(chapter)) {
          list.add(chapter);
          map[book.id] = list;
        }
      }
    }
    state = state.copyWith(completedChapters: map);
    _persist();
  }

  void selectBook(String bookId) {
    state = state.copyWith(selectedBookId: bookId);
    _persist();
  }

  void toggleDarkMode() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
    _persist();
  }

  Future<void> completeChapter(String bookId, int chapter) async {
    final map = Map<String, List<int>>.from(state.completedChapters);
    final list = List<int>.from(map[bookId] ?? []);
    if (list.contains(chapter)) return;

    list.add(chapter);
    map[bookId] = list;

    final today = DateTime.now().toIso8601String().substring(0, 10);
    var streak = state.streak;
    final last = state.lastActiveDate;
    if (last == null) {
      streak = 1;
    } else if (last == today) {
      // mismo día, mantener racha
    } else {
      final lastDate = DateTime.parse(last);
      final diff = DateTime.now().difference(lastDate).inDays;
      streak = diff == 1 ? streak + 1 : 1;
    }

    state = state.copyWith(
      completedChapters: map,
      xp: state.xp + 25,
      streak: streak,
      lastActiveDate: today,
    );
    await _persist();
  }
}

final selectedBookProvider = Provider<BibleBook>((ref) {
  final progress = ref.watch(userProgressProvider);
  return bookById(progress.selectedBookId) ?? allBibleBooks.first;
});

typedef ChapterKey = ({String bookId, int chapter});

final chapterContentProvider =
    FutureProvider.family<ChapterContent, ChapterKey>((ref, key) async {
  final book = bookById(key.bookId);
  if (book == null) {
    throw BibleServiceException('Libro no encontrado');
  }
  return ref.read(bibleServiceProvider).fetchChapter(book, key.chapter);
});

enum AppOverlay { none, read, quiz }

class NavigationState {
  const NavigationState({
    this.tabIndex = 0,
    this.overlay = AppOverlay.none,
    this.activeChapter = 1,
  });

  final int tabIndex;
  final AppOverlay overlay;
  final int activeChapter;

  NavigationState copyWith({
    int? tabIndex,
    AppOverlay? overlay,
    int? activeChapter,
  }) {
    return NavigationState(
      tabIndex: tabIndex ?? this.tabIndex,
      overlay: overlay ?? this.overlay,
      activeChapter: activeChapter ?? this.activeChapter,
    );
  }
}

class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier() : super(const NavigationState());

  void setTab(int index) => state = state.copyWith(tabIndex: index, overlay: AppOverlay.none);

  void openChapter(int chapter) =>
      state = state.copyWith(overlay: AppOverlay.read, activeChapter: chapter);

  void openQuiz() => state = state.copyWith(overlay: AppOverlay.quiz);

  void goHome() => state = state.copyWith(overlay: AppOverlay.none);
}

final navigationProvider =
    StateNotifierProvider<NavigationNotifier, NavigationState>(
  (ref) => NavigationNotifier(),
);
