import 'package:flutter/material.dart';
import 'dart:math';

class FlashCardScreen extends StatefulWidget {
  final String category;
  FlashCardScreen({required this.category});

  @override
  _FlashCardScreenState createState() => _FlashCardScreenState();
}

class _FlashCardScreenState extends State<FlashCardScreen> {
  Map<String, List<Map<String, String>>> wordsByCategory = {
    '주택': [
      {'단어': '건축물대장', '뜻': '집의 소재, 구조, 면적 및 소유자의 주소, 성명 따위를 적은 공용 문서'},
      {'단어': '경매', '뜻': '권리자의 신청에 의하여 법원 또는 집행관이 동산이나 부동산을 구두의 방법으로 경쟁하여 파는 일'},
      {'단어': '공시가격', '뜻': '세무 당국이 과세의 기준으로 삼는 가격'},
    ],
    '전자기기': [
      {'단어': '개통', '뜻': '휴대폰을 사용가능하게끔 함'},
      {'단어': '공기계', '뜻': '통신사의 개통 이력이 없는 단말기'},
      {'단어': '공식수리센터', '뜻': '지정서비스센터나 제조사가 공식적으로 지정한 A/S지정점 또는 협력사'},
      {'단어': '균열', '뜻': '거북의 등에 있는 무늬처럼 갈라져 터짐'},
      {'단어': '단말기', '뜻': '핸드폰 등의 기기 자체를 칭하는 용어'},
      {'단어': '도난', '뜻': '도둑을 맞는 재난'},
      {'단어': '디스플레이', '뜻': '데이터를 시각적으로 화면에 출력하는 표시장치'},
    ],
    '여행': [
      {'단어': '여권', '뜻': '국제 여행에 필요한 신분증'},
      {'단어': '항공권', '뜻': '비행기 탑승 티켓'},
      {'단어': '호텔', '뜻': '숙박 시설'},
      {'단어': '짐', '뜻': '여행 시 가져가는 물건'},
      {'단어': '지도', '뜻': '여행 장소를 보여주는 도구'},
    ],
    '아르바이트': [
      {'단어': '개인사업자', '뜻': '개인적으로 사업을 경영하는 사람'},
      {'단어': '건설공사', '뜻': '토목, 건축과 관련된 재료, 노력과 작업 기계 설비를 무리하여 조직적으로 하는 생산 업무'},
      {'단어': '임금', '뜻': '근로자가 노동의 대가로 사용자에게 받는 보수.'},
    ],
  };

  List<Map<String, String>> randomWords = [];
  int currentIndex = 0;
  bool showMeaning = false;

  @override
  void initState() {
    super.initState();
    randomWords = _getRandomWords();
  }

  List<Map<String, String>> _getRandomWords() {
    var random = Random();
    List<Map<String, String>> tempList =
        List.from(wordsByCategory[widget.category]!);
    tempList.shuffle(random);
    return tempList.take(10).toList();
  }

