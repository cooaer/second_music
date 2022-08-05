import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:second_music/entity/enum.dart';
import 'package:second_music/entity/song.dart';
import 'package:second_music/entity/song_list.dart';
import 'package:second_music/repository/local/database/song/entity.dart';

part 'song.g.dart';

@UseRowClass(
  SongList,
  constructor: "fromDb",
)
class SongListTable extends Table {
  String get tableName => "song_list";

  IntColumn get id => integer().autoIncrement()();

  TextColumn get plt => text()();

  TextColumn get pltId => text()();

  TextColumn get title => text()();

  TextColumn get cover => text()();

  TextColumn get description => text()();

  IntColumn get playCount => integer()();

  IntColumn get favorCount => integer()();

  TextColumn get userPlt => text()();

  TextColumn get userId => text()();

  TextColumn get userName => text()();

  TextColumn get userAvatar => text()();

  IntColumn get type => intEnum<SongListType>()();

  DateTimeColumn get createdTime =>
      dateTime().withDefault(currentDateAndTime)();

  IntColumn get songTotal => integer()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {plt, pltId, type}
      ];
}

@UseRowClass(Song, constructor: "fromDb")
class SongTable extends Table {
  String get tableName => "song";

  IntColumn get id => integer().autoIncrement()();

  TextColumn get plt => text()();

  TextColumn get pltId => text()();

  TextColumn get name => text()();

  TextColumn get subtitle => text()();

  TextColumn get cover => text()();

  TextColumn get streamUrl => text()();

  TextColumn get description => text()();

  TextColumn get singerId => text()();

  TextColumn get singerName => text()();

  TextColumn get singerAvatar => text()();

  TextColumn get albumId => text()();

  TextColumn get albumName => text()();

  TextColumn get albumCover => text()();

  DateTimeColumn get playedTime => dateTime().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {plt, pltId}
      ];
}

@UseRowClass(SongListJoinSong, constructor: "fromDb")
class SongListJoinSongTable extends Table {
  String get tableName => "songlist_song";

  IntColumn get songListId => integer()();

  IntColumn get songId => integer()();

  DateTimeColumn get addedTime => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {songListId, songId};
}

@UseRowClass(PlayingSong, constructor: "fromDb")
class PlayingSongTable extends Table {
  @override
  String get tableName => "playing_song";

  IntColumn get songId => integer()();

  DateTimeColumn get addedTime => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {songId};
}

@DriftDatabase(
  tables: [SongListTable, SongTable, SongListJoinSongTable, PlayingSongTable],
)
class SongDatabase extends _$SongDatabase {
  SongDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(onCreate: (migrator) async {
      await migrator.createAll();
      await into(songListTable).insert(SongListTableCompanion.insert(
          plt: MusicPlatforms.local,
          pltId: SongList.FAVOR_PLT_ID,
          title: "我最喜欢的音乐",
          cover: "",
          description: "",
          playCount: 0,
          favorCount: 0,
          userPlt: "",
          userId: "",
          userName: "",
          userAvatar: "",
          type: SongListType.playlist,
          songTotal: 0));
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(path.join(dbFolder.path, 'database', 'song.db'));
    return NativeDatabase(file, logStatements: true);
  });
}
