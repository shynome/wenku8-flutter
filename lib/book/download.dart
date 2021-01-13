import 'package:flutter/material.dart';
import 'package:wenku8/wenku8/client.dart';
import 'package:wenku8/wenku8/utils.dart' as utils;
import 'package:wenku8/wenku8/webku8.dart';
import 'package:wenku8/db/db.dart' show db;

class DownloadButton extends StatefulWidget {
  Book book;
  DownloadButton(this.book);
  @override
  State<StatefulWidget> createState() {
    return DownloadButtonState();
  }
}

class DownloadButtonState extends State<DownloadButton> {
  int downloadingState = 0;
  int okCount = 0;
  int failedCount = 0;
  int allCount = -1;
  int get progress {
    return okCount + failedCount;
  }

  _download() async {
    var list = await db.query(
      Chapter.TableName,
      where: "bid = ? and `order` = 0 and content is null",
      whereArgs: [widget.book.bid],
    ).then(
      (value) => value.map((e) => Chapter.fromMap(e)),
    );
    setState(() {
      allCount = list.length;
    });
    var list2 = list.map((chapter) async {
      if (chapter.content != null) {
        setState(() {
          okCount++;
        });
        return;
      }
      try {
        var content = await utils.getChapterContent(
          chapter.bid.toString(),
          chapter.cid.toString(),
        );
        await client.updateChapters(chapter, content);
        setState(() {
          okCount++;
        });
      } catch (e) {
        setState(() {
          failedCount++;
        });
      }
    });
    await Future.wait([
      Future.wait(list2),
      Future.delayed(Duration(seconds: 2)), //最少显示一秒中, 避免切换突兀
    ]);
    if (list.length == 0) {
      return;
    }
    setState(() {
      downloadingState = 2;
    });
    await Future.delayed(Duration(seconds: 2));
  }

  download() async {
    if (downloadingState > 0) {
      return;
    }
    setState(() {
      downloadingState = 1;
    });
    try {
      await _download();
    } finally {
      setState(() {
        downloadingState = 0;
        okCount = 0;
        failedCount = 0;
        allCount = -1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var handlePressed = () => download();
    var text = "全部下载";
    if (downloadingState > 0) {
      handlePressed = null;
      text = "下载中 ${progress}/${allCount}";
      if (downloadingState == 2) {
        text = "下载完成 ${progress}/${allCount}";
      } else if (allCount == 0) {
        text = "全部都下载完成了 ${progress}/${allCount}";
      }
    }
    return OutlineButton(
      onPressed: handlePressed,
      child: Text(text),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
