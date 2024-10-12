import 'package:flutter/material.dart';
import 'main_screen.dart';
import 'search_screen.dart';
import 'word_list_screen.dart';

// WordDetailScreen: 단어의 상세 정보를 표시하는 화면
class WordDetailScreen extends StatelessWidget {
  final Map<String, dynamic> word; // 단어 정보를 담은 Map
  final Color primaryColor = const Color(0xFF1E3859);

  const WordDetailScreen({Key? key, required this.word}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('', style: TextStyle(color: Color(0xFF1E3859))),
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: primaryColor,
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  word['word'] ?? '',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('정의'),
                  const SizedBox(height: 16),
                  _buildContentCard(word['definition'] ?? ''),
                  const SizedBox(height: 32),
                  _buildExampleSection('예문 1', word['example1']),
                  _buildExampleSection('예문 2', word['example2']),
                ],
              ),
            ),
          ],
        ),
      ),
      // 네비게이션 바 제거
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: primaryColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildContentCard(String content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Text(
        content,
        style: TextStyle(
            color: primaryColor.withOpacity(0.8), fontSize: 16, height: 1.5),
      ),
    );
  }

  Widget _buildExampleSection(String title, String? example) {
    if (example == null || example.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        const SizedBox(height: 16),
        _buildContentCard(example),
        const SizedBox(height: 32),
      ],
    );
  }
}
