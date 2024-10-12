import 'package:flutter/material.dart';
import 'dart:async';
import 'main_screen.dart'; // MainScreen 위젯이 있는 파일을 import 해야 합니다.
import '../word_data.dart'; // WordData import 추가

// SplashScreen: 앱 시작 시 표시되는 로딩 화면
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _loadDataAndNavigate();
  }

  // 데이터 로딩 및 메인 화면으로 이동하는 메서드
  Future<void> _loadDataAndNavigate() async {
    await WordData.loadWords(); // 단어 데이터 로딩
    await Future.delayed(const Duration(seconds: 2)); // 최소 2초 대기

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 1,
                child: Container(color: Colors.white),
              ),
              Expanded(
                flex: 1,
                child: Container(color: const Color(0xFF1E3859)),
              ),
            ],
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      '사회초년생을 위한',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3859),
                      ),
                    ),
                    Text(
                      '보험용어사전',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3859),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20), // 텍스트와 로고 사이의 간격
                Image.asset(
                  'assets/Icon/logo.png',
                  width: 300,
                  height: 300,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
