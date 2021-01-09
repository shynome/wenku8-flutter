import 'package:flutter/material.dart';
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

class ChapterPageState extends State<ChapterPage> {
  Future<String> content;
  String id;

  @override
  Widget build(BuildContext context) {
    final ScreenArguments args = ModalRoute.of(context).settings?.arguments;

    var cid = args.bid + args.cid;
    if (cid != id) {
      setState(() {
        content = getChapterContent(args.bid, args.cid);
        id = cid;
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(args.bid),
      ),
      body: FutureBuilder<String>(
        future: content,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return LinearProgressIndicator();
          }
          return SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 75),
              child: Text(snapshot.data),
            ),
          );
        },
      ),
    );
  }
}
