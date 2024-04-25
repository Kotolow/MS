// lib/screens/bookmarks_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/providers/manga_provider.dart';
import 'package:mobile/widgets/manga_card.dart';
import 'package:mobile/widgets/bottom_navigation.dart';

class BookmarksScreen extends StatefulWidget {
  final int currentIndex;

  BookmarksScreen({required this.currentIndex});

  @override
  _BookmarksScreenState createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Provider.of<MangaProvider>(context, listen: false).fetchFavouriteList();
    Provider.of<MangaProvider>(context, listen: false).fetchPlanToReadList();
    Provider.of<MangaProvider>(context, listen: false).fetchReadList();
    Provider.of<MangaProvider>(context, listen: false).fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Закладки'),
        backgroundColor: Color(0xFF141218),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: Container(
            height: 48.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: _currentIndex == index
                            ? BorderSide(
                          color: Colors.white,
                          width: 2.0,
                        )
                            : BorderSide.none,
                      ),
                    ),
                    child: Text(
                      _getTitleFromIndex(index),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          _buildListView(0), // History
          _buildListView(1), // Favourite
          _buildListView(2), // Planning
          _buildListView(3), // Completed
        ],
      ),
      bottomNavigationBar: BottomNavigation(currentIndex: widget.currentIndex),
    );
  }

  String _getTitleFromIndex(int index) {
    switch (index) {
      case 0:
        return 'История';
      case 1:
        return 'Избранное';
      case 2:
        return 'В планах';
      case 3:
        return 'Прочитал';
      default:
        return '';
    }
  }

  Widget _buildListView(int index) {
    final mangaProvider = Provider.of<MangaProvider>(context);

    switch (index) {
      case 0:
        return ListView.builder(
          itemCount: mangaProvider.history.length,
          itemBuilder: (context, index) {
            return MangaCard(manga: mangaProvider.history[index]);
          },
        );
      case 1:
        return ListView.builder(
          itemCount: mangaProvider.favouriteList.length,
          itemBuilder: (context, index) {
            return MangaCard(manga: mangaProvider.favouriteList[index]);
          },
        );
      case 2:
        return ListView.builder(
          itemCount: mangaProvider.planToReadList.length,
          itemBuilder: (context, index) {
            return MangaCard(manga: mangaProvider.planToReadList[index]);
          },
        );
      case 3:
        return ListView.builder(
          itemCount: mangaProvider.readList.length,
          itemBuilder: (context, index) {
            return MangaCard(manga: mangaProvider.readList[index]);
          },
        );
      default:
        return Container();
    }
  }
}
