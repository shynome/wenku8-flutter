import 'package:flutter/material.dart';
import 'package:wenku8/wenku8/client.dart';
import 'package:wenku8/wenku8/webku8.dart';
import './next.dart';
import '../book/book.dart' as book;
import 'dart:async';

class ChapterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ChapterPageState();
  }
}

class ScreenArguments {
  String cid;
  ScreenArguments({this.cid});
}

class Body extends StatefulWidget {
  final Widget appBar;
  final Widget child;
  final Widget last;
  final int cid;
  final int offset;
  Body({this.appBar, this.child, this.last, this.cid, this.offset});
  @override
  State<StatefulWidget> createState() {
    return BodyState();
  }
}

class BodyState extends State<Body> {
  ScrollController _controller;
  Timer timer;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController(
      initialScrollOffset: widget.offset.toDouble(),
    );
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      var offset = _controller.offset.toInt();
      client.updateReadRecord(widget.cid, offset);
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _controller,
      child: CustomScrollView(
        controller: _controller,
        slivers: [
          widget.appBar,
          widget.child,
          widget.last,
        ],
      ),
    );
  }
}

class FState {
  List<String> content;
  Chapter chapter;
  ChaptersVol vol;
  Record record;
}

Future<FState> getFState(String _cid) async {
  var f = FState();
  var cid = int.parse(_cid);
  var chapter = await client.getChapter(cid);
  f.content = chapter.content.split("\r\n");
  chapter.content = "";
  f.chapter = chapter;
  f.vol = await client.getChaptersVol(chapter.vid);
  f.record = await client.getReadRecord(chapter.bid);
  // 更新阅读记录
  client.updateReadRecord(cid, 0);
  return f;
}

class ChapterPageState extends State<ChapterPage> {
  Future<FState> f;
  String id;
  Chapter chapter;

  @override
  Widget build(BuildContext context) {
    final ScreenArguments args = ModalRoute.of(context).settings?.arguments;

    var cid = args.cid;
    if (cid != id) {
      setState(() {
        f = getFState(cid);
        id = cid;
      });
    }

    return Scaffold(
      body: FutureBuilder<FState>(
        future: f,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Scrollbar(
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    title: Text("加载中"),
                    floating: true,
                  ),
                  SliverToBoxAdapter(child: LinearProgressIndicator()),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Scrollbar(
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    title: Text("出错了"),
                    floating: true,
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("加载数据出错了"),
                          Text("可能原因是:"),
                          Text("- 网络请求出错 --> 检查网络是否连通"),
                          Text("- 该书解析失败 --> 向开发者反馈 '书名+${args.cid}' 解析失败"),
                          OutlineButton(
                            child: Text("点击重试"),
                            onPressed: () {
                              setState(() {
                                f = getFState(cid);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          var chapter = snapshot.data.chapter;
          var content = snapshot.data.content;
          var record = snapshot.data.record;
          var vol = snapshot.data.vol;
          var offset = 0;
          if (record != null && record.cid == chapter.cid) {
            offset = record.offset;
          }
          return Body(
            cid: chapter.cid,
            offset: offset,
            last: SliverPadding(
              padding: const EdgeInsets.fromLTRB(15, 5, 15, 100),
              sliver: SliverToBoxAdapter(child: NextChapter(chapter)),
            ),
            appBar: SliverAppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(vol.name),
                  Text(chapter.name, style: TextStyle(fontSize: 14)),
                ],
              ),
              floating: true,
              actions: [
                IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      "/book",
                      arguments: book.ScreenArguments(
                        bid: chapter.bid.toString(),
                        popMode: true,
                        vid: chapter.vid,
                      ),
                    );
                  },
                )
              ],
            ),
            child: SliverPadding(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    var p = snapshot.data.content[index];
                    return Text(p + "\r\n", style: TextStyle(fontSize: 16));
                  },
                  childCount: content.length,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
