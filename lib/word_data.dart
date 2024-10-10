import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class WordData {
  static List<Map<String, dynamic>> categories = [];
  static Map<String, List<Map<String, String>>> groupedWords = {};

  static Future<void> loadWords() async {
    final String response = await rootBundle.loadString('assets/words.json');
    final data = await json.decode(response);
    categories = List<Map<String, dynamic>>.from(data['categories']);

    for (var category in categories) {
      String categoryName = category['name'];
      List<dynamic> words = category['words'];
      groupedWords[categoryName] = words
          .map((word) => {
                'word': word['word'] as String,
                'definition': word['definition'] as String,
              })
          .toList();
    }
  }

  static List<Map<String, String>> getWordsByCategory(String category) {
    return groupedWords[category] ?? [];
  }

  static List<Map<String, String>> getAllWords() {
    List<Map<String, String>> allWords = [];
    groupedWords.forEach((key, value) {
      allWords.addAll(value);
    });
    return allWords;
  }

  static List<Map<String, String>> getTodaysWords() {
    // 임시로 모든 단어 중 5개를 반환
    return getAllWords().take(5).toList();
  }
}
