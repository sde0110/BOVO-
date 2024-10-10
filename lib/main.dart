import 'package:flutter/material.dart';
import 'word_data.dart';
import 'screens/splash_screen.dart';
import 'screens/search_screen.dart';
import 'screens/flash_card_start_screen.dart';
import 'screens/word_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await WordData.loadWords();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BOVO App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: SplashScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    SearchScreen(),
    FlashCardStartScreen(),
    WordListScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.search), label: '단어찾기'),
          BottomNavigationBarItem(icon: Icon(Icons.flash_on), label: '오늘단어'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: '단어목록'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xFF8A7FBA),
        selectedItemColor: Colors.white,
        unselectedItemColor: Color(0xFFD5D1EE),
      ),
    );
  }
}
