// mobile/lib/screens/genre_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/providers/registration_provider.dart';
import 'package:mobile/screens/login_screen.dart';

class GenreSelectionScreen extends StatefulWidget {
  @override
  _GenreSelectionScreenState createState() => _GenreSelectionScreenState();
}

class _GenreSelectionScreenState extends State<GenreSelectionScreen> {
  final List<String> _genres = [
    'приключения',
    'романтика',
    'боевик',
    'комедия',
    'этти',
    'школа',
    'сэйнэн',
    'сверхъестественное',
    'драма',
    'фэнтези',
    'сёнэн',
    'вампиры',
    'повседневность',
    'гарем',
    'героическое фэнтези',
    'боевые искусства',
    'психология',
    'сёдзё',
    'игра',
    'триллер',
    'детектив',
    'трагедия',
    'история',
    'спорт',
    'научная фантастика',
    'гендерная интрига',
    'дзёсэй',
    'ужасы',
    'постапокалиптика',
    'киберпанк',
    'меха',
    'эротика',
    'самурайский боевик',
    'махо-сёдзё',
    'додзинси',
    'кодомо',
    'исэкай',
    'сянься',
    'уся',
    'повседневность',
    'яой',
    'юри'
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RegistrationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Выберите жанры'),
        backgroundColor: Color(0xFF141218),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _genres.length,
              itemBuilder: (context, index) {
                final genre = _genres[index];
                return CheckboxListTile(
                  title: Text(genre),
                  value: provider.userGenres.contains(genre),
                  onChanged: (value) {
                    if (value != null) {
                      if (value) {
                        provider.addGenre(genre);
                      } else {
                        provider.removeGenre(genre);
                      }
                    }
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await provider.saveGenres();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ),
                );
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Не удалось сохранить жанры: $error'),
                  ),
                );
              }
            },
            child: Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}