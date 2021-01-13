import 'package:flutter/material.dart';
import 'package:wenku8/book/download.dart';
import 'package:wenku8/wenku8/client.dart' show client;
import 'package:wenku8/wenku8/webku8.dart';
import './clearCache.dart';

class Header extends StatefulWidget {
  Book book;
  Header(this.book);
  @override
  State<StatefulWidget> createState() {
    return HeaderState();
  }
}

class HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 5),
              child: Wrap(
                children: [
                  Text(
                    widget.book.name,
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            Divider(),
            Container(
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 15),
              child: Wrap(
                spacing: 10.0,
                runSpacing: 10.0,
                children: [
                  DownloadButton(widget.book),
                  ClearCacheButton(widget.book.bid),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
