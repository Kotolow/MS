import 'package:flutter/material.dart';
import 'package:mobile/services/api_service.dart';
import 'dart:convert';
import 'package:mobile/models/manga.dart';
import 'package:provider/provider.dart';
import 'package:mobile/providers/manga_provider.dart';

class MangaReaderScreen extends StatefulWidget {
  final int mangaId;
  final int chapterId;

  MangaReaderScreen({required this.mangaId, required this.chapterId});

  @override
  _MangaReaderScreenState createState() => _MangaReaderScreenState();
}

class _MangaReaderScreenState extends State<MangaReaderScreen> {
  late Future<List<MangaPage>> _mangaPagesFuture;
  bool _isVerticalScroll = false;
  bool _isGridView = false;
  PageController _pageController = PageController();
  int _currentPage = 0;
  List<Chapter> _chapters = [];
  Manga? _manga;
  List<ScrollController> _scrollControllers = [];

  @override
  void initState() {
    super.initState();
    _loadMangaData();
  }

  Future<void> _loadMangaData() async {
    final mangaProvider = Provider.of<MangaProvider>(context, listen: false);
    _manga = mangaProvider.searchResults.firstWhere(
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
                        (manga) => manga.id == widget.mangaId
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (_manga != null) {
      _chapters = _manga!.chapters;
    }

    _mangaPagesFuture = _fetchMangaPages(widget.chapterId);
  }

  Future<List<MangaPage>> _fetchMangaPages(int chapterId) async {
    final response = await ApiService().fetchChapterImages(widget.mangaId, chapterId);
    final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
    return jsonList.map((json) => MangaPage.fromJson(json)).toList();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _navigateToPreviousChapter() {
    int currentChapterIndex = _chapters.indexWhere((chapter) => chapter.chapterId == widget.chapterId);
    if (currentChapterIndex > 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MangaReaderScreen(
            mangaId: widget.mangaId,
            chapterId: _chapters[currentChapterIndex - 1].chapterId,
          ),
        ),
      );
    } else {
      _showMessage("Первая глава");
    }
  }

  void _navigateToNextChapter() {
    int currentChapterIndex = _chapters.indexWhere((chapter) => chapter.chapterId == widget.chapterId);
    if (currentChapterIndex < _chapters.length - 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MangaReaderScreen(
            mangaId: widget.mangaId,
            chapterId: _chapters[currentChapterIndex + 1].chapterId,
          ),
        ),
      );
    } else {
      _showMessage("Последняя глава");
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _toggleGridView() {
    setState(() {
      _isGridView = !_isGridView;
      if (!_isGridView) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _pageController.jumpToPage(_currentPage);
          }
        });
      }
    });
  }

  void _onPageSelected(int index) {
    setState(() {
      _isGridView = false;
      _currentPage = index;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _pageController.jumpToPage(index);
      }
    });
  }

  void _scrollListener(int index) {
    if (_scrollControllers[index].offset >= _scrollControllers[index].position.maxScrollExtent &&
        !_scrollControllers[index].position.outOfRange) {
      if (_currentPage < _scrollControllers.length - 1) {
        _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      } else {
        _navigateToNextChapter();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF141218),
        actions: [
          IconButton(
            icon: Icon(Icons.grid_view),
            onPressed: _toggleGridView,
          ),
          IconButton(
            icon: Icon(_isVerticalScroll ? Icons.swap_horiz : Icons.swap_vert),
            onPressed: () {
              setState(() {
                _isVerticalScroll = !_isVerticalScroll;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _pageController.jumpToPage(_currentPage);
                  }
                });
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<MangaPage>>(
        future: _mangaPagesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load manga pages'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Данной главы нет'));
          } else {
            final pages = snapshot.data!;
            _scrollControllers = List.generate(pages.length, (index) {
              ScrollController controller = ScrollController();
              controller.addListener(() => _scrollListener(index));
              return controller;
            });
            if (_isGridView) {
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                ),
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _onPageSelected(index),
                    child: Stack(
                      children: [
                        Image.network(pages[index].src, fit: BoxFit.cover),
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Container(
                            color: Colors.black54,
                            padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
            return Stack(
              children: [
                _isVerticalScroll
                    ? PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: pages.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return SingleChildScrollView(
                      controller: _scrollControllers[index],
                      child: Center(
                        child: Image.network(pages[index].src),
                      ),
                    );
                  },
                )
                    : GestureDetector(
                  onTapUp: (details) {
                    final screenWidth = MediaQuery.of(context).size.width;
                    if (details.globalPosition.dx > screenWidth / 2) {
                      if (_currentPage < pages.length - 1) {
                        _pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _navigateToNextChapter();
                      }
                    } else {
                      if (_currentPage > 0) {
                        _pageController.previousPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _navigateToPreviousChapter();
                      }
                    }
                  },
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: pages.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return SingleChildScrollView(
                        controller: _scrollControllers[index],
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 0.0),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: MediaQuery.of(context).size.height - 60,
                                minWidth: MediaQuery.of(context).size.width,
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                child: Image.network(
                                  pages[index].src,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    color: Colors.grey.withOpacity(0.5),
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Text(
                      '${pages[_currentPage].title}/${pages.length}',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

class MangaPage {
  final String src;
  final String dataNumber;
  final String title;

  MangaPage({
    required this.src,
    required this.dataNumber,
    required this.title,
  });

  factory MangaPage.fromJson(Map<String, dynamic> json) {
    return MangaPage(
      src: json['src'],
      dataNumber: json['data-number'],
      title: json['title'],
    );
  }
}
