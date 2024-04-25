import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/providers/manga_provider.dart';
import 'package:mobile/widgets/manga_card.dart';
import 'package:mobile/widgets/bottom_navigation.dart';

class ReadingScreen extends StatefulWidget {
  final int currentIndex;

  ReadingScreen({required this.currentIndex});

  @override
  _ReadingScreenState createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<MangaProvider>(context, listen: false).fetchReadingList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Читаю'),
        backgroundColor: Color(0xFF141218),
      ),
      body: Consumer<MangaProvider>(
        builder: (context, mangaProvider, child) {
          if (mangaProvider.readingList.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: mangaProvider.readingList.length,
            itemBuilder: (context, index) {
              return MangaCard(manga: mangaProvider.readingList[index]);
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigation(currentIndex: widget.currentIndex),
    );
  }
}
