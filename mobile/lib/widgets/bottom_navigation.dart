// mobile/lib/widgets/bottom_navigation.dart
import 'package:flutter/material.dart';
import 'package:mobile/screens/home_screen.dart';
import 'package:mobile/screens/reading_screen.dart';
import 'package:mobile/screens/bookmarks_screen.dart';
import 'package:mobile/screens/profile_screen.dart';

class BottomNavigation extends StatefulWidget {
  final int currentIndex;

  BottomNavigation({required this.currentIndex});

  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen(currentIndex: index)),
            );
            break;
          case 1:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ReadingScreen(currentIndex: index)),
            );
            break;
          case 2:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => BookmarksScreen(currentIndex: index)),
            );
            break;
          case 3:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen(currentIndex: index)),
            );
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Главная',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: 'Читаю',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bookmark),
          label: 'Закладки',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Профиль',
        ),
      ],
      unselectedItemColor: Colors.grey,
      selectedItemColor: Colors.white,
    );
  }
}
