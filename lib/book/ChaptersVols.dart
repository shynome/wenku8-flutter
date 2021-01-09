import 'package:flutter/material.dart';
import '../webku8.dart' as wenku8;
import '../chapter.dart' as chapter;

class ChaptersVol extends StatelessWidget {
  final wenku8.ChaptersVol vol;
  final String bid;
  ChaptersVol(this.bid, this.vol);
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(
              title: Text(vol.name),
            ),
            Divider(),
            Container(
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 15),
              child: Wrap(
                spacing: 10.0,
                runSpacing: 10.0,
                children: vol.chapters.map((e) {
                  return ButtonTheme(
                    minWidth: 0,
                    child: OutlineButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          "/chapter",
                          arguments: chapter.ScreenArguments(bid, e.cid),
                        );
                      },
                      child: Text(e.name),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChaptersVols extends StatelessWidget {
  final wenku8.Book book;
  ChaptersVols(this.book);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.book.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children:
            book.chaptersVols.map((e) => ChaptersVol(book.bid, e)).toList(),
      ),
    );
  }
}
