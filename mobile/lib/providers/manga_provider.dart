// mobile/lib/providers/manga_provider.dart
import 'package:flutter/material.dart';
import 'package:mobile/models/manga.dart';
import 'package:mobile/services/api_service.dart';

class MangaProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Manga> _searchResults = [];
  List<Manga> _recommendations = [];
  List<Manga> _userMangas = [];
  List<Manga> _readingList = [];
  List<Manga> _favouriteList = [];
  List<Manga> _planToReadList = [];
  List<Manga> _readList = [];
  List<Manga> _history = [];

  List<Manga> get searchResults => _searchResults;
  List<Manga> get recommendations => _recommendations;
  List<Manga> get readingList => _readingList;
  List<Manga> get favouriteList => _favouriteList;
  List<Manga> get planToReadList => _planToReadList;
  List<Manga> get readList => _readList;
  List<Manga> get history => _history;

  Future<void> searchManga(String query) async {
    try {
      _searchResults = await _apiService.searchManga(query);
      _userMangas = await _apiService.fetchUserMangas();
      await _loadMangaDetails(_searchResults);
      List<Manga> filteredMangas = _searchResults.where((manga) => manga.chapters.isNotEmpty).toList();
      _searchResults = filteredMangas;
      notifyListeners();
    } catch (e) {
      print('Failed to search manga: $e');
    }
  }

  Future<void> clearSearchResults() async {
    try {
      _searchResults = [];
      notifyListeners();
    } catch (e) {
      print('Failed to clean search results: $e');
    }
  }

  Future<void> fetchRecommendations() async {
    try {
      _recommendations = await _apiService.fetchRecommendations();
      _userMangas = await _apiService.fetchUserMangas();
      await _loadMangaDetails(_recommendations);
      List<Manga> filteredMangas = _recommendations.where((manga) => manga.chapters.isNotEmpty).toList();
      _recommendations = filteredMangas;
      notifyListeners();
    } catch (e) {
      print('Failed to fetch recommendations: $e');
    }
  }

  Future<void> fetchReadingList() async {
    try {
      _userMangas = await _apiService.fetchUserMangas();
      await _loadMangaDetails(_userMangas);
      List<Manga> filteredMangas = _userMangas.where((manga) => manga.chapters.isNotEmpty && manga.userStatus == 'reading').toList();
      _readingList = filteredMangas;
      notifyListeners();
    } catch (e) {
      print('Failed to fetch reading list: $e');
    }
  }

  Future<void> fetchFavouriteList() async {
    try {
      _userMangas = await _apiService.fetchUserMangas();
      await _loadMangaDetails(_userMangas);
      List<Manga> filteredMangas = _userMangas.where((manga) => manga.chapters.isNotEmpty && manga.isFavourite).toList();
      _favouriteList = filteredMangas;
      notifyListeners();
    } catch (e) {
      print('Failed to fetch favourite list: $e');
    }
  }

  Future<void> fetchPlanToReadList() async {
    try {
      _userMangas = await _apiService.fetchUserMangas();
      await _loadMangaDetails(_userMangas);
      List<Manga> filteredMangas = _userMangas.where((manga) => manga.chapters.isNotEmpty && manga.userStatus == 'plan_to_read').toList();
      _planToReadList = filteredMangas;
      notifyListeners();
    } catch (e) {
      print('Failed to fetch plan to read list: $e');
    }
  }

  Future<void> fetchReadList() async {
    try {
      _userMangas = await _apiService.fetchUserMangas();
      await _loadMangaDetails(_userMangas);
      List<Manga> filteredMangas = _userMangas.where((manga) => manga.chapters.isNotEmpty && manga.userStatus == 'completed').toList();
      _readList = filteredMangas;
      notifyListeners();
    } catch (e) {
      print('Failed to fetch read list: $e');
    }
  }

  Future<void> fetchHistory() async {
    try {
      _history = await _apiService.fetchHistory();
      await _loadMangaDetails(_history);
      List<Manga> filteredMangas = _history.where((manga) => manga.chapters.isNotEmpty).toList();
      _history = filteredMangas.reversed.toList();
      notifyListeners();
    } catch (e) {
      print('Failed to fetch history: $e');
    }
  }

  Future<void> _loadMangaDetails(List<Manga> mangas) async {
    for (var manga in mangas) {
      if (manga.coverImageUrl.isEmpty || manga.coverImageUrl.startsWith('image/svg+xml;base64')) {
        Manga? details = await fetchMangaDetails(manga.id);
        if (details != null) {
          manga.coverImageUrl = details.coverImageUrl;
          manga.chaptersCount = details.chaptersCount;
          manga.status = details.status;
          manga.genres = details.genres;
          manga.year = details.year;
          manga.chapters = details.chapters;
        }
      }
    }
  }

  Future<Manga?> fetchMangaDetails(int mangaId) async {
    try {
      Manga? mangaDetails = await _apiService.fetchMangaDetails(mangaId);
      for (var manga in _userMangas){
        if(manga.id==mangaId){
          mangaDetails.userStatus = manga.userStatus;
          mangaDetails.isFavourite = manga.isFavourite;
        }
      }
      return mangaDetails;
    } catch (e) {
      print('Failed to fetch manga details: $e');
      return null;
    }
  }

  Future<void> updateMangaStatus(int mangaId, bool isFavorite, String status) async {
    try {
      await _apiService.updateMangaStatus(mangaId, isFavorite, status);
      fetchReadingList();
    } catch (e) {
      print('Failed to update manga status: $e');
    }
  }

  Future<void> updateHistory(int mangaId, int chapterId) async {
    try {
      await _apiService.updateHistory(mangaId, chapterId);
      fetchHistory();
    } catch (e) {
      print('Failed to update history: $e');
    }
  }
}