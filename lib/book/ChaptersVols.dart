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

class ChaptersVols extends StatefulWidget {
  final wenku8.Book book;
  ChaptersVols(this.book);

  @override
  State<StatefulWidget> createState() {
    return ChaptersVolsState();
  }
}

class ChaptersVolsState extends State<ChaptersVols> {
  bool refreshing = false;
  _refresh(BuildContext context) async {
    Fluttertoast.showToast(msg: "查询新章节中");
    var newChapterCount = await client.updateBook2(widget.book.bid.toString());
    if (newChapterCount == 0) {
      Fluttertoast.showToast(msg: "没有新的章节");
      return;
    }
    Fluttertoast.showToast(msg: "有新章节, 刷新页面中");
    Navigator.pushReplacementNamed(
      context,
      "/book",
      arguments: ScreenArguments(bid: widget.book.bid.toString()),
    );
    return;
  }

  refresh(BuildContext context) async {
    if (refreshing) {
      return;
    }
    setState(() {
      refreshing = true;
    });
    try {
      await _refresh(context);
    } finally {
      setState(() {
        refreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var handlePressed = () => refresh(context);
    if (refreshing) {
      handlePressed = null;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.name),
        actions: <Widget>[
          Tooltip(
            message: "点击刷新, 获取最新数据",
            child: IconButton(
              icon: Icon(Icons.refresh_outlined),
              onPressed: handlePressed,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: widget.book.chaptersVols
            .map((e) => ChaptersVol(widget.book.bid.toString(), e))
            .toList(),
      ),
    );
  }
}
