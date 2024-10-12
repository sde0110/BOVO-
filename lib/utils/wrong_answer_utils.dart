import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WrongAnswerUtils {
  static const String _key = 'wrong_answers';

  Future<void> addWrongAnswer(Map<String, String> word) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> wrongAnswers = await _getWrongAnswersMap(prefs);

    String wordKey = word['word']!;
    if (!wrongAnswers.containsKey(wordKey)) {
      wrongAnswers[wordKey] = {'count': 1, 'definition': word['definition']};
    } else {
      wrongAnswers[wordKey]['count'] = wrongAnswers[wordKey]['count'] + 1;
    }

    String encodedData = json.encode(wrongAnswers);
    await prefs.setString(_key, encodedData);
  }

  Future<Map<String, dynamic>> getWrongAnswers() async {
    final prefs = await SharedPreferences.getInstance();
    return await _getWrongAnswersMap(prefs);
  }

  Future<Map<String, dynamic>> _getWrongAnswersMap(
      SharedPreferences prefs) async {
    String? wrongAnswersString = prefs.getString(_key);
    if (wrongAnswersString != null && wrongAnswersString.isNotEmpty) {
      return json.decode(wrongAnswersString);
    }
    return {};
  }

  Future<void> removeWrongAnswer(String word) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> wrongAnswers = await _getWrongAnswersMap(prefs);
    wrongAnswers.remove(word);
    String encodedData = json.encode(wrongAnswers);
    await prefs.setString(_key, encodedData);
  }

  Future<void> clearWrongAnswers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<void> decreaseWrongAnswerCount(String word) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> wrongAnswers = await _getWrongAnswersMap(prefs);

    print('현재 오답 목록: $wrongAnswers'); // 현재 오답 목록 출력

    if (wrongAnswers.containsKey(word)) {
      wrongAnswers[word]['count'] = wrongAnswers[word]['count'] - 1;
      print('$word의 오답 카운트 감소: ${wrongAnswers[word]['count']}'); // 감소된 카운트 출력
      if (wrongAnswers[word]['count'] <= 0) {
        wrongAnswers.remove(word);
        print('$word가 오답 목록에서 제거됨'); // 단어가 제거되었음을 출력
      }
      String encodedData = json.encode(wrongAnswers);
      await prefs.setString(_key, encodedData);
    } else {
      print('$word는 오답 목록에 없음'); // 단어가 오답 목록에 없는 경우 출력
    }

    print('업데이트된 오답 목록: $wrongAnswers'); // 업데이트된 오답 목록 출력
  }
}
