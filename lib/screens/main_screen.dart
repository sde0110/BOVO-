import 'package:flutter/material.dart';
import 'search_screen.dart';
import 'word_list_screen.dart';
import 'flash_card_start_screen.dart'; // FlashCardStartScreen을 import

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BOVO', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF8A7FBA),
        elevation: 0,
      ),
      body: Container(
        color: Color(0xFFF0F0FF),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLargeButton(
                  context,
                  icon: Icons.search,
                  label: '단어 찾기',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SearchScreen()),
                  ),
                ),
                SizedBox(height: 20),
                _buildLargeButton(
                  context,
                  icon: Icons.flash_on,
                  label: '오늘 단어',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FlashCardStartScreen()),
                  ),
                ),
                SizedBox(height: 20),
                _buildLargeButton(
                  context,
                  icon: Icons.book,
                  label: '단어 목록',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WordListScreen()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLargeButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 80,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 30, color: Colors.white),
        label: Text(
          label,
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF8A7FBA), // primary를 backgroundColor로 변경
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 5,
        ),
      ),
    );
  }
}
