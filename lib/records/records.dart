import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:wenku8/wenku8/client.dart';
import 'package:wenku8/db/db.dart' show db;
import 'package:wenku8/wenku8/webku8.dart';
import '../home.dart';
import '../chapter/chapter.dart' as chapter;
import 'package:flutter_slidable/flutter_slidable.dart';

class _Item {
  Record record;
  _Names names;
}

class _Names {
  String book;
  String vol;
  String chapter;
  _Names.fromMap(Map<String, dynamic> map) {
    book = map["book"];
    vol = map["vol"];
    chapter = map["chapter"];
  }
}

Future<_Names> getNames({int bid, int vid, int cid}) {
  var q = """
  select
    b.name as book,
    v.name as vol,
    c.name as chapter
  from
    books AS b
    join chapters AS c on (c.cid = ${cid})
    join chapters_vols as v on (v.vid = ${vid})
    where b.bid = ${bid}
  """;
  return db.rawQuery(q).then((value) => _Names.fromMap(value.first));
}

Future<List<_Item>> getRecords() async {
  var records = await db
      .query(Record.TableName)
      .then((value) => value.map((e) => Record.fromMap(e)));
  var items = Future.wait(records.map((record) async {
    var item = _Item();
    item.record = record;
    item.names =
        await getNames(bid: record.bid, vid: record.vid, cid: record.cid);
    return item;
  }));
  var a = await Future.wait([
    items,
    Future.delayed(Duration(seconds: 1)),
  ]);
  return a[0];
}

class RecordsRender extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RecordsRenderState();
  }
}

class RecordsRenderState extends State<RecordsRender>
    with AutomaticKeepAliveClientMixin<RecordsRender> {
  @override
  bool get wantKeepAlive => true;

  Future<List<_Item>> data;

  @override
  void initState() {
    super.initState();
    data = getRecords();
  }

  refresh() async {
    var d = getRecords();
    if (data == d) {
      return;
    }
    await d;
    setState(() {
      data = d;
    });
  }

  deleteRecord(int rid) async {
    await db.delete(Record.TableName, where: "rid = ?", whereArgs: [rid]);
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<List<_Item>>(
      future: data,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Column(
            children: [LinearProgressIndicator()],
          );
        }
        var records = snapshot.data;
        if (records.length == 0) {
          return Center(
            child: Text(
              "没有阅读记录, 右滑去搜索页吧",
              style: TextStyle(fontSize: 18),
            ),
          );
        }
        return Scrollbar(
          child: RefreshIndicator(
            onRefresh: () async {
              await refresh();
            },
            child: ListView(
              children: records.map((item) {
                var n = item.names;
                return Slidable(
                  actionPane: SlidableDrawerActionPane(),
                  // actionExtentRatio: 0.25,
                  child: Tooltip(
                    message: "点击继续阅读",
                    child: ListTile(
                      title: Text("${n.book}"),
                      subtitle: Text("${n.vol} - ${n.chapter}"),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          "/chapter",
                          arguments: chapter.ScreenArguments(
                            cid: item.record.cid.toString(),
                          ),
                        );
                      },
                    ),
                  ),
                  secondaryActions: [
                    IconSlideAction(
                      caption: "Delete",
                      color: Colors.red,
                      icon: Icons.delete,
                      onTap: () => deleteRecord(item.record.rid),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class RecordsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HomePageWrapper(
      title: Text("阅读记录"),
      index: 1,
      body: RecordsRender(),
    );
  }
}
