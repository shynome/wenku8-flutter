import 'package:flutter/material.dart';

class BookNotFoundPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("没有找到对应书籍"),
      ),
      body: Center(
        child: OutlineButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, "/search");
          },
          child: Text("去往输入页"),
        ),
      ),
    );
  }
}
