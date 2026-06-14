import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app_theme.dart';
import 'providers/providers.dart';
import 'screens/home_shell.dart';

class SheepyApp extends ConsumerWidget {
  const SheepyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(userProgressProvider).isDarkMode;

    return MaterialApp(
      title: 'Sheepy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: const HomeShell(),
    );
  }
}
