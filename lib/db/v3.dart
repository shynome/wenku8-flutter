import 'package:sqflite/sqflite.dart';

createTableRecord(Batch batch) {
  batch.execute('DROP TABLE IF EXISTS records');
  batch.execute('''
  CREATE TABLE records (
    `rid` INTEGER PRIMARY KEY AUTOINCREMENT,
    `bid` INTEGER NOT NULL,
    `vid` INTEGER NOT NULL,
    `cid` INTEGER NOT NULL,
    `offset` INTEGER,
    -- datetime
    `updated_at` INTEGER NOT NULL,
    -- datetime
    `created_at` INTEGER NOT NULL
  )
  ''');
}

updateTableRecord(Batch batch) {
  batch.execute('''
  ALTER TABLE records ADD COLUMN `offset` INTEGER
  ''');
}
