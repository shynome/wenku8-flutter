import 'package:flutter/material.dart';
import 'package:wenku8/db/db.dart' show db;
import 'package:wenku8/wenku8/webku8.dart';

class ClearCacheButton extends StatefulWidget {
  final int bid;
  ClearCacheButton(this.bid);
  @override
  State<StatefulWidget> createState() {
    return ClearCacheButtonState();
  }
}

class ClearCacheButtonState extends State<ClearCacheButton> {
  int progressState = 0;

  _clearCache(int bid) async {
    var r = db.update(
      Chapter.TableName,
      <String, dynamic>{"content": null},
      where: "bid = ?",
      whereArgs: [bid],
    );
    await Future.wait([
      r,
      Future.delayed(Duration(seconds: 2)),
    ]);
    setState(() {
      progressState = 2;
    });
    await Future.delayed(Duration(seconds: 2));
  }

  clearCache() async {
    if (progressState > 0) {
      return;
    }
    setState(() {
      progressState = 1;
    });
    try {
      await _clearCache(widget.bid);
    } finally {
      setState(() {
        progressState = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var handlePressed = () => clearCache();
    var text = "清除已下载的章节";

    if (progressState > 0) {
      handlePressed = null;
      text = "清除中...";
      if (progressState == 2) {
        text = "清除完成";
      }
    }
    return OutlineButton(
      onPressed: handlePressed,
      child: Text(text),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
