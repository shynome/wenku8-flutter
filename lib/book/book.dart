import 'package:flutter/material.dart';
import './notfound.dart';
import './ChaptersVols.dart';
import '../webku8.dart';
import '../webku8-client.dart';

class BookPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BookPageState();
  }
}

class ScreenArguments {
  String bid;
  ScreenArguments(this.bid);
}

class BookPageState extends State<BookPage> {
  Future<Book> book;
  String id;

  @override
  Widget build(BuildContext context) {
    final ScreenArguments args = ModalRoute.of(context).settings?.arguments;
    if (args?.bid == null) {
      return BookNotFoundPage();
    }
    if (args.bid != id) {
      setState(() {
        book = getBook(args.bid);
        id = args.bid;
      });
    }
    return FutureBuilder<Book>(
      future: book,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(
              title: Text("加载中"),
            ),
            body: LinearProgressIndicator(),
          );
        }
        return ChaptersVols(snapshot.data);
      },
    );
  }
}
