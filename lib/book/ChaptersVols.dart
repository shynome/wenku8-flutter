import 'package:flutter/material.dart';
import 'package:wenku8/wenku8/client.dart';
import '../wenku8/webku8.dart' as wenku8;
import '../chapter/chapter.dart' as chapter;
import 'package:fluttertoast/fluttertoast.dart';
import './book.dart' show ScreenArguments;
import './header.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

RoutePredicate popCount(int count) {
  var cursor = 0;
  return (Route<dynamic> route) {
    cursor++;
    if (cursor <= count) {
      return false;
    }
    return true;
  };
}

class ChaptersVol extends StatelessWidget {
  final wenku8.ChaptersVol vol;
  final bool popMode;
  final int cid;
  ChaptersVol({this.vol, this.popMode, this.cid});
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
                children: vol.chapters.map((vol) {
                  var handlePressed = () {
                    if (popMode) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        "/chapter",
                        popCount(2),
                        arguments:
                            chapter.ScreenArguments(cid: vol.cid.toString()),
                      );
                      return;
                    }
                    Navigator.pushNamed(
                      context,
                      "/chapter",
                      arguments:
                          chapter.ScreenArguments(cid: vol.cid.toString()),
                    );
                  };
                  BorderSide borderSide;
                  if (vol.cid == cid) {
                    borderSide =
                        BorderSide(color: Theme.of(context).textSelectionColor);
                  }
                  return ButtonTheme(
                    minWidth: 0,
                    child: OutlineButton(
                      onPressed: handlePressed,
                      child: Text(vol.name),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      borderSide: borderSide,
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
  final bool popMode;
  final int position;
  final int cid;
  ChaptersVols({this.book, this.popMode, this.position = -1, this.cid});

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
    var list = <Widget>[
      Header(widget.book),
    ];
    list.addAll(
      widget.book.chaptersVols.map(
        (vol) =>
            ChaptersVol(vol: vol, popMode: widget.popMode, cid: widget.cid),
      ),
    );
    list = list.map((e) => Container(child: e)).toList();
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
      body: Scrollbar(
        child: ScrollablePositionedList.builder(
          padding: const EdgeInsets.all(8),
          itemCount: list.length,
          initialScrollIndex: widget.position + 1, //因为最上面有个操作栏
          itemBuilder: (context, index) {
            return list[index];
          },
        ),
      ),
    );
  }
}
