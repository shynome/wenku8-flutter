import 'package:flutter/material.dart';
import 'package:wenku8/wenku8/client.dart';
import '../db/db.dart' show db;
import '../wenku8/webku8.dart';
import './chapter.dart' show ScreenArguments;

class NextChapter extends StatefulWidget {
  final Chapter chapter;
  NextChapter(this.chapter);
  @override
  State<StatefulWidget> createState() {
    return NextChapterState();
  }
}

class FState {
  final Chapter chapter;
  final ChaptersVol vol;
  FState({this.chapter, this.vol});
}

Future<FState> getNextChapter(Chapter chapter) async {
  var columns = ["bid", "vid", "`order`", "cid", "name"];
  Chapter map2Chapter(List<Map<String, dynamic>> value) {
    if (value.length == 0) {
      return null;
    }
    return Chapter.fromMap(value.first);
  }

  ChaptersVol map2Vol(List<Map<String, dynamic>> value) {
    if (value.length == 0) {
      return null;
    }
    return ChaptersVol.fromMap(value.first);
  }

  var nChapter = await db
      .query(
        Chapter.TableName,
        where: "`order` = ? and bid = ? and vid = ?",
        whereArgs: [chapter.order + 1, chapter.bid, chapter.vid],
        columns: columns,
        limit: 1,
      )
      .then(map2Chapter);
  var vol = await db
      .query(
        ChaptersVol.TableName,
        where: "vid = ?",
        whereArgs: [chapter.vid],
        limit: 1,
      )
      .then(map2Vol);
  if (nChapter != null) {
    return FState(chapter: nChapter, vol: vol);
  }

  var nVol = await db
      .query(
        ChaptersVol.TableName,
        where: "`order` = ? and bid = ?",
        whereArgs: [vol.order + 1, vol.bid],
        limit: 1,
      )
      .then(map2Vol);
  if (nVol == null) {
    return null;
  }
  nChapter = await db
      .query(
        Chapter.TableName,
        where: "`order` = 0 and bid = ? and vid = ?",
        whereArgs: [nVol.bid, nVol.vid],
        columns: columns,
        limit: 1,
      )
      .then(map2Chapter);
  return FState(chapter: nChapter, vol: nVol);
}

class NextChapterState extends State<NextChapter> {
  Future<FState> f;
  int id;

  @override
  Widget build(BuildContext context) {
    if (widget.chapter.cid != id) {
      setState(() {
        f = getNextChapter(widget.chapter);
      });
    }

    return FutureBuilder<FState>(
        future: f,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return OutlineButton(
              child: Text("加载数据中"),
              onPressed: null,
            );
          }
          if (snapshot.data == null) {
            return OutlineButton(
              child: Text("没有更多了"),
              onPressed: null,
            );
          }
          var chapter = snapshot.data.chapter;
          var vol = snapshot.data.vol;
          var txt = "下一章节: ${chapter.name}";
          if (widget.chapter.vid != vol.vid) {
            txt = "下一章: ${vol.name} - ${chapter.name}";
          }
          return OutlineButton(
            child: Wrap(children: [Text(txt)]),
            onPressed: () {
              Navigator.pushReplacementNamed(
                context,
                "/chapter",
                arguments: ScreenArguments(cid: chapter.cid.toString()),
              );
            },
          );
        });
  }
}
