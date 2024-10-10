import 'package:flutter/material.dart';
import 'flash_card_screen.dart';
import 'search_screen.dart';
import 'word_list_screen.dart';
import 'main_screen.dart';
import '../word_data.dart';

class FlashCardStartScreen extends StatefulWidget {
  @override
  _FlashCardStartScreenState createState() => _FlashCardStartScreenState();
}

class _FlashCardStartScreenState extends State<FlashCardStartScreen> {
  List<Map<String, String>> todaysWords = [];
  List<Map<String, dynamic>> categories = [
    {'name': '주택', 'icon': Icons.home},
    {'name': '아르바이트', 'icon': Icons.work},
    {'name': '전자기기', 'icon': Icons.devices},
    {'name': '여행', 'icon': Icons.flight},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await WordData.loadWords();
    setState(() {
      todaysWords = WordData.getTodaysWords();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('오늘 단어', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF8A7FBA),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        color: Color(0xFFF0F0FF),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Text(
                '오늘의 단어를 학습해 보세요!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                padding: EdgeInsets.all(16),
                children: categories
                    .map((category) => _buildCategoryCard(context,
                        category['icon'], category['name'], category['name']))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xFF8A7FBA),
        selectedItemColor: Colors.white,
        unselectedItemColor: Color(0xFFD5D1EE),
        currentIndex: 2,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: '단어찾기'),
          BottomNavigationBarItem(icon: Icon(Icons.flash_on), label: '오늘단어'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: '단어목록'),
        ],
        onTap: (index) {
          if (index != 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) {
                  switch (index) {
                    case 0:
                      return MainScreen();
                    case 1:
                      return SearchScreen();
                    case 3:
                      return WordListScreen();
                    default:
                      return FlashCardStartScreen();
                  }
                },
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildCategoryCard(
      BuildContext context, IconData icon, String label, String category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => FlashCardScreen(category: category)),
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
            Icon(icon, size: 48, color: Color(0xFF8A7FBA)),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8A7FBA),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
