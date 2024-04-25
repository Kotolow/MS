// mobile/lib/screens/manga_chapters_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/models/manga.dart';
import 'package:mobile/providers/manga_provider.dart';
import 'package:mobile/screens/manga_reader_screen.dart';

class MangaChaptersScreen extends StatefulWidget {
  final int mangaId;

  MangaChaptersScreen({required this.mangaId});

  @override
  _MangaChaptersScreenState createState() => _MangaChaptersScreenState();
}

class _MangaChaptersScreenState extends State<MangaChaptersScreen> {
  bool _isAscending = true;

  Future<void> _updateHistory(BuildContext context, int mangaId, int chapterId) async {
    try {
      await Provider.of<MangaProvider>(context, listen: false).updateHistory(mangaId, chapterId);
    } catch (e) {
      print('Failed to update history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mangaProvider = Provider.of<MangaProvider>(context, listen: false);
    final Manga? manga = mangaProvider.searchResults.firstWhere(
          (manga) => manga.id == widget.mangaId,
      orElse: () => mangaProvider.recommendations.firstWhere(
            (manga) => manga.id == widget.mangaId,
        orElse: () => mangaProvider.readingList.firstWhere(
              (manga) => manga.id == widget.mangaId,
          orElse: () => mangaProvider.history.firstWhere(
                  (manga) => manga.id == widget.mangaId,
            orElse: () => mangaProvider.favouriteList.firstWhere(
                    (manga) => manga.id == widget.mangaId,
              orElse: () => mangaProvider.planToReadList.firstWhere(
                      (manga) => manga.id == widget.mangaId,
                orElse: () => mangaProvider.readList.firstWhere(
                        (manga) => manga.id == widget.mangaId,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (manga == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF141218),
        ),
        body: Center(child: Text('Глав нет')),
      );
    }

    List<Chapter> chapters = manga.chapters;
    if (!_isAscending) {
      chapters = chapters.reversed.toList();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF141218),
        actions: [
          IconButton(
            icon: Icon(_isAscending ? Icons.arrow_downward : Icons.arrow_upward),
            onPressed: () {
              setState(() {
                _isAscending = !_isAscending;
              });
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: chapters.length,
        itemBuilder: (context, index) {
          final chapter = chapters[index];
          return ListTile(
            title: Text(chapter.title),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MangaReaderScreen(mangaId: manga.id, chapterId: chapter.chapterId),
                ),
              );
              _updateHistory(context, manga.id, chapter.chapterId);
            },
          );
        },
      ),
    );
  }
}