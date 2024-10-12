import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'main_screen.dart';
import 'search_screen.dart';
import 'flash_card_start_screen.dart';
import 'mynote_screen.dart';
import 'package:bovo/utils/favorite_utils.dart';

// WordListScreen 위젯: 단어 목록을 표시하는 화면
class WordListScreen extends StatefulWidget {
  const WordListScreen({Key? key}) : super(key: key);

  @override
  _WordListScreenState createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _expandedWord;
  String? _pressedLetter;
  Map<String, double> _letterPositions = {};
  Map<String, GlobalKey> letterKeys = {};
  List<String> _favoriteWords = [];

  // 초성별로 그룹화된 단어 목록
  Map<String, List<Map<String, String>>> groupedWords = {};
  // 한글 초성 목록
  final List<String> _alphabet = [
    'ㄱ',
    'ㄴ',
    'ㄷ',
    'ㄹ',
    'ㅁ',
    'ㅂ',
    'ㅅ',
    'ㅇ',
    'ㅈ',
    'ㅊ',
    'ㅋ',
    'ㅌ',
    'ㅍ',
    'ㅎ'
  ];

  @override
  void initState() {
    super.initState();
    _loadWords();
    _initLetterKeys();
    _loadFavoriteWords();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateLetterPositions();
    });
  }

  void _initLetterKeys() {
    for (final letter in _alphabet) {
      letterKeys[letter] = GlobalKey();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadFavoriteWords() async {
    final words = await FavoriteUtils.getFavorites();
    setState(() {
      _favoriteWords = words;
    });
  }

  void _updateLetterPositions() {
    for (final letter in _alphabet) {
      final RenderBox? renderBox = _getLetterRenderBox(letter);
      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero);
        _letterPositions[letter] = position.dy;
      }
    }
  }

  RenderBox? _getLetterRenderBox(String letter) {
    final context = letterKeys[letter]?.currentContext;
    return context?.findRenderObject() as RenderBox?;
  }

  void _scrollToLetter(String letter) {
    _updateLetterPositions();
    final targetPosition = _letterPositions[letter];
    if (targetPosition != null) {
      _scrollController.animateTo(
        targetPosition - MediaQuery.of(context).padding.top,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    setState(() {
      _pressedLetter = letter;
    });

    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _pressedLetter = null;
        });
      }
    });
  }

  // JSON 파일에서 단어 데이터를 로드하는 메서드
  Future<void> _loadWords() async {
    try {
      String jsonString = await rootBundle.loadString('assets/words.json');
      Map<String, dynamic> jsonResponse = json.decode(jsonString);
      List<Map<String, String>> allWords = [];

      // JSON 데이터에서 단어와 정의를 추출
      jsonResponse['categories'].forEach((category) {
        category['words'].forEach((word) {
          allWords.add({
            'word': word['word'],
            'definition': word['definition'],
          });
        });
      });

      // 단어를 알파벳 순으로 정렬
      allWords.sort((a, b) => a['word']!.compareTo(b['word']!));

      setState(() {
        // 초성별로 단어 그룹화
        groupedWords = _groupWordsByInitial(allWords);
      });
      print('단어 로드 완료: ${groupedWords.length} 그룹, ${allWords.length} 단어');
    } catch (e) {
      print('단어 로드 중 오류 발생: $e');
    }
  }

  // 단어를 초성별로 그룹화하는 메서드
  Map<String, List<Map<String, String>>> _groupWordsByInitial(
      List<Map<String, String>> words) {
    Map<String, List<Map<String, String>>> grouped = {};
    for (var word in words) {
      String initial = _getInitialConsonant(word['word']!);
      if (!grouped.containsKey(initial)) {
        grouped[initial] = [];
      }
      grouped[initial]!.add(word);
    }
    return grouped;
  }

  // 단어의 초성을 반환하는 메서드
  String _getInitialConsonant(String word) {
    final initialConsonants = [
      'ㄱ',
      'ㄲ',
      'ㄴ',
      'ㄷ',
      'ㄸ',
      'ㄹ',
      'ㅁ',
      'ㅂ',
      'ㅃ',
      'ㅅ',
      'ㅆ',
      'ㅇ',
      'ㅈ',
      'ㅉ',
      'ㅊ',
      'ㅋ',
      'ㅌ',
      'ㅍ',
      'ㅎ'
    ];
    if (word.isEmpty) return 'ㄱ';
    int code = word.codeUnitAt(0);
    if (code >= 0xAC00 && code <= 0xD7A3) {
      int index = ((code - 0xAC00) ~/ 28 ~/ 21);
      return initialConsonants[index];
    } else {
      return 'ㄱ';
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
          '',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        color: Color(0xFF1E3859),
        child: Stack(
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollEndNotification) {
                  _updateLetterPositions();
                }
                return true;
              },
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _alphabet.length,
                itemBuilder: (context, index) {
                  final letter = _alphabet[index];
                  final words = groupedWords[letter] ?? [];
                  return Column(
                    key: letterKeys[letter],
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        color: Colors.white.withOpacity(0.1),
                        child: Text(
                          letter,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (words.isNotEmpty)
                        ...words.map((word) => CustomExpansionTile(
                              word: word['word']!,
                              definition: word['definition']!,
                              isExpanded: word['word'] == _expandedWord,
                              isFavorite: _favoriteWords.contains(word['word']),
                              onExpansionChanged: (expanded) {
                                setState(() {
                                  _expandedWord =
                                      expanded ? word['word'] : null;
                                });
                              },
                              onFavoriteChanged: () async {
                                await FavoriteUtils.toggleFavorite(
                                    word['word']!);
                                await _loadFavoriteWords();
                              },
                            )),
                    ],
                  );
                },
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 40,
                decoration: BoxDecoration(
                  color: Color(0xFF1E3859).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ListView(
                  children: _alphabet
                      .map((letter) => GestureDetector(
                            onTap: () => _scrollToLetter(letter),
                            child: Container(
                              height: 40,
                              alignment: Alignment.center,
                              child: Text(
                                letter,
                                style: TextStyle(
                                  color: _pressedLetter == letter
                                      ? Color(0xFF1E3859)
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: _pressedLetter == letter
                                    ? Colors.white.withOpacity(0.8)
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
      // 하단 네비게이션 바
      bottomNavigationBar: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
            _buildNavBarItem(
                'assets/Icon/search_navi.png',
                '검색',
                () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => SearchScreen()))),
            _buildNavBarItem('assets/Icon/word_list.png', '단어목록', null),
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
            color: label == '단어목록'
                ? Color(0xFF1E3859)
                : Color(0xFF1E3859).withOpacity(0.5),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: label == '단어목록'
                  ? Color(0xFF1E3859)
                  : Color(0xFF1E3859).withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// CustomExpansionTile 위젯: 확장 가능한 단어 타일
class CustomExpansionTile extends StatelessWidget {
  final String word;
  final String definition;
  final bool isExpanded;
  final bool isFavorite;
  final ValueChanged<bool> onExpansionChanged;
  final VoidCallback onFavoriteChanged;

  const CustomExpansionTile({
    Key? key,
    required this.word,
    required this.definition,
    required this.isExpanded,
    required this.isFavorite,
    required this.onExpansionChanged,
    required this.onFavoriteChanged,
  }) : super(key: key);

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
                    color: isFavorite ? Colors.yellow : Colors.grey,
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
                style: TextStyle(fontSize: 14, color: Color(0xFF1E3859)),
              ),
            ),
        ],
      ),
    );
  }
}
