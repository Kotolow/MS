// mobile/lib/models/user_stats.dart
class UserStats {
  final String username;
  final int readingCount;
  final int planToReadCount;
  final int completedCount;
  final int favoriteCount;
  final int chaptersReadCount;

  UserStats({
    required this.username,
    required this.readingCount,
    required this.planToReadCount,
    required this.completedCount,
    required this.favoriteCount,
    required this.chaptersReadCount,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      username: json['username'],
      readingCount: json['reading_count'],
      planToReadCount: json['plan_to_read_count'],
      completedCount: json['completed_count'],
      favoriteCount: json['favorite_count'],
      chaptersReadCount: json['chapters_read_count'],
    );
  }
}
