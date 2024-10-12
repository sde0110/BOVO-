import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bovo/word_data.dart';
import 'main_screen.dart';
import 'word_detail_screen.dart';
import 'flash_card_start_screen.dart';
import 'word_list_screen.dart';
import 'mynote_screen.dart';
import 'package:bovo/utils/favorite_utils.dart';

// SearchScreen: 단어 검색 기능을 제공하는 화면
class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allWords = [];
  List<Map<String, dynamic>> _filteredWords = [];
  List<String> _recentSearches = [];
  bool _isSearching = false;
  Set<String> _favorites = <String>{};

  final Color primaryColor = Color(0xFF1E3859);

  @override
  void initState() {
    super.initState();
    _loadWords();
    _loadRecentSearches();
    _loadFavorites();
  }

  // 모든 단어 데이터 로드
  Future<void> _loadWords() async {
    await WordData.loadWords();
    setState(() {
      _allWords = WordData.getAllWords();
    });
  }

  // 최근 검색어 로드
  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recentSearches') ?? [];
    });
  }

  // 최근 검색어 저장 (최대 3개)
  Future<void> _saveRecentSearch(String search) async {
    if (!_recentSearches.contains(search)) {
      _recentSearches.insert(0, search);
      if (_recentSearches.length > 3) {
        _recentSearches.removeLast();
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('recentSearches', _recentSearches);
    }
  }

  // 검색어에 따라 단어 필터링 (중복 제거 로직 추가)
  void _filterSearchResults(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      if (_isSearching) {
        Set<String> uniqueWords = {}; // 중복 제거를 위한 Set
        _filteredWords = _allWords
            .where((word) =>
                word['word']!.toLowerCase().contains(query.toLowerCase()))
            .where((word) => uniqueWords.add(word['word']!)) // 중복 단어 제거
            .toList();
      } else {
        _filteredWords = [];
      }
    });
  }

  // 검색 결과 위젯 생성
  Widget _buildSearchResults() {
    if (_filteredWords.isEmpty) {
      return SizedBox();
    }
    return ListView.builder(
      itemCount: _filteredWords.length,
      itemBuilder: (context, index) {
        final word = _filteredWords[index];
        final wordText = word['word']!;
        final query = _searchController.text.toLowerCase();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: primaryColor),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              title: RichText(
                text: TextSpan(
                  style: TextStyle(color: primaryColor, fontSize: 16),
                  children: _buildTextSpans(wordText, query),
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      _favorites.contains(wordText)
                          ? Icons.star
                          : Icons.star_border,
                      color: _favorites.contains(wordText)
                          ? Colors.amber
                          : primaryColor,
                    ),
                    onPressed: () => _toggleFavorite(wordText),
                  ),
                  Icon(Icons.arrow_forward_ios, color: primaryColor, size: 18),
                ],
              ),
              onTap: () {
                _saveRecentSearch(wordText);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WordDetailScreen(word: word),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // 검색어 하이라이트를 위한 TextSpan 생성
  List<TextSpan> _buildTextSpans(String text, String query) {
    List<TextSpan> spans = [];
    int start = 0;
    final matches = query.allMatches(text.toLowerCase());
    for (final match in matches) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }
      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
      ));
      start = match.end;
    }
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }
    return spans;
  }

  // 최근 검색어 목록 위젯 생성
  Widget _buildRecentSearches() {
    return _recentSearches.isEmpty
        ? _buildLogoSection()
        : ListView.builder(
            itemCount: _recentSearches.length,
            itemBuilder: (context, index) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: primaryColor),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Icon(Icons.history, color: primaryColor),
                    title: Text(_recentSearches[index],
                        style: TextStyle(color: primaryColor)),
                    trailing: Icon(Icons.arrow_forward_ios,
                        color: primaryColor, size: 18),
                    onTap: () {
                      _searchController.text = _recentSearches[index];
                      _filterSearchResults(_recentSearches[index]);
                    },
                  ),
                ),
              );
            },
          );
  }

  // 로고 섹션 위젯 생성
  Widget _buildLogoSection() {
    return Center(
      child: Image.asset(
        'assets/Icon/logo.png',
        width: MediaQuery.of(context).size.width * 0.7, // 로고 크기 조절
      ),
    );
  }

  // 검색어 초기화
  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _isSearching = false;
      _filteredWords = [];
    });
  }

  Future<void> _loadFavorites() async {
    final favorites = await FavoriteUtils.getFavorites();
    setState(() {
      _favorites = Set<String>.from(favorites);
    });
  }

  Future<void> _toggleFavorite(String word) async {
    await FavoriteUtils.toggleFavorite(word);
    await _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // 아이콘 색상을 흰색으로 변경
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(''),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '검색어를 입력하세요',
                hintStyle: TextStyle(color: primaryColor.withOpacity(0.6)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: primaryColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: primaryColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
                prefixIcon: Icon(Icons.search, color: primaryColor),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear, color: primaryColor),
                  onPressed: _clearSearch,
                ),
              ),
              style: TextStyle(color: primaryColor),
              onChanged: _filterSearchResults,
              onSubmitted: (value) {
                _filterSearchResults(value);
              },
            ),
          ),
          if (_isSearching && _filteredWords.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '검색 결과가 없습니다.',
                style: TextStyle(fontSize: 16, color: primaryColor),
              ),
            ),
          Expanded(
            child:
                _isSearching ? _buildSearchResults() : _buildRecentSearches(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavBarItem(
              'assets/Icon/home.png',
              '홈',
              () => Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => MainScreen()))),
          _buildNavBarItem('assets/Icon/search_navi.png', '검색', null),
          _buildNavBarItem(
              'assets/Icon/word_list.png',
              '단어목록',
              () => Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => WordListScreen()))),
          _buildNavBarItem(
              'assets/Icon/today_word.png',
              '오늘단어',
              () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FlashCardStartScreen()))),
          _buildNavBarItem(
              'assets/Icon/mynote.png',
              '단어장',
              () => Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => MyNoteScreen()))),
        ],
      ),
    );
  }

  Widget _buildNavBarItem(String iconPath, String label, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            iconPath,
            width: 24,
            height: 24,
            color: label == '검색' ? primaryColor : primaryColor.withOpacity(0.5),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color:
                  label == '검색' ? primaryColor : primaryColor.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
