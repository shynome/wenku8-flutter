import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;
import 'package:path/path.dart' as path;
import './v1.dart' as v1;

Database db;

Future<void> init({String dbPath}) async {
  if (db != null) {
    return;
  }
  dbPath ??= path.join(await getDatabasesPath(), "wenku8.db");
  var options = OpenDatabaseOptions(
    version: 1,
    onCreate: (db, version) async {
      var batch = db.batch();
      v1.createTableBook(batch);
      v1.createChaptersVol(batch);
      v1.createcreateChapter(batch);
      await batch.commit();
    },
  );
  DatabaseFactory factory = databaseFactory;
  if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
    factory = ffi.databaseFactoryFfi;
  }
  db = await factory.openDatabase(dbPath, options: options);
}
