// mobile/lib/providers/registration_provider.dart

import 'package:flutter/material.dart';
import 'package:mobile/models/user.dart';
import 'package:mobile/services/api_service.dart';

class RegistrationProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  String _registrationStatus = '';
  List<String> _userGenres = [];

  String get registrationStatus => _registrationStatus;
  List<String> get userGenres => _userGenres;

  Future<void> registerUser(String username, String password) async {
    _registrationStatus = 'Loading';
    notifyListeners();
    try {
      final user = User(username: username, password: password);
      _registrationStatus = await _apiService.register(user);
    } catch (e) {
      _registrationStatus = 'Failed to register: ${e.toString()}';
    } finally {
      notifyListeners();
    }
  }

  void addGenre(String genre) {
    _userGenres.add(genre);
    notifyListeners();
  }

  void removeGenre(String genre) {
    _userGenres.remove(genre);
    notifyListeners();
  }

  Future<void> saveGenres() async {
    try {
      await _apiService.saveUserGenres(_userGenres);
      _registrationStatus = 'Genres saved successfully';
      notifyListeners();
    } catch (error) {
      _registrationStatus = 'Failed to save genres: $error';
      notifyListeners();
    }
  }
}