import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/models/manga.dart';
import 'package:mobile/providers/manga_provider.dart';
import 'package:mobile/screens/manga_chapters_screen.dart';

class MangaDetailScreen extends StatefulWidget {
  final int mangaId;

  MangaDetailScreen({required this.mangaId});

  @override
  _MangaDetailScreenState createState() => _MangaDetailScreenState();
}

class _MangaDetailScreenState extends State<MangaDetailScreen> {
  late Future<Manga?> _mangaDetailsFuture;
  bool isFavorite = false;
  String selectedStatus = 'not_reading';

  final Map<String, String> statusMap = {
    'not_reading': 'Не читаю',
    'reading': 'Читаю',
    'plan_to_read': 'В планах',
    'completed': 'Прочитано'
  };

  @override
  void initState() {
    super.initState();
    _mangaDetailsFuture = Provider.of<MangaProvider>(context, listen: false).fetchMangaDetails(widget.mangaId);
  }

  Future<void> _updateMangaStatus(BuildContext context, int mangaId, bool isFavorite, String status) async {
    try {
      await Provider.of<MangaProvider>(context, listen: false).updateMangaStatus(mangaId, isFavorite, status);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Статус обновлен')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Не удалось обновить статус')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF141218),
      ),
      body: FutureBuilder<Manga?>(
        future: _mangaDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load manga details'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No data available'));
          } else {
            final Manga manga = snapshot.data!;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: AspectRatio(
                          aspectRatio: 3 / 2,
                          child: Image.network(
                            manga.coverImageUrl,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            manga.title,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              DropdownButton<String>(
                                value: manga.userStatus,
                                iconSize: 30,
                                elevation: 16,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    manga.userStatus = newValue!;
                                  });
                                  _updateMangaStatus(context, manga.id, manga.isFavourite, manga.userStatus);
                                },
                                items: statusMap.entries.map<DropdownMenuItem<String>>((entry) {
                                  return DropdownMenuItem<String>(
                                    value: entry.key,
                                    child: Text(entry.value),
                                  );
                                }).toList(),
                              ),
                              SizedBox(width: 8.0),
                              IconButton(
                                icon: Icon(
                                  Icons.favorite,
                                  color: manga.isFavourite ? Colors.yellow : Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    manga.isFavourite = !manga.isFavourite;
                                  });
                                  _updateMangaStatus(context, manga.id, manga.isFavourite, manga.userStatus);
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.0),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MangaChaptersScreen(mangaId: manga.id),
                                ),
                              );
                            },
                            icon: Icon(Icons.book, color: Colors.black),
                            label: Text('Читать', style: TextStyle(color: Colors.black)),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 80.0, vertical: 16.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ).copyWith(
                              backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                                if (states.contains(MaterialState.pressed)) {
                                  return Colors.grey;
                                }
                                return Colors.white;
                              }),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.0),
                        Divider(),
                        Row(
                          children: [
                            Icon(Icons.library_books, size: 20),
                            SizedBox(width: 8.0),
                            Text(
                              'Глав: ',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
                            ),
                            Text(
                              '${manga.chaptersCount}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 14.0),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.0),
                        Row(
                          children: [
                            Icon(Icons.check_circle, size: 20),
                            SizedBox(width: 8.0),
                            Text(
                              'Статус: ',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
                            ),
                            Text(
                              '${manga.status}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 14.0),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.0),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.category, size: 20),
                            SizedBox(width: 8.0),
                            Text(
                              'Жанр: ',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
                            ),
                            Expanded(
                              child: Text(
                                '${manga.genres}',
                                style: TextStyle(fontSize: 14.0),
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.0),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 20),
                            SizedBox(width: 8.0),
                            Text(
                              'Год: ',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
                            ),
                            Text(
                              '${manga.year}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 14.0),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Описание:',
                          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                        ),
                        Text(manga.description),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
