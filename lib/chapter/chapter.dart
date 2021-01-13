import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wenku8/wenku8/client.dart';
import 'package:wenku8/wenku8/webku8.dart';
import '../wenku8/utils.dart';
import './next.dart';

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
  Body(this.appBar, this.child);
  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: CustomScrollView(
        slivers: [appBar, child],
      ),
    );
  }
}

class FState {
  List<String> content;
  Chapter chapter;
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
        f = client.getChapter(int.parse(args.cid)).then((chapter) {
          var f = FState();
          f.content = chapter.content.split("\r\n");
          chapter.content = "";
          f.chapter = chapter;
          return f;
        });
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
          List<Widget> list = snapshot.data.content
              .map((p) => Text(p + "\r\n", style: TextStyle(fontSize: 16)))
              .map((p) => Container(child: p))
              .toList();
          list.add(Container(child: NextChapter(chapter)));
          return Body(
            SliverAppBar(
              title: Text(chapter.name),
              floating: true,
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 75),
              sliver: SliverList(delegate: SliverChildListDelegate(list)),
            ),
          );
        },
      ),
    );
  }
}
