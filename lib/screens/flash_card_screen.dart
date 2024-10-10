import 'package:flutter/material.dart';
import '../word_data.dart';

class FlashCardScreen extends StatefulWidget {
  final String category;

  FlashCardScreen({required this.category});

  @override
  _FlashCardScreenState createState() => _FlashCardScreenState();
}

class _FlashCardScreenState extends State<FlashCardScreen> {
  List<Map<String, String>> categoryWords = [];
  bool isLoading = true;
  int currentIndex = 0;
  bool showDefinition = false;

  @override
  void initState() {
    super.initState();
    _loadCategoryWords();
  }

  Future<void> _loadCategoryWords() async {
    setState(() {
      isLoading = true;
    });

    await WordData.loadWords();
    categoryWords = WordData.getWordsByCategory(widget.category);

    setState(() {
      isLoading = false;
    });
  }

  void _nextCard() {
    setState(() {
      if (currentIndex < categoryWords.length - 1) {
        currentIndex++;
        showDefinition = false;
      }
    });
  }

  void _previousCard() {
    setState(() {
      if (currentIndex > 0) {
        currentIndex--;
        showDefinition = false;
      }
    });
  }

  void _toggleDefinition() {
    setState(() {
      showDefinition = !showDefinition;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('#${widget.category}')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (categoryWords.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('#${widget.category}')),
        body: Center(child: Text('이 카테고리에 단어가 없습니다.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('#${widget.category}')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${currentIndex + 1} / ${categoryWords.length}'),
            SizedBox(height: 20),
            GestureDetector(
              onTap: _toggleDefinition,
              child: Card(
                elevation: 5,
                child: Container(
                  width: 300,
                  height: 200,
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      showDefinition
                          ? categoryWords[currentIndex]['definition'] ?? ''
                          : categoryWords[currentIndex]['word'] ?? '',
                      style: TextStyle(fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _previousCard,
                  child: Icon(Icons.arrow_back),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _nextCard,
                  child: Icon(Icons.arrow_forward),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
