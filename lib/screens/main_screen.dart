import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'search_screen.dart';
import 'word_list_screen.dart';
import 'flash_card_start_screen.dart';
import 'mynote_screen.dart'; // mynote_screen.dart import

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Map<String, dynamic>> words = [];
  int currentWordIndex = 0;
  bool showMeaning = false;
  bool isLoading = true;
  late PageController _pageController;
  bool _isSearchPressed = false;
  bool _isWordListPressed = false;
  bool _isMyNotePressed = false;

  @override
  void initState() {
    super.initState();
    loadWords();
    _pageController = PageController(
      initialPage: 0,
      viewportFraction: 1.0,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> loadWords() async {
    try {
      final String response = await rootBundle.loadString('assets/words.json');
      final data = await json.decode(response);
      setState(() {
        words = [];
        for (var category in data['categories']) {
          words.addAll(List<Map<String, dynamic>>.from(category['words']));
        }
        words.shuffle();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading words: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E3859),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildTodayWordCard(),
              SizedBox(height: 16),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildSearchCard(),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          Expanded(child: _buildWordListCard()),
                          SizedBox(height: 16),
                          Expanded(child: _buildMyNoteCard()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildTodayWordCard() {
    if (isLoading) {
      return _buildCardContainer(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (words.isEmpty) {
      return _buildCardContainer(
        child: Center(child: Text('단어를 불러올 수 없습니다.')),
      );
    }

    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(left: 16, top: 16, right: 16),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFF1E3859), width: 2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '오늘 학습할 단어',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3859),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! > 0 && currentWordIndex > 0) {
                  // 오른쪽으로 스와이프
                  _pageController.previousPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else if (details.primaryVelocity! < 0 &&
                    currentWordIndex < 3) {
                  // 왼쪽으로 스와이프
                  _pageController.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: PageView.builder(
                controller: _pageController,
                itemCount: 4, // 3개의 단어 + 추가학습하기 버튼
                onPageChanged: (index) {
                  setState(() {
                    currentWordIndex = index;
                    showMeaning = false;
                  });
                },
                itemBuilder: (context, index) {
                  if (index == 3) {
                    return _buildAdditionalLearningCard();
                  }
                  return _buildWordCard(words[index]);
                },
                physics: NeverScrollableScrollPhysics(), // 스크롤 물리 효과 비활성화
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContainer({required Widget child}) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }

  Widget _buildWordCard(Map<String, dynamic> word) {
    String wordText = word['word']?.toString() ?? '단어 없음';
    String definitionText = word['definition']?.toString() ?? '정의 없음';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              wordText,
              style: TextStyle(
                fontSize: 24, // 글자 크기를 28에서 24로 줄임
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3859),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Container(
              height: 1,
              width: 100,
              color: Color(0xFF1E3859).withOpacity(0.3),
            ),
            SizedBox(height: 16),
            Expanded(
              // Expanded 위젯 추가
              child: SingleChildScrollView(
                // 스크롤 가능하도록 SingleChildScrollView 추가
                child: Text(
                  definitionText,
                  style: TextStyle(
                    fontSize: 16, // 글자 크기를 18에서 16으로 줄임
                    color: Color(0xFF1E3859),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalLearningCard() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1E3859),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FlashCardStartScreen()),
            );
          },
          child: Center(
            child: Text(
              '단어 더보기',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCard({
    required Widget child,
    required VoidCallback onTap,
    required bool isPressed,
  }) {
    return GestureDetector(
      onTapDown: (_) => setState(() => isPressed = true),
      onTapUp: (_) {
        setState(() => isPressed = false);
        onTap();
      },
      onTapCancel: () => setState(() => isPressed = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        transform:
            isPressed ? Matrix4.identity().scaled(0.95) : Matrix4.identity(),
        child: child,
      ),
    );
  }

  Widget _buildSearchCard() {
    return _buildAnimatedCard(
      isPressed: _isSearchPressed,
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SearchScreen()));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('단어찾기',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3859))),
            Text('Search',
                style: TextStyle(fontSize: 18, color: Color(0xFF1E3859))),
            SizedBox(height: 20),
            Image.asset('assets/Icon/search.png', width: 50, height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildWordListCard() {
    return _buildAnimatedCard(
      isPressed: _isWordListPressed,
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => WordListScreen()));
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('단어목록',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3859))),
            Text('Word List',
                style: TextStyle(fontSize: 14, color: Color(0xFF1E3859))),
            SizedBox(height: 10),
            Image.asset('assets/Icon/wordlist.png', width: 50, height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildMyNoteCard() {
    return _buildAnimatedCard(
      isPressed: _isMyNotePressed,
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => MyNoteScreen()));
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('단어장',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3859))),
            Text('My Note',
                style: TextStyle(fontSize: 14, color: Color(0xFF1E3859))),
            SizedBox(height: 10),
            Image.asset('assets/Icon/my_note.png', width: 50, height: 50),
          ],
        ),
      ),
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
          _buildNavBarItem('assets/Icon/home.png', '홈', null),
          _buildNavBarItem(
              'assets/Icon/search_navi.png',
              '검색',
              () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SearchScreen()))),
          _buildNavBarItem(
              'assets/Icon/word_list.png',
              '단어목록',
              () => Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => WordListScreen()))),
          _buildNavBarItem(
              'assets/Icon/today_word.png',
              '오늘단어',
              () => Navigator.push(
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
          color: label == '홈'
              ? Color(0xFF1E3859)
              : Color(0xFF1E3859).withOpacity(0.5),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: label == '홈'
                ? Color(0xFF1E3859)
                : Color(0xFF1E3859).withOpacity(0.5),
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}

Widget _buildButton(String text, IconData icon, VoidCallback onPressed) {
  return Container(
    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          spreadRadius: 1,
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1E3859),
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  );
}
