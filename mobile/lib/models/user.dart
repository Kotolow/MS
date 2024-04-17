// mobile/lib/models/user.dart

class User {
  final String username;
  final String password;
  final List<String> genres;

  User({required this.username, required this.password, this.genres = const []});
}