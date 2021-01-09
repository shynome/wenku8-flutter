import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './webku8-client.dart';

class ChapterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ChapterPageState();
  }
}

class ScreenArguments {
  String bid;
  String cid;
  ScreenArguments(this.bid, this.cid);
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

class ChapterPageState extends State<ChapterPage> {
  Future<List<String>> content;
  String id;

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    super.dispose();
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ScreenArguments args = ModalRoute.of(context).settings?.arguments;

    var cid = args.bid + args.cid;
    if (cid != id) {
      setState(() {
        content = getChapterContent(args.bid, args.cid)
            .then((value) => value.split(delimiter));
        id = cid;
      });
    }

    return Scaffold(
      body: FutureBuilder<List<String>>(
        future: content,
        builder: (ctx, snapshot) {
          var appBar = SliverAppBar(
            title: Text(args.bid),
            floating: true,
          );
          if (snapshot.connectionState != ConnectionState.done) {
            return Body(
              appBar,
              SliverToBoxAdapter(child: LinearProgressIndicator()),
            );
          }
          var list = snapshot.data
              .map((p) => Text(p + "\r\n", style: TextStyle(fontSize: 16)))
              .toList();
          return Body(
            appBar,
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
