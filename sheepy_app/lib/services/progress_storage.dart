import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_progress.dart';

class ProgressStorage {
  ProgressStorage(this._prefs);

  final SharedPreferences _prefs;
  static const _key = 'sheepy_user_progress';

  Future<UserProgress> load() async {
    final raw = _prefs.getString(_key);
    if (raw == null) {
      return const UserProgress(selectedBookId: 'genesis');
    }
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return UserProgress.fromJson(json);
    } catch (_) {
      return const UserProgress();
    }
  }

  Future<void> save(UserProgress progress) async {
    await _prefs.setString(_key, jsonEncode(progress.toJson()));
  }
}
