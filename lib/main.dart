import 'package:flutter/material.dart';
import 'word_data.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await WordData.loadWords();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BOVO',
      theme: ThemeData(
        primaryColor: Color(0xFF8A7FBA),
        scaffoldBackgroundColor: Color(0xFFF0F0FF),
      ),
      home: MainScreen(),
    );
  }
}
