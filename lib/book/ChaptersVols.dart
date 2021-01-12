import 'package:flutter/material.dart';
import 'package:wenku8/wenku8/client.dart';
import '../wenku8/webku8.dart' as wenku8;
import '../chapter.dart' as chapter;
import 'package:fluttertoast/fluttertoast.dart';
import './book.dart' show ScreenArguments;

class ChaptersVol extends StatelessWidget {
  final wenku8.ChaptersVol vol;
  final String bid;
  ChaptersVol(this.bid, this.vol);
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 5),
              child: Text(
                vol.name,
                style: TextStyle(fontSize: 18),
              ),
            ),
            Divider(),
            Container(
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 15),
              child: Wrap(
                spacing: 10.0,
                runSpacing: 10.0,
                children: vol.chapters.map((e) {
                  return ButtonTheme(
                    minWidth: 0,
                    child: OutlineButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          "/chapter",
                          arguments: chapter.ScreenArguments(
                            bid,
                            e.cid.toString(),
                          ),
                        );
                      },
                      child: Text(e.name),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChaptersVols extends StatelessWidget {
  final wenku8.Book book;
  ChaptersVols(this.book);

  refresh(BuildContext context) async {
    var newChapterCount = await client.updateBook2(book.bid.toString());
    if (newChapterCount == 0) {
      Fluttertoast.showToast(msg: "没有新的章节");
      return;
    }
    Fluttertoast.showToast(msg: "有新章节, 刷新页面中");
    Navigator.pushReplacementNamed(
      context,
      "/book",
      arguments: ScreenArguments(bid: book.bid.toString()),
    );
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.book.name),
        actions: <Widget>[
          Tooltip(
            message: "点击刷新, 获取最新数据",
            child: IconButton(
              icon: Icon(Icons.refresh_outlined),
              onPressed: () => refresh(context),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: book.chaptersVols
            .map((e) => ChaptersVol(book.bid.toString(), e))
            .toList(),
      ),
    );
  }
}
