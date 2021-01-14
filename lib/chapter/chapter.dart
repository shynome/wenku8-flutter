import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wenku8/wenku8/client.dart';
import 'package:wenku8/wenku8/webku8.dart';
import '../wenku8/utils.dart';
import './next.dart';
import '../book/book.dart' as book;

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

class Body extends StatelessWidget {
  final Widget appBar;
  final Widget child;
  final Widget last;
  Body(this.appBar, this.child, [this.last]);
  @override
  Widget build(BuildContext context) {
    var l = [appBar, child];
    if (last != null) {
      l.add(last);
    }
    return Scrollbar(
      child: CustomScrollView(
        slivers: l,
      ),
    );
  }
}

class FState {
  List<String> content;
  Chapter chapter;
  ChaptersVol vol;
}

Future<FState> getFState(String _cid) async {
  var f = FState();
  var cid = int.parse(_cid);
  var chapter = await client.getChapter(cid);
  f.content = chapter.content.split("\r\n");
  chapter.content = "";
  f.chapter = chapter;
  f.vol = await client.getChaptersVol(chapter.vid);
  // 更新阅读记录
  client.updateReadRecord(cid);
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
            return Body(
              SliverAppBar(
                title: Text("加载中"),
                floating: true,
              ),
              SliverToBoxAdapter(child: LinearProgressIndicator()),
            );
          }
          var chapter = snapshot.data.chapter;
          var content = snapshot.data.content;
          var vol = snapshot.data.vol;
          return Body(
            SliverAppBar(
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
                    Navigator.pushReplacementNamed(
                      context,
                      "/book",
                      arguments: book.ScreenArguments(
                        bid: chapter.bid.toString(),
                        replacHistory: true,
                      ),
                    );
                  },
                )
              ],
            ),
            SliverPadding(
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
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(15, 5, 15, 100),
              sliver: SliverToBoxAdapter(child: NextChapter(chapter)),
            ),
          );
        },
      ),
    );
  }
}
