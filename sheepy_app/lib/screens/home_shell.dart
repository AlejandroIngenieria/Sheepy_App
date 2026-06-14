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

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = ref.watch(navigationProvider);
    final progress = ref.watch(userProgressProvider);

    if (nav.overlay == AppOverlay.read) {
      return ReadScreen(chapter: nav.activeChapter);
    }
    if (nav.overlay == AppOverlay.quiz) {
      return QuizScreen(chapter: nav.activeChapter);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '📖 Sheepy',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
        ),
        actions: [
          TextButton.icon(
            onPressed: null,
            icon: const Icon(Icons.local_fire_department, color: Colors.orange),
            label: Text(
              '${progress.streak}',
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  '${progress.xp}',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
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
          NavigationDestination(icon: Icon(Icons.home), label: 'Camino'),
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'Libros'),
          NavigationDestination(icon: Icon(Icons.shield), label: 'Ligas'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }
}
