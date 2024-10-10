import 'package:flutter/material.dart';
import '../word_data.dart';
import 'dart:math';

// 선택된 카테고리의 단어를 플래시 카드 형식으로 학습하는 화면
class FlashCardScreen extends StatefulWidget {
  final String category;

  FlashCardScreen({required this.category});

  @override
  _FlashCardScreenState createState() => _FlashCardScreenState();
}

class _FlashCardScreenState extends State<FlashCardScreen> {
  List<Map<String, String>> categoryWords = [];
  List<Map<String, String>> quizWords = [];
  List<Map<String, String>> originalQuizWords = []; // 원래 선택된 10개 단어 저장
  bool isLoading = true;
  int currentIndex = 0;
  bool showDefinition = false;
  bool isQuizMode = false;
  bool isAnswered = false;
  bool isCorrect = false;
  bool isShuffled = false;
  List<Map<String, String>> incorrectAnswers = [];
  int score = 0;
  String displayedWord = '';
  String displayedMeaning = '';
  List<Map<String, String>> currentWordSet = []; // 현재 학습 중인 단어 세트

  final Color primaryColor = Color(0xFF9575CD);
  final Color accentColor = Color(0xFFD1C4E9);

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  // 단어 데이터 로드 및 초기화
  Future<void> _loadWords() async {
    setState(() {
      isLoading = true;
    });

    await WordData.loadWords();
    categoryWords = WordData.getWordsByCategory(widget.category);
    quizWords = _getRandomWords();
    originalQuizWords = List.from(quizWords);
    currentWordSet = _getRandomWords();

    setState(() {
      isLoading = false;
    });
  }

  // 랜덤으로 10개의 단어 선택
  List<Map<String, String>> _getRandomWords() {
    final random = Random();
    final tempList = List<Map<String, String>>.from(categoryWords);
    tempList.shuffle(random);
    return tempList.take(10).toList();
  }

  // 다음 카드로 이동
  void _nextCard() {
    setState(() {
      if (currentIndex < quizWords.length - 1) {
        currentIndex++;
        showDefinition = false;
        if (isQuizMode) {
          isAnswered = false;
          _shuffleWordAndMeaning();
        }
      } else {
        if (isQuizMode) {
          _showQuizResult();
        } else {
          _showCompletionScreen();
        }
      }
    });
  }

  // 이전 카드로 이동
  void _previousCard() {
    setState(() {
      if (currentIndex > 0) {
        currentIndex--;
      } else {
        currentIndex = 0;
      }
      showDefinition = false;
    });
  }

  // 단어 정의 표시/숨김 토글
  void _toggleDefinition() {
    setState(() {
      showDefinition = !showDefinition;
    });
  }

  // 학습 완료 화면 표시
  void _showCompletionScreen() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('수고하셨습니다!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _resetToFirstWord();
                },
                child: Text('다시 학습하기'),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(primaryColor),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _startQuiz();
                },
                child: Text('퀴즈 시작하기'),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(primaryColor),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 첫 번째 단어로 리셋
  void _resetToFirstWord() {
    setState(() {
      currentIndex = 0;
      showDefinition = false;
      isQuizMode = false;
    });
  }

  // 퀴즈 모드 시작
  void _startQuiz() {
    setState(() {
      isQuizMode = true;
      currentIndex = 0;
      score = 0;
      incorrectAnswers = [];
      isAnswered = false;
      _shuffleWordAndMeaning();
    });
  }

  // 퀴즈 모드에서 단어와 뜻을 섞음
  void _shuffleWordAndMeaning() {
    var random = Random();
    var wordPair = quizWords[currentIndex];

    bool showCorrectMeaning = random.nextBool();
    if (showCorrectMeaning) {
      displayedWord = wordPair['word']!;
      displayedMeaning = wordPair['definition']!;
      isShuffled = true;
    } else {
      List<String> incorrectMeanings = quizWords
          .where((w) => w['word'] != wordPair['word'])
          .map((w) => w['definition']!)
          .toList();
      displayedWord = wordPair['word']!;
      displayedMeaning =
          incorrectMeanings[random.nextInt(incorrectMeanings.length)];
      isShuffled = false;
    }
  }

  // 퀴즈 답변 확인
  void _checkAnswer(bool userAnswer) {
    setState(() {
      isAnswered = true;
      isCorrect = (userAnswer == isShuffled);
      if (isCorrect) {
        score += 10;
      } else {
        incorrectAnswers.add(quizWords[currentIndex]);
      }

      Future.delayed(Duration(milliseconds: 500), _nextCard);
    });
  }

  // 퀴즈 결과 화면 표시
  void _showQuizResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('퀴즈 결과', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('오늘의 점수',
                    style: TextStyle(fontSize: 24, color: Colors.grey[600])),
                SizedBox(height: 10),
                Text('$score',
                    style: TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: primaryColor)),
                SizedBox(height: 20),
                Text(
                  score <= 40
                      ? '아쉬워요. 다시 학습하러 가 볼까요?'
                      : score <= 80
                          ? '잘 했어요! 틀린 문제를 확인해 보세요.'
                          : score <= 99
                              ? '정말 잘했어요!'
                              : '오늘 학습한 단어를 모두 맞추셨어요!',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                if (incorrectAnswers.isNotEmpty) ...[
                  Text('오답 리스트',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  ...incorrectAnswers
                      .map((word) => Card(
                            child: ListTile(
                              title: Text(word['word']!,
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(word['definition']!),
                            ),
                          ))
                      .toList(),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('단어학습 다시하기'),
              onPressed: () {
                Navigator.of(context).pop();
                _resetToLearningMode();
              },
            ),
          ],
        );
      },
    );
  }

  // 학습 모드로 리셋
  void _resetToLearningMode() {
    setState(() {
      currentIndex = 0;
      showDefinition = false;
      isQuizMode = false;
      isAnswered = false;
      isCorrect = false;
      isShuffled = false;
      score = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _loadWords();
        return true;
      },
      child: Scaffold(
        backgroundColor: accentColor,
        appBar: AppBar(
          title: Text('#${widget.category}'),
          backgroundColor: primaryColor,
          actions: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '${currentIndex + 1} / ${quizWords.length}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 학습 모드 UI
                if (!isQuizMode) ...[
                  Expanded(
                    child: GestureDetector(
                      onTap: _toggleDefinition,
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  quizWords[currentIndex]['word'] ?? '',
                                  style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 20),
                                if (showDefinition)
                                  Text(
                                    quizWords[currentIndex]['definition'] ?? '',
                                    style: TextStyle(fontSize: 24),
                                    textAlign: TextAlign.center,
                                  )
                                else
                                  Text(
                                    '터치하여 뜻 보기',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.grey),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ]
                // 퀴즈 모드 UI (답변 전)
                else if (!isAnswered) ...[
                  Text(
                    displayedWord,
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      displayedMeaning,
                      style: TextStyle(fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => _checkAnswer(true),
                        child: Text('O', style: TextStyle(fontSize: 36)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(24),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _checkAnswer(false),
                        child: Text('X', style: TextStyle(fontSize: 36)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(24),
                        ),
                      ),
                    ],
                  ),
                ]
                // 퀴즈 모드 UI (답변 후)
                else ...[
                  Text(
                    isCorrect ? '정답입니다!' : '오답입니다!',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: isCorrect ? Colors.green : Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                SizedBox(height: 20),
                if (!isQuizMode)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            currentIndex = 0;
                            showDefinition = false;
                          });
                        },
                        child: Icon(Icons.arrow_back),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(16),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _nextCard,
                        child: Icon(Icons.arrow_forward),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(16),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
