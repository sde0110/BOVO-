import 'package:flutter/material.dart';
import 'main_screen.dart';
import 'search_screen.dart';
import 'word_list_screen.dart';
import 'flash_card_start_screen.dart';

class MyNoteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내 단어장'),
        backgroundColor: Color(0xFF1E3859),
      ),
      body: Center(
        child: Text('내 단어장 화면'),
      ),
      bottomNavigationBar: Container(
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
            _buildNavBarItem(
                context,
                'assets/Icon/home.png',
                '홈',
                () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => MainScreen()))),
            _buildNavBarItem(
                context,
                'assets/Icon/search_navi.png',
                '검색',
                () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => SearchScreen()))),
            _buildNavBarItem(
                context,
                'assets/Icon/word_list.png',
                '단어목록',
                () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => WordListScreen()))),
            _buildNavBarItem(
                context,
                'assets/Icon/today_word.png',
                '오늘단어',
                () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FlashCardStartScreen()))),
            _buildNavBarItem(
                context,
                'assets/Icon/mynote.png',
                '단어장',
                () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => MyNoteScreen()))),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBarItem(BuildContext context, String iconPath, String label,
      VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            iconPath,
            width: 24,
            height: 24,
            color: label == '단어장'
                ? Color(0xFF1E3859)
                : Color(0xFF1E3859).withOpacity(0.5),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: label == '단어장'
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
