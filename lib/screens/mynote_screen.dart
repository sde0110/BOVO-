import 'package:flutter/material.dart';
import 'main_screen.dart';
import 'search_screen.dart';
import 'word_list_screen.dart';
import 'flash_card_start_screen.dart';

import 'package:flutter/material.dart';
import 'package:bovo/utils/favorite_utils.dart';
import 'package:bovo/utils/wrong_answer_utils.dart';

class MyNoteScreen extends StatefulWidget {
  const MyNoteScreen({Key? key}) : super(key: key);

  @override
  _MyNoteScreenState createState() => _MyNoteScreenState();
}

class _MyNoteScreenState extends State<MyNoteScreen>
    with SingleTickerProviderStateMixin {
  List<String> _favoriteWords = [];
  Map<int, List<Map<String, String>>> _wrongAnswersByRound = {};
  bool _showFavorites = true;
  final WrongAnswerUtils wrongAnswerUtils = WrongAnswerUtils();
  late TabController _tabController;
  String? _expandedWord;

  @override
  void initState() {
    super.initState();
    _loadFavoriteWords();
    _loadWrongAnswers();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _loadFavoriteWords() async {
    final words = await FavoriteUtils.getFavorites();
    setState(() {
      _favoriteWords = words;
    });
  }

  Future<void> _loadWrongAnswers() async {
    try {
      final wrongAnswers = await wrongAnswerUtils.getWrongAnswersByRound();
      setState(() {
        _wrongAnswersByRound = wrongAnswers;
      });
      print('로드된 오답: $_wrongAnswersByRound'); // 디버깅용 출력
    } catch (e) {
      print('오답 로드 중 오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1E3859),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => MainScreen()),
            );
          },
        ),
        title: Text(
          '단어장',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Color.fromARGB(191, 255, 255, 255), // 선택된 탭의 글자색
          unselectedLabelColor:
              Color(0xFF215BA6).withOpacity(0.7), // 선택되지 않은 탭의 글자색
          tabs: [
            Tab(text: '즐겨찾기'),
            Tab(text: '오답 노트'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFavoritesList(),
          _buildWrongAnswersList(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildFavoritesList() {
    return Container(
      color: Colors.white,
      child: _favoriteWords.isEmpty
          ? Center(
              child: Text(
                '즐겨찾기한 단어가 없습니다.',
                style: TextStyle(color: Color(0xFF1E3859), fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: _favoriteWords.length,
              itemBuilder: (context, index) {
                final word = _favoriteWords[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Color(0xFF1E3859), width: 1),
                  ),
                  child: ListTile(
                    title: Text(
                      word,
                      style: TextStyle(
                        color: Color(0xFF1E3859),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.star, color: Color(0xFF1E3859)),
                      onPressed: () async {
                        await FavoriteUtils.toggleFavorite(word);
                        await _loadFavoriteWords();
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildWrongAnswersList() {
    return Container(
      color: Colors.white,
      child: _wrongAnswersByRound.isEmpty
          ? Center(
              child: Text(
                '오답이 없습니다.',
                style: TextStyle(color: Color(0xFF1E3859), fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: _wrongAnswersByRound.length,
              itemBuilder: (context, index) {
                int round = _wrongAnswersByRound.keys.toList()[index];
                List<Map<String, String>> wrongAnswers =
                    _wrongAnswersByRound[round]!;
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Color(0xFF1E3859), width: 1),
                  ),
                  child: ExpansionTile(
                    title: Text(
                      '회차 $round',
                      style: TextStyle(
                        color: Color(0xFF1E3859),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    children: wrongAnswers
                        .map((wrongAnswer) => ListTile(
                              title: Text(
                                wrongAnswer['word'] ?? '',
                                style: TextStyle(color: Color(0xFF1E3859)),
                              ),
                              subtitle: Text(
                                wrongAnswer['definition'] ?? '',
                                style: TextStyle(
                                    color: Color(0xFF1E3859).withOpacity(0.7)),
                              ),
                            ))
                        .toList(),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildBottomNavigationBar() {
    // 기존 네비게이션 바 코드를 그대로 유지
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
          _buildNavBarItem(context, 'assets/Icon/home.png', '홈', () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => MainScreen()));
          }),
          _buildNavBarItem(context, 'assets/Icon/search_navi.png', '검색', () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => SearchScreen()));
          }),
          _buildNavBarItem(context, 'assets/Icon/word_list.png', '단어목록', () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => WordListScreen()));
          }),
          _buildNavBarItem(context, 'assets/Icon/today_word.png', '오늘단어', () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => FlashCardStartScreen()));
          }),
          _buildNavBarItem(context, 'assets/Icon/mynote.png', '단어장', null),
        ],
      ),
    );
  }
}

Widget _buildNavBarItem(
    BuildContext context, String iconPath, String label, VoidCallback? onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          iconPath,
          width: 24,
          height: 24,
          color: label == '단어장'
              ? Color(0xFF1E3859)
              : Color(0xFF1E3859).withOpacity(0.5),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: label == '단어장'
                ? Color(0xFF1E3859)
                : Color(0xFF1E3859).withOpacity(0.5),
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}

class CustomExpansionTile extends StatelessWidget {
  final String word;
  final String definition;
  final bool isExpanded;
  final bool isFavorite;
  final ValueChanged<bool>
      onExpansionChanged; // VoidCallback에서 ValueChanged<bool>로 변경
  final VoidCallback onFavoriteChanged;

  const CustomExpansionTile({
    required this.word,
    required this.definition,
    required this.isExpanded,
    required this.isFavorite,
    required this.onExpansionChanged,
    required this.onFavoriteChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: isExpanded ? 4 : 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              word,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3859),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.star : Icons.star_border,
                    color: isFavorite
                        ? Color(0xFFFFD700)
                        : Color(0xFF1E3859).withOpacity(0.5),
                  ),
                  onPressed: onFavoriteChanged,
                ),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Color(0xFF1E3859),
                ),
              ],
            ),
            onTap: () => onExpansionChanged(!isExpanded),
          ),
          if (isExpanded)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                definition,
                style: TextStyle(
                    fontSize: 14, color: Color(0xFF1E3859).withOpacity(0.8)),
              ),
            ),
        ],
      ),
    );
  }
}
