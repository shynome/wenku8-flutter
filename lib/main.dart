import 'package:flutter/material.dart';
import 'package:wenku8/chapter/chapter.dart';
import 'package:wenku8/records/records.dart';
import './search.dart';
import 'book/book.dart';
import './home.dart';
import './about.dart';
import 'db/db.dart' as db;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await db.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'wenku8 reader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: "/home",
      routes: {
        "/home": (context) => HomePage(),
        "/about": (context) => AboutPage(),
        "/search": (context) => SearchPage(),
        "/book": (context) => BookPage(),
        '/chapter': (context) => ChapterPage(),
        '/records': (context) => RecordsPage(),
      },
    );
  }
}
