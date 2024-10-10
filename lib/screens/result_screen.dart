import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final String category;

  const ResultScreen({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$category 용어'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('선택된 카테고리: $category'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
              child: const Text('메인 화면으로'),
            ),
          ],
        ),
      ),
    );
  }
}
