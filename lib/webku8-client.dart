import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:gbk2utf8/gbk2utf8.dart' show gbk;
import 'package:utf/utf.dart';
import './webku8.dart';

Future<String> getLink(String bid) async {
  var doc = await http
      .get("https://www.wenku8.net/book/${bid}.htm")
      .then((value) => value.bodyBytes)
      .then((value) => gbk.decode(value))
      .then((value) => parse(value));
  var a = doc.querySelector("#content fieldset a");
  return a.attributes["href"];
}

ChaptersVol _getEmptyVol() => ChaptersVol("", []);

Future<Book> getChaptersVol(String link, String bid) async {
  var doc = await http
      .get(link)
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
    var aList = n.querySelectorAll("a");
    if (aList.length == 0) {
      // 跳过填充用的 td
      continue;
    }
    var a = aList.first;
    var cid = a.attributes["href"];
    var name = a.text;
    var chapter = Chapter(
      name,
      cid,
      vol.chapters.length,
    );
    vol.chapters.add(chapter);
  }
  var book = Book();
  book.bid = bid;
  book.name = doc.querySelector("#title").text;
  book.chaptersVols = vols;
  return book;
}

Future<Book> getBook(String bid) async {
  var link = await getLink(bid);
  var book = await getChaptersVol(link, bid);
  return book;
}

var delimiter = new RegExp(r'\s+\r\n');

Future<String> getChapterContent(String bid, String cid) async {
  var content = await http
      .get(
          "http://dl.wenku8.com/packtxt.php?aid=${bid}&vid=${cid}&aname=1&vname=1")
      .then((value) => decodeUtf16le(value.bodyBytes));
  return content;
}
