import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'search_screen.dart';
import 'word_list_screen.dart';
import 'flash_card_start_screen.dart';
import 'mynote_screen.dart'; // mynote_screen.dart import

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Map<String, dynamic>> words = [];
  int currentWordIndex = 0;
  bool showMeaning = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadWords();
  }

  Future<void> loadWords() async {
    try {
      final String response = await rootBundle.loadString('assets/words.json');
      final data = await json.decode(response);
      setState(() {
        words = [];
        for (var category in data['categories']) {
          words.addAll(List<Map<String, dynamic>>.from(category['words']));
        }
        words.shuffle();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading words: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E3859),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildTodayWordCard(),
              SizedBox(height: 16),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 3, // 단어찾기 카드의 비율
                      child: _buildSearchCard(),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      flex: 2, // 단어목록과 단어장 컬럼의 비율
                      child: Column(
                        children: [
                          Expanded(child: _buildWordListCard()),
                          SizedBox(height: 16),
                          Expanded(child: _buildMyNoteCard()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildTodayWordCard() {
    if (isLoading) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (words.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(child: Text('단어를 불러올 수 없습니다.')),
      );
    }

    if (currentWordIndex >= 3 || currentWordIndex >= words.length) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: ElevatedButton(
            child: Text('추가학습하기'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FlashCardStartScreen()),
              );
            },
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          showMeaning = !showMeaning;
        });
      },
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! < 0) {
          // 왼쪽으로 스와이프
          setState(() {
            currentWordIndex++;
            showMeaning = false;
          });
        }
      },
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '오늘 학습할 단어',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3859),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  showMeaning
                      ? words[currentWordIndex]['meaning']
                      : words[currentWordIndex]['word'],
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3859),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '${currentWordIndex + 1} / ${words.length < 3 ? words.length : 3}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1E3859),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '단어찾기',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3859),
            ),
          ),
          Text(
            'Search',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF1E3859),
            ),
          ),
          SizedBox(height: 20),
          Icon(Icons.search, size: 60, color: Color(0xFF1E3859)),
        ],
      ),
    );
  }

  Widget _buildWordListCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '단어목록',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3859),
            ),
          ),
          Text(
            'Word List',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF1E3859),
            ),
          ),
          SizedBox(height: 10),
          Icon(Icons.book, size: 40, color: Color(0xFF1E3859)),
        ],
      ),
    );
  }

  Widget _buildMyNoteCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '단어장',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3859),
            ),
          ),
          Text(
            'My Note',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF1E3859),
            ),
          ),
          SizedBox(height: 10),
          Icon(Icons.note, size: 40, color: Color(0xFF1E3859)),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.home, color: Color(0xFF1E3859)),
          Icon(Icons.search, color: Color(0xFF1E3859)),
          Icon(Icons.book, color: Color(0xFF1E3859)),
          Icon(Icons.note, color: Color(0xFF1E3859)),
          Icon(Icons.menu_book, color: Color(0xFF1E3859)),
        ],
      ),
    );
  }
}
