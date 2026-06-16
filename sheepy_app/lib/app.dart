import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:animations/animations.dart';

import 'core/app_theme.dart';
import 'providers/providers.dart';
import 'screens/home_shell.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';

class SheepyApp extends ConsumerStatefulWidget {
  const SheepyApp({super.key});

  @override
  ConsumerState<SheepyApp> createState() => _SheepyAppState();
}

class _SheepyAppState extends ConsumerState<SheepyApp> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final loggedIn = await AuthService().isLoggedIn();
    if (mounted) {
      setState(() {
        _isLoggedIn = loggedIn;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(userProgressProvider).isDarkMode;

    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      title: 'Sheepy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),

      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: _isLoggedIn ? const HomeShell() : const LoginScreen(),
      onGenerateRoute: (settings) {
        Widget page;
        if (settings.name == '/home') {
          page = const HomeShell();
        } else {
          page = const LoginScreen();
        }

        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.horizontal,
              child: child,
            );
          },
        );
      },
      builder: (context, child) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: child,
          ),
        );
      },
    );
  }
}
