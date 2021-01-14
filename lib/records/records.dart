import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:wenku8/wenku8/client.dart';
import 'package:wenku8/db/db.dart' show db;
import 'package:wenku8/wenku8/webku8.dart';
import '../home.dart';
import '../chapter/chapter.dart' as chapter;
import 'package:flutter_slidable/flutter_slidable.dart';
import '../wenku8/records-changed-count.dart' show count;

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

  GlobalKey<RefreshIndicatorState> _indicatorKey =
      GlobalKey<RefreshIndicatorState>();

  Future<List<_Item>> data;
  List<_Item> items;
  int lastCount;

  @override
  void initState() {
    super.initState();
    data = getRecords();
    lastCount = count.value;
  }

  deleteRecord(int rid) async {
    await db.delete(Record.TableName, where: "rid = ?", whereArgs: [rid]);
    count.value++;
    _indicatorKey.currentState.show();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (lastCount != count.value) {
      setState(() {
        lastCount = count.value;
        _indicatorKey.currentState.show();
      });
    }

    return RefreshIndicator(
      key: _indicatorKey,
      onRefresh: () async {
        var _items = await getRecords();
        setState(() {
          // 重置 count.value
          count.value = 0;
          items = _items;
          lastCount = 0;
        });
      },
      child: FutureBuilder<List<_Item>>(
        future: data,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Column(
              children: [LinearProgressIndicator()],
            );
          }
          var records = items ?? snapshot.data;
          if (records.length == 0) {
            return Center(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                    child: Wrap(
                      children: [
                        Text(
                          "没有阅读记录, 右滑去搜索页吧",
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          }
          return Scrollbar(
            child: ListView.separated(
              itemCount: records.length,
              separatorBuilder: (context, index) => Divider(),
              itemBuilder: (context, index) {
                var item = records[index];
                var n = item.names;
                return Slidable(
                  actionPane: SlidableDrawerActionPane(),
                  key: Key(item.record.bid.toString()),
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
              },
            ),
          );
        },
      ),
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
