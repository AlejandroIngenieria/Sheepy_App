import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/app_theme.dart';
import '../providers/providers.dart';

class LeaguesScreen extends ConsumerWidget {
  const LeaguesScreen({super.key});

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncLeaderboard = ref.watch(leaderboardProvider);
    final userStats = ref.watch(userStatsProvider).valueOrNull;

    return asyncLeaderboard.when(
      data: (data) {
        final List<dynamic> leadersData = data['leaderboard'] ?? [];
        final leaders = leadersData.cast<Map<String, dynamic>>();
        final nextLeaguePoints = data['next_league_points'] as int?;
        
        final leagueName = userStats?.leagueName ?? 'Bronce';
        final leagueColorHex = userStats?.leagueColorHex ?? '#CD7F32';
        final color = _hexToColor(leagueColorHex);

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // League hero card
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.emoji_events_rounded, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Liga $leagueName',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userStats != null ? '${userStats.points} Puntos' : 'Cargando...',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (nextLeaguePoints != null && userStats != null) ...[
                    const SizedBox(height: 12),
                    // Progress to next league
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '⬆️ Faltan ${nextLeaguePoints - userStats.points} pts para subir',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
            const SizedBox(height: 24),
            Text(
              '🏆 Clasificación',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            if (leaders.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'Aún no hay usuarios en esta liga',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ),
              )
            else
              ...leaders.asMap().entries.map((entry) {
                final rank = entry.key + 1;
                final leader = entry.value;
                final isYou = leader['id'] == userStats?.id;
                final name = isYou ? '${leader['username']} (Tú)' : leader['username'];
                final points = leader['points'];

                // Medal emoji for top 3
                String? medal;
                if (rank == 1) medal = '🥇';
                if (rank == 2) medal = '🥈';
                if (rank == 3) medal = '🥉';

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isYou
                        ? AppTheme.primary.withValues(alpha: 0.08)
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: isYou
                        ? Border.all(color: AppTheme.primary.withValues(alpha: 0.3), width: 2)
                        : null,
                  ),
                  child: Row(
                    children: [
                      if (medal != null)
                        Text(medal, style: const TextStyle(fontSize: 24))
                      else
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$rank',
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                            ),
                          ),
                        ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontWeight: isYou ? FontWeight.w900 : FontWeight.w700,
                            color: isYou ? AppTheme.primaryDark : null,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$points pts',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            color: Colors.amber.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: (entry.key * 80).ms).fadeIn().slideX(begin: 0.05);
              }),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }
}
