import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_theme.dart';
import '../providers/providers.dart';
import 'books_screen.dart';
import 'leagues_screen.dart';
import 'path_screen.dart';
import 'quiz_screen.dart';
import 'read_screen.dart';
import 'settings_screen.dart';
import '../widgets/lives_widget.dart';

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = ref.watch(navigationProvider);
    final progress = ref.watch(userProgressProvider);
    final userStatsAsync = ref.watch(userStatsProvider);

    if (nav.overlay == AppOverlay.read) {
      return ReadScreen(chapter: nav.activeChapter);
    }
    if (nav.overlay == AppOverlay.quiz) {
      return QuizScreen(chapter: nav.activeChapter);
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🐑', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(
              'Sheepy',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: AppTheme.primary,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          userStatsAsync.when(
            data: (stats) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                children: [
                  LivesWidget(
                    userStats: stats,
                    onZeroLives: () {
                      ref.invalidate(userStatsProvider);
                    },
                  ),
                  const SizedBox(width: 12),
                  // Streak chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.fire.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_fire_department_rounded, color: AppTheme.fire, size: 18),
                        const SizedBox(width: 3),
                        Text(
                          '${stats.currentStreak}',
                          style: const TextStyle(
                            color: AppTheme.fire,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Coins chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.monetization_on_rounded, color: AppTheme.gold, size: 18),
                        const SizedBox(width: 3),
                        Text(
                          '${stats.coins}',
                          style: TextStyle(
                            color: Colors.amber.shade800,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (e, s) => const Icon(Icons.error_outline_rounded),
          ),
        ],
      ),
      body: IndexedStack(
        index: nav.tabIndex,
        children: const [
          PathScreen(),
          BooksScreen(),
          LeaguesScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: nav.tabIndex,
        onDestinationSelected: (i) =>
            ref.read(navigationProvider.notifier).setTab(i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.route_rounded),
            selectedIcon: Icon(Icons.route_rounded, color: AppTheme.primary),
            label: 'Camino',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories_rounded),
            selectedIcon: Icon(Icons.auto_stories_rounded, color: AppTheme.primary),
            label: 'Libros',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_rounded),
            selectedIcon: Icon(Icons.emoji_events_rounded, color: AppTheme.primary),
            label: 'Ligas',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: AppTheme.primary),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
