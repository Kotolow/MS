// lib/models/manga.dart
class Manga {
  final int id;
  final String title;
  String description;
  String coverImageUrl; // изменяем final на обычное свойство
  int chaptersCount;
  String status;
  String genres;
  String year;
  List<Chapter> chapters;
  String userStatus;
  bool isFavourite;

  Manga({
    required this.id,
    required this.title,
    required this.description,
    required this.coverImageUrl,
    required this.chaptersCount,
    required this.status,
    required this.genres,
    required this.year,
    required this.chapters,
    required this.userStatus,
    required this.isFavourite
  });

  factory Manga.fromJson(Map<String, dynamic> json) {
    var chaptersJson = json['chapters'] as List? ?? [];
    List<Chapter> chaptersList = chaptersJson.map((i) => Chapter.fromJson(i)).toList();
    return Manga(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      coverImageUrl: json['cover'] ?? '',
      chaptersCount: json['chapters_count'] ?? 0,
      status: json['status'] ?? '',
      genres: json['genres'] ?? '',
      year: json['year'] ?? '',
      chapters: chaptersList,
      userStatus: 'not_reading',
      isFavourite: false
    );
  }
}

class Chapter {
  final int chapterId;
  final String url;
  final String title;

  Chapter({
    required this.chapterId,
    required this.url,
    required this.title,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      chapterId: json['chapter_id'],
      url: json['url'],
      title: json['title'],
    );
  }
}