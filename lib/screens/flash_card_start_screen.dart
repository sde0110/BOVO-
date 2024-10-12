import 'package:flutter/material.dart';
import 'flash_card_screen.dart';
import 'search_screen.dart';
import 'word_list_screen.dart';
import 'main_screen.dart';
import '../word_data.dart';
import 'mynote_screen.dart';

// FlashCardStartScreen: 플래시 카드 학습을 시작하는 화면
class FlashCardStartScreen extends StatefulWidget {
  @override
  _FlashCardStartScreenState createState() => _FlashCardStartScreenState();
}

class _FlashCardStartScreenState extends State<FlashCardStartScreen> {
  late List<Map<String, dynamic>> todaysWords; // String을 dynamic으로 변경
  // 카테고리 정보 (이름과 아이콘 경로)
  List<Map<String, dynamic>> categories = [
    {'name': '주택', 'icon': 'assets/Icon/jutaek.png'},
    {'name': '아르바이트', 'icon': 'assets/Icon/alba.png'},
    {'name': '전자기기', 'icon': 'assets/Icon/junja.png'},
    {'name': '여행', 'icon': 'assets/Icon/yuhang.png'},
  ];

  @override
  void initState() {
    super.initState();
    todaysWords = WordData.getTodaysWords(); // 타입 캐스팅 제거
    _loadData();
  }

  // 단어 데이터 로드
  Future<void> _loadData() async {
    await WordData.loadWords();
    setState(() {
      todaysWords = WordData.getTodaysWords();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E3859),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => MainScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
              child: Text(
                '원하는 카테고리를 선택해 학습을 시작하세요.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.0,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                padding: EdgeInsets.all(16),
                children: categories
                    .map((category) => _buildCategoryCard(
                        context, category['icon'], category['name']))
                    .toList(),
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
              color: Color(0xFF1E3859).withOpacity(0.1),
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
            _buildNavBarItem(
                'assets/Icon/word_list.png',
                '단어목록',
                () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => WordListScreen()))),
            _buildNavBarItem('assets/Icon/today_word.png', '오늘단어', null),
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

  // 카테고리 카드 위젯 생성
  Widget _buildCategoryCard(
      BuildContext context, String iconPath, String label) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => FlashCardScreen(category: label)),
        );
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: 64,
              height: 64,
              color: Color(0xFF1E3859),
              errorBuilder: (context, error, stackTrace) {
                print('Error loading image: $error');
                return Icon(Icons.error, size: 64, color: Color(0xFF1E3859));
              },
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3859),
              ),
              textAlign: TextAlign.center,
            ),
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
            color: label == '오늘단어'
                ? Color(0xFF1E3859)
                : Color(0xFF1E3859).withOpacity(0.5),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: label == '오늘단어'
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
