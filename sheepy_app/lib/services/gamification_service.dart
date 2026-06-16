import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import 'auth_service.dart';

class GamificationService {
  GamificationService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<void> loseLife() async {
    final token = await AuthService().getToken();
    if (token == null) return;

    final url = Uri.parse('${ApiConfig.bibleBaseUrl}/api/users/lose_life');
    await _client.post(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<bool> saveProgress(int bookNumber, int chapter) async {
    final token = await AuthService().getToken();
    if (token == null) return false;

    final url = Uri.parse('${ApiConfig.bibleBaseUrl}/api/users/progress');
    final response = await _client.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'book_number': bookNumber,
        'chapter': chapter,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['new_chapter'] == true;
    }
    return false;
  }

  Future<List<Map<String, dynamic>>> getBooksProgress() async {
    final token = await AuthService().getToken();
    if (token == null) return [];

    final url = Uri.parse('${ApiConfig.bibleBaseUrl}/api/books');
    final response = await _client.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<Map<String, dynamic>> getLeaderboard() async {
    final token = await AuthService().getToken();
    if (token == null) return {'leaderboard': []};

    final url = Uri.parse('${ApiConfig.bibleBaseUrl}/api/leagues/leaderboard');
    final response = await _client.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    return {'leaderboard': []};
  }

  Future<List<Map<String, dynamic>>> getCompletedChapters() async {
    final token = await AuthService().getToken();
    if (token == null) return [];

    final url = Uri.parse('${ApiConfig.bibleBaseUrl}/api/users/completed_chapters');
    final response = await _client.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }
}
