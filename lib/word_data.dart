import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math'; // Added import for Random

class WordData {
  static List<Map<String, dynamic>> categories = [];
  static List<Map<String, String>> commonWords = [];

  static Future<void> loadWords() async {
    final String jsonString = await rootBundle.loadString('assets/words.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    categories = List<Map<String, dynamic>>.from(jsonData['categories']);

    if (jsonData.containsKey('common')) {
      commonWords = List<Map<String, String>>.from(jsonData['common']);
    }
  }

  static List<Map<String, dynamic>> getAllWords() {
    List<Map<String, dynamic>> allWords = [];
    for (var category in categories) {
      allWords.addAll(List<Map<String, dynamic>>.from(category['words']));
    }
    allWords.addAll(commonWords);
    return allWords;
  }

  static List<Map<String, dynamic>> searchWords(String query) {
    query = query.toLowerCase();
    return getAllWords()
        .where((word) =>
            word['word']!.toLowerCase().contains(query) ||
            word['definition']!.toLowerCase().contains(query))
        .toList();
  }

  static List<Map<String, dynamic>> get allCategories {
    return categories;
  }

  static List<String> getCategoryNames() {
    return categories.map((category) => category['name'] as String).toList();
  }

  static List<Map<String, dynamic>> getTodaysWords() {
    List<Map<String, dynamic>> todaysWords = [];
    Random random = Random();

    // 카테고리 목록에서 '공통'을 제외하고 '주택'을 포함시킵니다.
    List<String> categoriesToInclude = ['주택', '금융', '법률', '의료', '교육'];

    // 각 카테고리에서 랜덤하게 단어를 선택합니다.
    for (var categoryName in categoriesToInclude) {
      var category = categories.firstWhere((c) => c['name'] == categoryName,
          orElse: () => <String, dynamic>{'name': categoryName, 'words': []});

      List<Map<String, dynamic>> categoryWords =
          List<Map<String, dynamic>>.from(category['words']);
      if (categoryWords.isNotEmpty) {
        int randomIndex = random.nextInt(categoryWords.length);
        todaysWords.add(categoryWords[randomIndex]);
      }
    }

    // 만약 선택된 단어가 5개 미만이라면, 전체 단어 목록에서 랜덤하게 추가합니다.
    List<Map<String, dynamic>> allWords = getAllWords()
        .where((word) => categoriesToInclude.contains(word['category']))
        .toList();

    while (todaysWords.length < 5 && allWords.isNotEmpty) {
      int randomIndex = random.nextInt(allWords.length);
      if (!todaysWords.contains(allWords[randomIndex])) {
        todaysWords.add(allWords[randomIndex]);
      }
      allWords.removeAt(randomIndex);
    }

    return todaysWords;
  }

  static List<Map<String, dynamic>> getAllCategories() {
    return categories;
  }

  static Map<String, List<Map<String, dynamic>>> groupWordsByKoreanConsonant() {
    final consonants = [
      'ㄱ',
      'ㄴ',
      'ㄷ',
      'ㄹ',
      'ㅁ',
      'ㅂ',
      'ㅅ',
      'ㅇ',
      'ㅈ',
      'ㅊ',
      'ㅋ',
      'ㅌ',
      'ㅍ',
      'ㅎ'
    ];
    final grouped = Map<String, List<Map<String, dynamic>>>.fromIterable(
        consonants,
        key: (e) => e as String,
        value: (_) => <Map<String, dynamic>>[]);

    getAllWords().forEach((word) {
      final firstChar = word['word']![0];
      final consonant = getKoreanConsonant(firstChar);
      if (consonants.contains(consonant)) {
        grouped[consonant]!.add(word);
      }
    });

    return grouped;
  }

  static String getKoreanConsonant(String char) {
    final consonants = 'ㄱㄲㄴㄷㄸㄹㅁㅂㅃㅅㅆㅇㅈㅉㅊㅋㅌㅍㅎ';
    final unicode = char.codeUnitAt(0) - 0xAC00;
    if (unicode < 0 || unicode > 11171) return char;
    return consonants[unicode ~/ 588];
  }
}
