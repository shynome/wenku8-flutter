import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:gbk2utf8/gbk2utf8.dart' show gbk;
import 'package:utf/utf.dart';
import './webku8.dart';

Future<http.Response> mustGetLink(String link) {
  return http.get(link).then((value) {
    return value;
  });
}

Future<String> getLink(String bid) async {
  var doc = await mustGetLink("https://www.wenku8.net/book/${bid}.htm")
      .then((value) => value.bodyBytes)
      .then((value) => gbk.decode(value))
      .then((value) => parse(value));
  var a = doc.querySelector("#content fieldset a");
  return a.attributes["href"];
}

ChaptersVol _getEmptyVol() => ChaptersVol(name: "", chapters: []);

Future<Book> getChaptersVol(String link, String bid) async {
  var doc = await mustGetLink(link)
      .then((value) => value.bodyBytes)
      .then((value) => gbk.decode(value))
      .then((value) => parse(value));
  var nodes = doc.querySelectorAll(".css td");
  var vols = <ChaptersVol>[];
  ChaptersVol vol;
  var volOrder = 0;
  for (var i = 0; i < nodes.length; i++) {
    var n = nodes[i];
    if (n.classes.contains("vcss")) {
      vol = _getEmptyVol();
      vol.name = n.text;
      vol.order = volOrder++;
      vols.add(vol);
      continue;
    }
    var a = n.querySelector("a");
    if (a == null) {
      // 跳过填充用的 td
      continue;
    }
    var cid = int.parse(
      a.attributes["href"].substring(0, a.attributes["href"].length - 4),
    );
    var chapter = Chapter(
      name: a.text,
      cid: cid,
      order: vol.chapters.length,
    );
    vol.chapters.add(chapter);
  }
  var book = Book(
    bid: int.parse(bid),
    name: doc.querySelector("#title").text,
    chaptersVols: vols,
  );
  return book;
}

Future<Book> getBook(String bid) async {
  var link = await getLink(bid);
  var book = await getChaptersVol(link, bid);
  return book;
}

var delimiter = new RegExp(r'\s+\r\n');

Future<String> getChapterContent(String bid, String cid) async {
  var link =
      "http://dl.wenku8.com/packtxt.php?aid=${bid}&vid=${cid}&aname=1&vname=1";
  var content =
      await mustGetLink(link).then((value) => decodeUtf16le(value.bodyBytes));
  return content;
}
