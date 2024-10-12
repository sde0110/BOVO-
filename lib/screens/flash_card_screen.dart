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

class _FlashCardScreenState extends State<FlashCardScreen>
    with TickerProviderStateMixin {
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

  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late AnimationController _definitionFadeController;
  late Animation<double> _definitionFadeAnimation;

  final Color backgroundColor = Color(0xFF1E3859);
  final Color textColor = Colors.white;
  final Color accentColor = Color(0xFFF0F4F8);
  final Color correctColor = Color.fromARGB(142, 172, 255, 174);
  final Color incorrectColor = Color.fromARGB(168, 255, 181, 176);

  @override
  void initState() {
    super.initState();
    _loadWords();
    _scaleController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _fadeController = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    _scaleAnimation =
        CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut);
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _definitionFadeController = AnimationController(
      duration: const Duration(milliseconds: 100), // 빠른 페이드 아웃을 위해 시간 단축
      vsync: this,
    );
    _definitionFadeAnimation = CurvedAnimation(
      parent: _definitionFadeController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _definitionFadeController.dispose();
    super.dispose();
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
    _definitionFadeController.reverse().then((_) {
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
    });
  }

  // 이전 카드로 이동
  void _previousCard() {
    _definitionFadeController.reverse().then((_) {
      setState(() {
        if (currentIndex > 0) {
          currentIndex--;
        } else {
          currentIndex = 0;
        }
        showDefinition = false;
      });
    });
  }

  // 단어 정의 표시/숨김 토글
  void _toggleDefinition() {
    setState(() {
      showDefinition = !showDefinition;
      if (showDefinition) {
        _definitionFadeController.forward();
      } else {
        _definitionFadeController.reverse();
      }
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
                      MaterialStateProperty.all<Color>(backgroundColor),
                  foregroundColor: MaterialStateProperty.all<Color>(textColor),
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
                      MaterialStateProperty.all<Color>(backgroundColor),
                  foregroundColor: MaterialStateProperty.all<Color>(textColor),
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

      _showResultPopup();
    });
  }

  void _showResultPopup() {
    _scaleController.reset();
    _fadeController.reset();
    _scaleController.forward();
    _fadeController.forward();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 250,
            height: 250,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCorrect ? correctColor : incorrectColor,
                    ),
                  ),
                ),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Icon(
                    isCorrect ? Icons.check : Icons.close,
                    color: Colors.white,
                    size: 120,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isCorrect
                            ? correctColor.withOpacity(0.8)
                            : incorrectColor.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isCorrect ? '+10점' : '+0점',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    Future.delayed(Duration(milliseconds: 1500), () {
      Navigator.of(context).pop();
      _nextCard();
    });
  }

  // 퀴즈 결과 화면 표시
  void _showQuizResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('퀴즈 결과',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: backgroundColor)),
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
                        color: backgroundColor)),
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
                      color: backgroundColor),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                if (incorrectAnswers.isNotEmpty) ...[
                  Text('오답 리스트',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: backgroundColor)),
                  SizedBox(height: 10),
                  ...incorrectAnswers
                      .map((word) => Card(
                            color: Colors.white,
                            elevation: 2,
                            margin: EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              title: Text(word['word']!,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: backgroundColor)),
                              subtitle: Text(word['definition']!,
                                  style: TextStyle(
                                      color: backgroundColor.withOpacity(0.7))),
                            ),
                          ))
                      .toList(),
                ],
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      child: Text('오답노트 확인하기',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            backgroundColor, // primary를 backgroundColor로 변경
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        // 오답노트 확인 로직 구현
                        Navigator.of(context).pop();
                        // 오답노트 화면으로 이동하는 코드 추가
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      child: Text('단어학습 다시하기',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            backgroundColor, // primary를 backgroundColor로 변경
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _resetToLearningMode();
                      },
                    ),
                  ),
                ),
              ],
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
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('#${widget.category}',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                '${currentIndex + 1} / ${quizWords.length}',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isQuizMode) ...[
                _buildFlashCard(),
                SizedBox(height: 40),
                _buildNavigationButtons(),
              ] else if (!isAnswered) ...[
                _buildQuizCard(),
                SizedBox(height: 40),
                _buildQuizButtons(),
              ] else ...[
                _buildResultCard(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlashCard() {
    return GestureDetector(
      onTap: _toggleDefinition,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: textColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      quizWords[currentIndex]['word'] ?? '',
                      style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: backgroundColor),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    FadeTransition(
                      opacity: _definitionFadeAnimation,
                      child: Text(
                        quizWords[currentIndex]['definition'] ?? '',
                        style: TextStyle(
                            fontSize: 22,
                            color: backgroundColor.withOpacity(0.8)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!showDefinition)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    '탭하여 뜻 보기',
                    style: TextStyle(
                        color: backgroundColor.withOpacity(0.5), fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildIconButton(Icons.arrow_back, () {
          if (currentIndex > 0) {
            _previousCard();
          }
        }),
        _buildIconButton(Icons.arrow_forward, _nextCard),
      ],
    );
  }

  Widget _buildQuizCard() {
    return Container(
      width: double.infinity, // 화면 너비 전체를 사용
      height: MediaQuery.of(context).size.height * 0.6, // 높이는 화면의 60%로 고정
      decoration: BoxDecoration(
        color: textColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              displayedWord,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: backgroundColor,
              ),
              textAlign: TextAlign.center,
            ),
            Expanded(
              // 남은 공간을 모두 차지하도록 Expanded 위젯 사용
              child: Center(
                // 뜻을 중앙에 배치
                child: Text(
                  displayedMeaning,
                  style: TextStyle(
                    fontSize: 22,
                    color: backgroundColor.withOpacity(0.8),
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

  Widget _buildQuizButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0), // 좌우 패딩 추가
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // 버튼을 양쪽 끝으로 정렬
        children: [
          _buildAnswerButton('O', () => _checkAnswer(true)),
          _buildAnswerButton('X', () => _checkAnswer(false)),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: accentColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Center(),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: textColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: backgroundColor, size: 32),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildAnswerButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text, style: TextStyle(fontSize: 24, color: backgroundColor)),
      style: ElevatedButton.styleFrom(
        backgroundColor: textColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        minimumSize: Size(120, 60), // 버튼의 최소 크기 설정
      ),
    );
  }
}
