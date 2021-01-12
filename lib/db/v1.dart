import 'package:sqflite/sqflite.dart';

createTableBook(Batch batch) {
  batch.execute('DROP TABLE IF EXISTS books');
  batch.execute('''
  CREATE TABLE books (
    `bid` INTEGER PRIMARY KEY,
    `name` TEXT NOT NULL
  )
  ''');
}

createChaptersVol(Batch batch) {
  batch.execute('DROP TABLE IF EXISTS chapters_vols');
  batch.execute('''
  CREATE TABLE chapters_vols (
    `vid` INTEGER PRIMARY KEY AUTOINCREMENT,
    `bid` INTEGER NOT NULL,
    `order` INTEGER NOT NULL,
    `name` TEXT
  )
  ''');
}

createcreateChapter(Batch batch) {
  batch.execute('DROP TABLE IF EXISTS chapters');
  batch.execute('''
  CREATE TABLE chapters (
    `cid` INTEGER PRIMARY KEY,
    `bid` INTEGER NOT NULL,
    `vid` INTEGER NOT NULL,
    `order` INTEGER NOT NULL,
    `name` TEXT NOT NULL,
    `content` TEXT
  )
  ''');
}
