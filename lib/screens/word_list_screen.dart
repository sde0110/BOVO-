import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'main_screen.dart';
import 'search_screen.dart';

class WordListScreen extends StatefulWidget {
  const WordListScreen({Key? key}) : super(key: key);

  @override
  _WordListScreenState createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showAlphabetList = false;
  String? _expandedWord;
  String? _pressedLetter;
  Timer? _hideTimer;

  Map<String, List<Map<String, String>>> groupedWords = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadWords();
  }

  Future<void> _loadWords() async {
    String jsonString = await rootBundle.loadString('assets/words.json');
    Map<String, dynamic> jsonResponse = json.decode(jsonString);
    setState(() {
      groupedWords = jsonResponse.map((key, value) {
        return MapEntry(
          key,
          (value as List<dynamic>)
              .map((item) =>
                  Map<String, String>.from(item as Map<String, dynamic>))
              .toList(),
        );
      });
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  void _scrollListener() {
    setState(() {
      _showAlphabetList = true;
    });
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _showAlphabetList = false;
        });
      }
    });
  }

  void _scrollToLetter(String letter) {
    final keys = groupedWords.keys.toList();
    final index = keys.indexOf(letter);
    if (index != -1) {
      final itemHeight = 48.0; // 예상되는 각 항목의 평균 높이
      final targetPosition = index * itemHeight * 6; // 각 글자당 평균 5개의 단어가 있다고 가정
      _scrollController.animateTo(
        targetPosition,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }

    setState(() {
      _showAlphabetList = true;
      _pressedLetter = letter;
    });

    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showAlphabetList = false;
          _pressedLetter = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()),
              (Route<dynamic> route) => false,
            );
          },
        ),
        title: Text('단어 목록', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF8A7FBA),
        elevation: 0,
      ),
      body: Container(
        color: Color(0xFFF0F0FF), // 매우 연한 라벤더 색상
        child: Stack(
          children: [
            ListView.builder(
              controller: _scrollController,
              itemCount: groupedWords.length,
              itemBuilder: (context, index) {
                final letter = groupedWords.keys.elementAt(index);
                final words = groupedWords[letter]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      color: Color(0xFFD5D1EE), // 연한 라벤더 색상
                      child: Text(
                        letter,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF5D4777), // 진한 보라색
                        ),
                      ),
                    ),
                    ...words
                        .map((word) => CustomExpansionTile(
                              word: word['word']!,
                              definition: word['definition']!,
                              isExpanded: word['word'] == _expandedWord,
                              onExpansionChanged: (expanded) {
                                setState(() {
                                  _expandedWord =
                                      expanded ? word['word'] : null;
                                });
                              },
                            ))
                        .toList(),
                  ],
                );
              },
            ),
            if (_showAlphabetList)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 40,
                  decoration: BoxDecoration(
                    color: Color(0xFFB3ADE0).withOpacity(0.2), // 연한 푸른빛 보라색
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListView(
                    children: groupedWords.keys
                        .map((letter) => GestureDetector(
                              onTap: () => _scrollToLetter(letter),
                              child: Container(
                                height: 40,
                                alignment: Alignment.center,
                                child: Text(
                                  letter,
                                  style: TextStyle(
                                    color: _pressedLetter == letter
                                        ? Colors.white
                                        : Color(0xFF6A5495), // 중간 톤의 보라색
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  color: _pressedLetter == letter
                                      ? Color(0xFF8A7FBA) // 부드러운 푸른빛 보라색
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 3,
        backgroundColor: Color(0xFF8A7FBA), // 부드러운 푸른빛 보라색
        selectedItemColor: Colors.white,
        unselectedItemColor: Color(0xFFD5D1EE), // 연한 라벤더 색상
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: '단어찾기'),
          BottomNavigationBarItem(icon: Icon(Icons.flash_on), label: '오늘단어'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: '단어목록'),
        ],
        onTap: (index) {
          if (index != 3) {
            // 현재 페이지가 아닌 경우에만 네비게이션 실행
            Widget screen;
            switch (index) {
              case 0:
                screen = MainScreen();
                break;
              case 1:
                screen = SearchScreen();
                break;
              case 2:
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('준비 중입니다.'),
                    backgroundColor: Color(0xFF8A7FBA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
                return; // SnackBar를 보여주고 네비게이션은 하지 않음
              default:
                return; // 잘못된 인덱스인 경우 아무 것도 하지 않음
            }

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => screen),
              (Route<dynamic> route) => false,
            );
          }
        },
      ),
    );
  }
}

class CustomExpansionTile extends StatelessWidget {
  final String word;
  final String definition;
  final bool isExpanded;
  final ValueChanged<bool> onExpansionChanged;

  const CustomExpansionTile({
    Key? key,
    required this.word,
    required this.definition,
    required this.isExpanded,
    required this.onExpansionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: isExpanded ? 4 : 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white, // 카드 배경색을 흰색으로 설정
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              word,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D4777), // 진한 보라��
              ),
            ),
            trailing: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: Color(0xFF8A7FBA), // 부드러운 푸른빛 보라색
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
                    fontSize: 14, color: Color(0xFF6A5495)), // 중간 톤의 보라색
              ),
            ),
        ],
      ),
    );
  }
}
