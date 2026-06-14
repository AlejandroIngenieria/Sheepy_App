import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_theme.dart';
import '../providers/providers.dart';

class LeaguesScreen extends ConsumerWidget {
  const LeaguesScreen({super.key});

  static const _mockLeaders = [
    ('María', 1840, 1),
    ('Carlos', 1620, 2),
    ('Ana', 1410, 3),
    ('Lector Creyente (Tú)', 0, 4),
    ('Pedro', 980, 5),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final xp = ref.watch(userProgressProvider).xp;
    final league = _leagueForXp(xp);

    final leaders = _mockLeaders.map((e) {
      if (e.$3 == 4) return (e.$1, xp, e.$3);
      return e;
    }).toList()
      ..sort((a, b) => b.$2.compareTo(a.$2));

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [league.color, league.color.withValues(alpha: 0.6)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Icon(league.icon, size: 64, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                'Liga ${league.name}',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '$xp XP esta semana',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Clasificación',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...leaders.asMap().entries.map((entry) {
          final rank = entry.key + 1;
          final (name, points, _) = entry.value;
          final isYou = name.contains('(Tú)');

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: isYou ? AppTheme.primary.withValues(alpha: 0.12) : null,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: rank <= 3 ? league.color : Colors.grey,
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                name,
                style: TextStyle(
                  fontWeight: isYou ? FontWeight.bold : FontWeight.w600,
                  color: isYou ? AppTheme.primaryDark : null,
                ),
              ),
              trailing: Text(
                '$points XP',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        }),
      ],
    );
  }

  static _LeagueInfo _leagueForXp(int xp) {
    if (xp >= 2000) return _LeagueInfo('Diamante', Icons.diamond, Color(0xFF80DEEA));
    if (xp >= 1000) return _LeagueInfo('Oro', Icons.emoji_events, Color(0xFFFFD54F));
    if (xp >= 500) return _LeagueInfo('Plata', Icons.military_tech, Color(0xFFB0BEC5));
    return _LeagueInfo('Bronce', Icons.shield, Color(0xFFBCAAA4));
  }
}

class _LeagueInfo {
  const _LeagueInfo(this.name, this.icon, this.color);
  final String name;
  final IconData icon;
  final Color color;
}
