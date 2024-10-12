import 'package:flutter/material.dart';
import 'main_screen.dart';
import 'search_screen.dart';
import 'word_list_screen.dart';

// WordDetailScreen: 단어의 상세 정보를 표시하는 화면
class WordDetailScreen extends StatelessWidget {
  final Map<String, dynamic> word; // 단어 정보를 담은 Map

  const WordDetailScreen({Key? key, required this.word}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('단어 찾기', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF8A7FBA),
        elevation: 0,
        leading: IconButton(
          // 뒤로 가기 버튼
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        color: Color(0xFFF0F0FF), // 배경색 설정
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 단어 표시
              Text(
                word['word'] ?? '',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5D4777),
                ),
              ),
              SizedBox(height: 24),
              // 단어 정의를 포함하는 컨테이너
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                // 단어 정의 표시
                child: Text(
                  word['definition'] ?? '',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF6A5495),
                    height: 1.5,
                  ),
                ),
              ),
              if (word['example1']?.isNotEmpty ?? false)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '예문 1:',
                      style: TextStyle(fontSize: 18, color: Color(0xFF5D4777)),
                    ),
                    Text(
                      word['example1'] ?? '',
                      style: TextStyle(fontSize: 18, color: Color(0xFF5D4777)),
                    ),
                  ],
                ),
              // 예문 2도 유사한 구조
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  // 하단 네비게이션 바 구축 메서드
  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Color(0xFF8A7FBA),
      selectedItemColor: Colors.white,
      unselectedItemColor: Color(0xFFD5D1EE),
      currentIndex: 1, // '단어찾기' 탭이 선택된 상태
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: '단어찾기'),
        BottomNavigationBarItem(icon: Icon(Icons.flash_on), label: '오늘단어'),
        BottomNavigationBarItem(icon: Icon(Icons.book), label: '단어목록'),
      ],
      onTap: (index) {
        Widget screen;
        // 선택된 탭에 따라 화면 전환
        switch (index) {
          case 0:
            screen = MainScreen();
            break;
          case 1:
            screen = SearchScreen();
            break;
          case 3:
            screen = WordListScreen();
            break;
          default:
            return;
        }
        // 새로운 화면으로 이동하고 이전 화면들을 모두 제거
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => screen),
          (Route<dynamic> route) => false,
        );
      },
    );
  }
}
