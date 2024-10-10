import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

// WordData 클래스: 단어 데이터를 관리하는 정적 클래스
class WordData {
  // 카테고리 정보를 저장하는 리스트
  static List<Map<String, dynamic>> categories = [];
  // 카테고리별로 단어를 그룹화하여 저장하는 맵
  static Map<String, List<Map<String, String>>> groupedWords = {};

  // 단어 데이터를 로드하는 비동기 메서드
  static Future<void> loadWords() async {
    // assets/words.json 파일에서 데이터 읽기
    final String response = await rootBundle.loadString('assets/words.json');
    // JSON 데이터 파싱
    final data = await json.decode(response);
    // 카테고리 정보 저장
    categories = List<Map<String, dynamic>>.from(data['categories']);

    // 카테고리별로 단어 그룹화
    for (var category in categories) {
      String categoryName = category['name'];
      List<dynamic> words = category['words'];
      // 각 단어를 Map 형태로 변환하여 저장
      groupedWords[categoryName] = words
          .map((word) => {
                'word': word['word'] as String,
                'definition': word['definition'] as String,
              })
          .toList();
    }
  }

  // 특정 카테고리의 단어 목록을 반환하는 메서드
  static List<Map<String, String>> getWordsByCategory(String category) {
    return groupedWords[category] ?? [];
  }

  // 모든 단어 목록을 반환하는 메서드
  static List<Map<String, String>> getAllWords() {
    List<Map<String, String>> allWords = [];
    groupedWords.forEach((key, value) {
      allWords.addAll(value);
    });
    return allWords;
  }

  // 오늘의 단어 목록을 반환하는 메서드 (현재는 임시로 구현)
  static List<Map<String, String>> getTodaysWords() {
    // 임시로 모든 단어 중 5개를 반환
    return getAllWords().take(5).toList();
  }
}
