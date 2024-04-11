// lib/widgets/manga_card.dart
import 'package:flutter/material.dart';
import 'package:mobile/models/manga.dart';
import 'package:mobile/screens/manga_detail_screen.dart';

class MangaCard extends StatelessWidget {
  final Manga manga;

  MangaCard({required this.manga});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MangaDetailScreen(mangaId: manga.id),
          ),
        );
      },
      child: Card(
        color: Colors.grey[850],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              (manga.coverImageUrl.isNotEmpty && !manga.coverImageUrl.startsWith('image'))
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(
                  manga.coverImageUrl,
                  height: 100.0,
                  width: 70.0,
                  fit: BoxFit.cover,
                ),
              )
                  : Container(
                height: 100.0,
                width: 70.0,
                color: Colors.grey,
                child: Center(child: Text('No Image', style: TextStyle(color: Colors.white))),
              ),
              SizedBox(width: 10.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      manga.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      manga.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14.0, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
