import 'package:flutter/material.dart';
import 'main_screen.dart';
import 'search_screen.dart';
import 'word_list_screen.dart';

class WordDetailScreen extends StatelessWidget {
  final Map<String, dynamic> word; // String에서 dynamic으로 변경

  const WordDetailScreen({Key? key, required this.word}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('단어 찾기', style: TextStyle(color: Colors.white)), // 제목 변경
        backgroundColor: Color(0xFF8A7FBA),
        elevation: 0,
        leading: IconButton(
          // 뒤로 가기 버튼 추가
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        color: Color(0xFFF0F0FF),
        child: Padding(
          // Padding 추가
          padding: EdgeInsets.all(16),
          child: Column(
            // ListView에서 Column으로 변경
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                word['word'] ?? '',
                style: TextStyle(
                  fontSize: 28, // 폰트 크기 변경
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5D4777),
                ),
              ),
              SizedBox(height: 24),
              Container(
                // 정의를 포함하는 컨테이너 추가
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
                child: Text(
                  word['definition'] ?? '',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF6A5495),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Color(0xFF8A7FBA),
      selectedItemColor: Colors.white,
      unselectedItemColor: Color(0xFFD5D1EE),
      currentIndex: 1,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: '단어찾기'),
        BottomNavigationBarItem(icon: Icon(Icons.flash_on), label: '오늘단어'),
        BottomNavigationBarItem(icon: Icon(Icons.book), label: '단어목록'),
      ],
      onTap: (index) {
        Widget screen;
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
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => screen),
          (Route<dynamic> route) => false,
        );
      },
    );
  }
}
