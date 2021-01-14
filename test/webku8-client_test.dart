import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wenku8/wenku8/client.dart' show client;
import 'package:wenku8/wenku8/utils.dart' as utils;
import 'package:test/test.dart';
import 'package:wenku8/db/db.dart' show init;
import 'package:wenku8/db/db.dart' show db;
import 'package:wenku8/wenku8/webku8.dart';

void main() async {
  sqfliteFfiInit();
  await init(dbPath: "/tmp/test.db");
  group("wenku8 client", () {
    test("createBook", () async {
      var book = await utils.getBook("1861");
      await client.createBook(book);
      return;
    });
    test("getBook", () async {
      var book = await client.getBook("1861");
      return;
    });

    test("updateBook", () async {
      var book = await utils.getBook("1861");
      await client.updateBook(book);
      return;
    });
    test("getChapter", () async {
      var chapter = await client.getChapter(65286);
      return;
    });
    test("getChapter", () async {
      await client.updateReadRecord(65286);
      return;
    });
  });
}
