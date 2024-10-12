import 'package:flutter/material.dart';
import 'word_data.dart';
import 'screens/splash_screen.dart'; // SplashScreen import 추가

// 앱의 진입점
void main() async {
  // Flutter 엔진과 위젯 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // 단어 데이터 로드 (비동기 작업)
  await WordData.loadWords();

  // MyApp 위젯으로 앱 실행
  runApp(MyApp());
}

// MyApp 클래스: 앱의 루트 위젯
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 앱의 제목 설정
      title: 'BOVO App',

      // 앱의 테마 설정
      theme: ThemeData(
        // 주 색상을 보라색 계열로 설정
        primaryColor: Color(0xFF8A7FBA),
        // 배경색을 연한 보라색으로 설정
        scaffoldBackgroundColor: Color(0xFFF0F0FF),
        fontFamily: 'Bovo', // 여기서 기본 폰트를 설정합니다.
        textTheme: Theme.of(context).textTheme.apply(
              fontFamily: 'Bovo',
            ),
        primaryTextTheme: Theme.of(context).textTheme.apply(
              fontFamily: 'Bovo',
            ),
      ),

      // 시작 화면을 SplashScreen으로 설정
      home: SplashScreen(),
    );
  }
}
