import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'main_screen.dart';
import 'search_screen.dart';
import 'flash_card_start_screen.dart';

class WordListScreen extends StatefulWidget {
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
  final List<String> _alphabet = [
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

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadWords();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadWords() async {
    try {
      String jsonString = await rootBundle.loadString('assets/words.json');
      Map<String, dynamic> jsonResponse = json.decode(jsonString);
      List<Map<String, String>> allWords = [];
      List<dynamic> categories = jsonResponse['categories'];
      for (var category in categories) {
        List<dynamic> words = category['words'];
        allWords.addAll(words.map((word) => {
              'word': word['word'] as String,
              'definition': word['definition'] as String,
            }));
      }
      allWords.sort((a, b) => a['word']!.compareTo(b['word']!));
      setState(() {
        groupedWords = _groupWordsByInitial(allWords);
      });
      print('단어 로드 완료: ${groupedWords.length} 그룹');
    } catch (e) {
      print('단어 로드 중 오류 발생: $e');
    }
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
    setState(() {
      _pressedLetter = letter;
    });

    if (groupedWords.containsKey(letter)) {
      final keys = groupedWords.keys.toList();
      final index = keys.indexOf(letter);
      final itemHeight = 60.0; // 예상되는 각 그룹의 평균 높이
      final targetPosition = index * itemHeight;
      _scrollController.animateTo(
        targetPosition,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }

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

  RenderBox? _getItemRenderBox(int index) {
    final context = _getItemContext(index);
    if (context != null) {
      return context.findRenderObject() as RenderBox?;
    }
    return null;
  }

  BuildContext? _getItemContext(int index) {
    final key = GlobalKey();
    final element = key.currentContext as Element?;
    if (element != null) {
      final scrollable = element.findAncestorWidgetOfExactType<Scrollable>();
      if (scrollable != null) {
        return element.findAncestorStateOfType<ScrollableState>()?.context;
      }
    }
    return null;
  }

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
    final unicode = word.codeUnitAt(0) - 0xAC00;
    final index = unicode ~/ (21 * 28);
    return index >= 0 && index < initialConsonants.length
        ? initialConsonants[index]
        : 'ㄱ';
  }

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
        color: Color(0xFFF0F0FF),
        child: Stack(
          children: [
            _buildWordList(),
            if (_showAlphabetList) _buildAlphabetList(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildWordList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: groupedWords.length,
      itemBuilder: (context, index) {
        final initial = groupedWords.keys.elementAt(index);
        final words = groupedWords[initial]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInitialHeader(initial),
            ...words.map((word) => _buildWordTile(word)).toList(),
          ],
        );
      },
    );
  }

  Widget _buildInitialHeader(String initial) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      color: Color(0xFFD5D1EE),
      child: Text(
        initial,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Color(0xFF5D4777),
        ),
      ),
    );
  }

  Widget _buildWordTile(Map<String, String> word) {
    return CustomExpansionTile(
      word: word['word']!,
      definition: word['definition']!,
      isExpanded: word['word'] == _expandedWord,
      onExpansionChanged: (expanded) {
        setState(() {
          _expandedWord = expanded ? word['word'] : null;
        });
      },
    );
  }

  Widget _buildAlphabetList() {
    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      child: Container(
        width: 30,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListView.builder(
          itemCount: _alphabet.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => _scrollToLetter(_alphabet[index]),
              child: Container(
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _pressedLetter == _alphabet[index]
                      ? Color(0xFF8A7FBA).withOpacity(0.3)
                      : Colors.transparent,
                ),
                child: Text(
                  _alphabet[index],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: _pressedLetter == _alphabet[index]
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: _pressedLetter == _alphabet[index]
                        ? Color(0xFF8A7FBA)
                        : Colors.black,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 3,
      backgroundColor: Color(0xFF8A7FBA),
      selectedItemColor: Colors.white,
      unselectedItemColor: Color(0xFFD5D1EE),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: '단어찾기'),
        BottomNavigationBarItem(icon: Icon(Icons.flash_on), label: '오늘단어'),
        BottomNavigationBarItem(icon: Icon(Icons.book), label: '단어목록'),
      ],
      onTap: (index) {
        if (index != 3) {
          Widget screen;
          switch (index) {
            case 0:
              screen = MainScreen();
              break;
            case 1:
              screen = SearchScreen();
              break;
            case 2:
              screen = FlashCardStartScreen();
              break;
            default:
              return;
          }
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => screen),
            (Route<dynamic> route) => false,
          );
        }
      },
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
                color: Color(0xFF5D4777), // 진한 보라
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
