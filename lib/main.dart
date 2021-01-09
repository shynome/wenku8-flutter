import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wenku8/chapter.dart';
import './search.dart';
import 'book/book.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    return MaterialApp(
      title: 'wenku8 reader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: "/search",
      routes: {
        "/search": (context) => SearchPage(),
        "/book": (context) => BookPage(),
        '/chapter': (context) => ChapterPage(),
      },
    );
  }
}
