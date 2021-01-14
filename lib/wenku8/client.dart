import '../db/db.dart' show db;
import './webku8.dart';
import './utils.dart' as utils;

class Wenku8Client {
  Future<Book> getBook2(String bid) async {
    var book = await getBook(bid);
    if (book == null) {
      book = await utils.getBook(bid);
      await createBook(book);
    }
    return book;
  }

  Future<Book> getBook(String bid) async {
    var maps =
        await db.query(Book.TableName, where: "bid = ?", whereArgs: [bid]);
    if (maps.length == 0) {
      return null;
    }
    var book = Book.fromMap(maps.first);
    var vols = await db.transaction<List<ChaptersVol>>((txn) async {
      var volsMaps = await txn.query(
        ChaptersVol.TableName,
        where: "bid = ?",
        whereArgs: [bid],
        orderBy: "`order`",
      );
      if (volsMaps.length == 0) {
        return <ChaptersVol>[];
      }
      var vols = <ChaptersVol>[];
      for (var map in volsMaps) {
        var vol = ChaptersVol.fromMap(map);
        var chapterMaps = await txn.query(
          Chapter.TableName,
          where: "bid = ? and vid = ?",
          whereArgs: [vol.bid, vol.vid],
          orderBy: "`order`",
        );
        vol.chapters = chapterMaps.map((e) => Chapter.fromMap(e)).toList();
        vols.add(vol);
      }
      return vols;
    });
    book.chaptersVols = vols;
    return book;
  }

  createBook(Book book) async {
    return db.transaction((txn) async {
      // add book record
      var book2 = Book(
        name: book.name,
        bid: book.bid,
      );
      await txn.insert(Book.TableName, book2.toMap());

      addChapter(int volId) {
        return (Chapter chapter) {
          return txn.insert(
            Chapter.TableName,
            Chapter(
              bid: book.bid,
              vid: volId,
              cid: chapter.cid,
              name: chapter.name,
              order: chapter.order,
            ).toMap(),
          );
        };
      }

      addChaptersVols(ChaptersVol vol) async {
        var volId = await txn.insert(
          ChaptersVol.TableName,
          ChaptersVol(
            bid: book.bid,
            name: vol.name,
            order: vol.order,
          ).toMap(),
        );
        await Future.wait(vol.chapters.map(addChapter(volId)));
      }

      // add vol and chapter records
      await Future.wait(book.chaptersVols.map(addChaptersVols));
    });
  }

  updateBook2(String bid) async {
    var book = await utils.getBook(bid);
    return updateBook(book);
  }

  Future<int> updateBook(Book book) async {
    var lastVol = await db
        .query(
          ChaptersVol.TableName,
          where: "bid = ?",
          whereArgs: [book.bid],
          orderBy: "`order` DESC",
          limit: 1,
        )
        .then((value) => ChaptersVol.fromMap(value.first));
    var lastVolChapter = await db
        .query(
          Chapter.TableName,
          where: "bid = ? and vid = ?",
          whereArgs: [book.bid, lastVol.vid],
          orderBy: "`order` DESC",
          limit: 1,
        )
        .then((value) => Chapter.fromMap(value.first));

    return db.transaction<int>((txn) async {
      var newChapterCount = 0;
      addChapter(int volId) {
        return (Chapter chapter) {
          newChapterCount++;
          return txn.insert(
            Chapter.TableName,
            Chapter(
              bid: book.bid,
              vid: volId,
              cid: chapter.cid,
              name: chapter.name,
              order: chapter.order,
            ).toMap(),
          );
        };
      }

      addChaptersVols(ChaptersVol vol) async {
        var volId = await txn.insert(
          ChaptersVol.TableName,
          ChaptersVol(
            bid: book.bid,
            name: vol.name,
            order: vol.order,
          ).toMap(),
        );
        await Future.wait(vol.chapters.map(addChapter(volId)));
      }

      await Future.wait(
        book.chaptersVols[lastVol.order].chapters
            .sublist(
              lastVolChapter.order + 1,
            )
            .map(
              addChapter(lastVol.vid),
            ),
      );
      await Future.wait(
        book.chaptersVols
            .sublist(
              lastVol.order + 1,
            )
            .map(addChaptersVols),
      );
      return newChapterCount;
    });
  }

  Future<Chapter> getChapter(int cid) async {
    var chapter = await db
        .query(
          Chapter.TableName,
          where: "cid = ?",
          whereArgs: [cid],
          limit: 1,
        )
        .then((value) => Chapter.fromMap(value.first));
    if (chapter.content != null) {
      return chapter;
    }
    var content = await utils.getChapterContent(
      chapter.bid.toString(),
      chapter.cid.toString(),
    );
    await updateChapters(chapter, content);
    return getChapter(cid);
  }

  updateChapters(Chapter chapter, String content) async {
    var strs = content.split(utils.delimiter);
    var chapters = await db.query(
      Chapter.TableName,
      where: "`order` >= ? and bid = ? and vid = ?",
      whereArgs: [chapter.order, chapter.bid, chapter.vid],
    ).then((value) => value.map((e) => Chapter.fromMap(e)).toList());

    var batch = db.batch();
    var index = -1;
    var matcher = new RegExp(r"^\s{2}\S+");
    var str = "";
    // var ss = <String>[];
    addContent() {
      var chapter = chapters[index];
      batch.update(
        Chapter.TableName,
        <String, dynamic>{"content": str},
        where: "cid = ?",
        whereArgs: [chapter.cid],
      );
      // ss.add(str);
    }

    for (var s in strs) {
      var matched = matcher.hasMatch(s);
      if (matched) {
        if (index >= chapters.length - 1) {
          break;
        }
        if (index >= 0) {
          addContent();
        }
        index++;
        str = "";
      }
      str = str + s + "\r\n";
    }
    addContent();
    await batch.commit();
    return;
  }

  Future<ChaptersVol> getChaptersVol(int vid) async {
    return db
        .query(
      ChaptersVol.TableName,
      where: "vid = ?",
      whereArgs: [vid],
      limit: 1,
    )
        .then((value) {
      if (value.length == 0) {
        return null;
      }
      return ChaptersVol.fromMap(value.first);
    });
  }

  Future<Record> getReadRecord(int bid) async {
    Record toRecord(List<Map<String, dynamic>> maps) {
      if (maps.length == 0) {
        return null;
      }
      return Record.fromMap(maps.first);
    }

    var record = await db
        .query(
          Record.TableName,
          where: "bid = ?",
          whereArgs: [bid],
          limit: 1,
        )
        .then((maps) => toRecord(maps));

    return record;
  }

  Future updateReadRecord(int cid) async {
    var chapter = await getChapter(cid);
    var record = await getReadRecord(chapter.bid);
    if (record == null) {
      record = Record(
        bid: chapter.bid,
        vid: chapter.vid,
        cid: chapter.cid,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await db.insert(Record.TableName, record.toMap());
      return;
    }
    await db.update(
      Record.TableName,
      <String, dynamic>{
        "bid": chapter.bid,
        "vid": chapter.vid,
        "cid": chapter.cid,
        "updated_at": DateTime.now().toUtc().millisecondsSinceEpoch,
      },
      where: "bid = ?",
      whereArgs: [chapter.bid],
    );
  }
}

var client = Wenku8Client();