  void _nextCard() {
    setState(() {
      if (currentIndex < randomWords.length - 1) {
        currentIndex++;
        showMeaning = false;
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CompletionScreen(
                category: widget.category, learnedWords: randomWords),
          ),
        );
      }
    });
  }

  void _previousCard() {
    setState(() {
      if (currentIndex > 0) {
        currentIndex--;
        showMeaning = false;
      }
    });
  }

  void _toggleMeaning() {
    setState(() {
      showMeaning = !showMeaning;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('#${widget.category}'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${currentIndex + 1}/${randomWords.length}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 50),
                  Text(
                    randomWords[currentIndex]['단어']!,
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: _toggleMeaning,
                    child: Column(
                      children: [
                        if (showMeaning)
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.blue[100],
                            ),
                            child: Text(
                              randomWords[currentIndex]['뜻']!,
                              style: TextStyle(fontSize: 24),
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          Text(
                            '터치해보세요!',
                            style: TextStyle(
                                fontSize: 16,
                                color: const Color.fromARGB(255, 24, 24, 24)),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, size: 40),
                  onPressed: _previousCard,
                  color: currentIndex > 0 ? Colors.black : Colors.grey[300],
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward, size: 40),
                  onPressed: _nextCard,
                  color: currentIndex < randomWords.length - 1
                      ? Colors.black
                      : const Color.fromARGB(255, 0, 0, 0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CompletionScreen extends StatelessWidget {
  final String category;
  final List<Map<String, String>> learnedWords;

  CompletionScreen({required this.category, required this.learnedWords});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('#$category'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '수고하셨습니다!',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          FlashCardScreen(category: category)),
                );
              },
              child: Text('다시 학습하기'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => QuizScreen(
                          category: category, learnedWords: learnedWords)),
                );
              },
              child: Text('퀴즈 시작하기'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuizScreen extends StatefulWidget {
  final String category;
  final List<Map<String, String>> learnedWords;

  QuizScreen({required this.category, required this.learnedWords});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Map<String, String>> quizWords = [];
  String displayedWord = '';
  String displayedMeaning = '';
  int currentIndex = 0;
  bool isAnswered = false;
  bool isCorrect = false;
  bool isShuffled = false;
  List<Map<String, String>> incorrectAnswers = [];
  int score = 0;

  @override
  void initState() {
    super.initState();
    quizWords = List.from(widget.learnedWords);
    _shuffleWordAndMeaning();
  }

  void _shuffleWordAndMeaning() {
    var random = Random();
    var wordPair = quizWords[currentIndex];

    bool showCorrectMeaning = random.nextBool();
    if (showCorrectMeaning) {
      displayedWord = wordPair['단어']!;
      displayedMeaning = wordPair['뜻']!;
      isShuffled = true;
    } else {
      List<String> incorrectMeanings = quizWords
          .where((w) => w['단어'] != wordPair['단어'])
          .map((w) => w['뜻']!)
          .toList();
      displayedWord = wordPair['단어']!;
      displayedMeaning =
          incorrectMeanings[random.nextInt(incorrectMeanings.length)];
      isShuffled = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('#${widget.category} 퀴즈'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${currentIndex + 1}/${quizWords.length}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isAnswered) ...[
              Text(
                displayedWord,
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.blue[100],
                ),
                child: Text(
                  displayedMeaning,
                  style: TextStyle(fontSize: 24),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _checkAnswer(true);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(24),
                    ),
                    child: Icon(Icons.check, size: 36),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _checkAnswer(false);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(24),
                    ),
                    child: Icon(Icons.close, size: 36),
                  ),
                ],
              ),
            ] else ...[
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
          ],
        ),
      ),
    );
  }

  void _checkAnswer(bool userAnswer) {
    setState(() {
      isAnswered = true;
      isCorrect = (userAnswer == isShuffled);
      if (isCorrect) {
        score += 10;
      } else {
        incorrectAnswers.add(quizWords[currentIndex]);
      }

      Future.delayed(Duration(milliseconds: 500), _nextQuestion);
    });
  }

  void _nextQuestion() {
    setState(() {
      if (currentIndex < quizWords.length - 1) {
        currentIndex++;
        isAnswered = false;
        _shuffleWordAndMeaning();
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QuizResultScreen(
              score: score,
              incorrectAnswers: incorrectAnswers,
            ),
          ),
        );
      }
    });
  }
}

class QuizResultScreen extends StatelessWidget {
  final int score;
  final List<Map<String, String>> incorrectAnswers;

  QuizResultScreen({required this.score, required this.incorrectAnswers});

  @override
  Widget build(BuildContext context) {
    String message;
    if (score <= 40) {
      message = '다시 학습해보아요!';
    } else if (score <= 80) {
      message = '잘 했어요! 틀린 문제를 보아요.';
    } else {
      message = '매우 잘했어요!';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('퀴즈 결과'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '오늘의 점수: $score',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                message,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FlashCardScreen(category: '주택')),
                  );
                },
                child: Text('다시 학습하기'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                '오답 리스트:',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: incorrectAnswers.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        '${index + 1}. ${incorrectAnswers[index]['단어']}',
                        style: TextStyle(fontSize: 20),
                      ),
                      subtitle: Text('정답: ${incorrectAnswers[index]['뜻']}'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
