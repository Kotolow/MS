// mobile/lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/models/user.dart';
import 'package:mobile/models/manga.dart';
import 'package:mobile/models/user_stats.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _baseUrl = 'https://4cb3-5-39-220-23.ngrok-free.app';

  Future<String> register(User user) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api-registration/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': user.username,
        'password': user.password,
      }),
    );

    if (response.statusCode == 201) {
      return 'Registration successful';
    } else {
      final errorResponse = jsonDecode(response.body);
      throw Exception('Failed to register: ${errorResponse.toString()}');
    }
  }

  Future<String> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api-token-auth/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final token = jsonDecode(response.body)['token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      return token;
    } else {
      final errorResponse = jsonDecode(response.body);
      throw Exception('Failed to login: ${errorResponse.toString()}');
    }
  }

  Future<void> saveUserGenres(List<String> genres) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    final genresString = genres.join(', ');

    final response = await http.post(
      Uri.parse('$_baseUrl/api/user-genres/'),
      headers: await postHeaders,
      body: jsonEncode({'genres': genresString}),
    );

    if (response.statusCode != 200) {
      final errorResponse = jsonDecode(response.body);
      throw Exception('Failed to save genres: ${errorResponse.toString()}');
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> get headers async {
    final token = await _getToken();
    return {
      'Authorization': 'Token $token',
    };
  }

  Future<Map<String, String>> get postHeaders async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token',
    };
  }

  Future<List<Manga>> searchManga(String query) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/mangas/search/?q=$query'),
      headers: await headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((json) => Manga.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search manga');
    }
  }

  Future<List<Manga>> fetchRecommendations() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/recommendations/'),
      headers: await headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((json) => Manga.fromJson(json)).toList().toList().take(30).toList();
    } else {
      throw Exception('Failed to load recommendations');
    }
  }

  Future<List<Manga>> fetchUserMangas() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/user-mangas'),
      headers: await headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));

      List<Manga> mangaList = jsonList.map((json) {
        var mangaJson = json['manga'];
        Manga manga = Manga.fromJson(mangaJson);
        manga.userStatus = json['status'];
        manga.isFavourite = json['is_favorite'];
        return manga;
      }).toList();

      return mangaList;
    } else {
      throw Exception('Failed to load reading list');
    }
  }

  Future<Manga> fetchMangaDetails(int mangaId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/mangas/$mangaId/'),
      headers: await headers,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      return Manga.fromJson(json);
    } else {
      throw Exception('Failed to load manga details');
    }
  }

  Future<void> updateMangaStatus(int mangaId, bool isFavorite, String status) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/user-mangas/'),
      headers: await postHeaders,
      body: jsonEncode({
        'manga': mangaId,
        'is_favorite': isFavorite,
        'status': status,
      }),
    );

    if (response.statusCode != 201) {
      final errorResponse = jsonDecode(response.body);
      throw Exception('Failed to update manga status: ${errorResponse.toString()}');
    }
  }

  Future<http.Response> fetchChapterImages(int mangaId, int chapterId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/mangas/$mangaId/chapter_images/?chapter_id=$chapterId'),
      headers: await headers,
    );

    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Failed to load chapter images');
    }
  }

  Future<List<Manga>> fetchHistory() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/history'),
      headers: await headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));

      List<Manga> mangaList = jsonList.map((json) {
        var mangaJson = json['manga'];
        Manga manga = Manga.fromJson(mangaJson);
        manga.description = json['chapter']['title'];
        return manga;
      }).toList();

      return mangaList;
    } else {
      throw Exception('Failed to load reading list');
    }
  }

  Future<void> updateHistory(int mangaId, int chapterId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/history/'),
      headers: await postHeaders,
      body: jsonEncode({
        'manga': mangaId,
        'chapter': chapterId,
      }),
    );

    if (response.statusCode != 201) {
      final errorResponse = jsonDecode(response.body);
      throw Exception('Failed to update history: ${errorResponse.toString()}');
    }
  }

  Future<UserStats> fetchUserStats() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/user-stats/stats'),
      headers: await headers,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return UserStats.fromJson(json);
    } else {
      throw Exception('Failed to load user stats');
    }
  }
}