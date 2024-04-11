import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/providers/manga_provider.dart';
import 'package:mobile/widgets/manga_card.dart';
import 'package:mobile/widgets/bottom_navigation.dart';

class HomeScreen extends StatefulWidget {
  final int currentIndex;

  HomeScreen({required this.currentIndex});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Provider.of<MangaProvider>(context, listen: false).fetchRecommendations();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      setState(() {
        _isSearching = false;
        _isLoading = false;
      });
      Provider.of<MangaProvider>(context, listen: false).clearSearchResults();
    }
  }

  void _startSearch() {
    String query = _searchController.text;
    if (query.isNotEmpty) {
      setState(() {
        _isSearching = true;
        _isLoading = true;
      });
      Provider.of<MangaProvider>(context, listen: false).searchManga(query).then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    } else {
      setState(() {
        _isSearching = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 32.0, 8.0, 0.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Поиск манги...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
                      filled: true,
                      fillColor: Colors.grey[800],
                      hintStyle: TextStyle(color: Colors.white70),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search, color: Colors.white),
                  onPressed: _startSearch,
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _isSearching
                ? Consumer<MangaProvider>(
              builder: (context, mangaProvider, child) {
                if (mangaProvider.searchResults.isEmpty && _searchController.text.isNotEmpty) {
                  return Center(child: Text('Ничего не найдено', style: TextStyle(color: Colors.white)));
                }
                return ListView.builder(
                  itemCount: mangaProvider.searchResults.length,
                  itemBuilder: (context, index) {
                    return MangaCard(manga: mangaProvider.searchResults[index]);
                  },
                );
              },
            )
                : Consumer<MangaProvider>(
              builder: (context, mangaProvider, child) {
                if (mangaProvider.recommendations.isEmpty) {
                  return Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  itemCount: mangaProvider.recommendations.length,
                  itemBuilder: (context, index) {
                    return MangaCard(manga: mangaProvider.recommendations[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigation(currentIndex: widget.currentIndex),
    );
  }
}
