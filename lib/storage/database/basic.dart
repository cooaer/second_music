import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

abstract class DbHelper {
  final int defaultVersion = 1;

  String get name;

  int get version => defaultVersion;

  FutureOr<void> onCreate(Database db, int version);

  FutureOr<void> onUpgrade(Database db, int oldVersion, int newVersion) {}

  FutureOr<void> onOpen(Database db) {}

  Future<Database> open() async {
    var databasesPath = await getDatabasesPath();
    try {
      await Directory(databasesPath).create(recursive: true);
    } catch (_) {}

    var path = join(databasesPath, this.name);
    var db = await openDatabase(path,
        version: this.version,
        onCreate: onCreate,
        onUpgrade: onUpgrade,
        onOpen: onOpen,
        singleInstance: false);
    return db;
  }
}