class UserStats {
  UserStats({
    required this.id,
    required this.username,
    required this.email,
    required this.points,
    required this.leagueId,
    required this.leagueName,
    required this.leagueColorHex,
    required this.coins,
    required this.currentLives,
    required this.minutesUntilNextLife,
    required this.currentStreak,
    required this.longestStreak,
  });

  final int id;
  final String username;
  final String email;
  final int points;
  final int leagueId;
  final String? leagueName;
  final String? leagueColorHex;
  final int coins;
  final int currentLives;
  final int minutesUntilNextLife;
  final int currentStreak;
  final int longestStreak;

  static int _parseInt(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      id: _parseInt(json['id'], 0),
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      points: _parseInt(json['points'], 0),
      leagueId: _parseInt(json['league_id'], 1),
      leagueName: json['league_name']?.toString(),
      leagueColorHex: json['color_hex']?.toString(),
      coins: _parseInt(json['coins'], 0),
      currentLives: _parseInt(json['current_lives'], 5),
      minutesUntilNextLife: _parseInt(json['minutes_until_next_life'], 0),
      currentStreak: _parseInt(json['current_streak'], 0),
      longestStreak: _parseInt(json['longest_streak'], 0),
    );
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'points': points,
    'league_id': leagueId,
    'league_name': leagueName,
    'color_hex': leagueColorHex,
    'coins': coins,
    'current_lives': currentLives,
    'minutes_until_next_life': minutesUntilNextLife,
    'current_streak': currentStreak,
    'longest_streak': longestStreak,
  };
}
