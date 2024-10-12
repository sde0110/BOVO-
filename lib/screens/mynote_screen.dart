import 'package:flutter/material.dart';

class MyNoteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내 단어장'),
      ),
      body: Center(
        child: Text('내 단어장 화면'),
      ),
    );
  }
}
