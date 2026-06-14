import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_config.dart';
import '../providers/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(userProgressProvider);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Configuración',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: SwitchListTile(
            title: const Text('Modo oscuro', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Ajusta la apariencia de la app'),
            value: progress.isDarkMode,
            onChanged: (_) =>
                ref.read(userProgressProvider.notifier).toggleDarkMode(),
            secondary: const Icon(Icons.dark_mode),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.local_fire_department, color: Colors.orange, size: 36),
            title: Text(
              '${progress.streak} días',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Racha de lectura'),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.star, color: Colors.amber, size: 36),
            title: Text(
              '${progress.xp} XP',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Experiencia total'),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.favorite, color: Colors.red, size: 36),
            title: Text(
              '${progress.lives} vidas',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Disponibles para el quiz'),
          ),
        ),
        const SizedBox(height: 16),
        ListTile(
          leading: const Icon(Icons.translate),
          title: const Text('Traducción'),
          subtitle: const Text('Reina-Valera 1909'),
        ),
        ListTile(
          leading: const Icon(Icons.dns),
          title: const Text('API local'),
          subtitle: Text('${ApiConfig.bibleBaseUrl}/api/book/…/chapter/…'),
        ),
        const ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('Sheepy · BibleGo'),
          subtitle: Text('v0.2.0 — Aprende leyendo la Biblia'),
        ),
      ],
    );
  }
}
