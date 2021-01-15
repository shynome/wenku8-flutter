import 'package:flutter/material.dart';
import 'package:wenku8/wenku8/client.dart' show client;
import './notfound.dart';
import './ChaptersVols.dart';
import '../wenku8/webku8.dart';

class BookPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BookPageState();
  }
}

class ScreenArguments {
  String bid;
  bool popMode = false;
  ScreenArguments({this.bid, this.popMode});
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
        book = client.getBook2(args.bid);
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
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text("出错了"),
            ),
            body: Container(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("加载数据出错了"),
                  Text("可能原因是:"),
                  Text("- 网络请求出错 --> 检查网络是否连通"),
                  Text("- 该书不存在 --> 检查bid是否输入正确(当前bid=${args.bid})"),
                  OutlineButton(
                    child: Text("点击重试"),
                    onPressed: () {
                      setState(() {
                        book = client.getBook2(args.bid);
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        }
        return ChaptersVols(
          book: snapshot.data,
          popMode: args.popMode ?? false,
        );
      },
    );
  }
}
