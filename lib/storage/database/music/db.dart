import 'dart:async';

import 'package:second_music/common/date.dart';
import 'package:second_music/model/enum.dart';
import 'package:second_music/model/song_list.dart';
import 'package:second_music/storage/database/basic.dart';
import 'package:second_music/storage/database/music/table.dart';
import 'package:sqflite/sqflite.dart';

class SongDbHelper extends DbHelper {
  @override
  String get name => "song.db";

  @override
  FutureOr<void> onCreate(Database db, int version) async {
    await db.execute('''
    create table if not exists ${SongListTable.TABLE_NAME}(
      ${SongListTable.PLT} text not null,
      ${SongListTable.PLT_ID} text not null,
      ${SongListTable.TITLE} text not null,
      ${SongListTable.COVER} text,
      ${SongListTable.DESCRIPTION} text,
      ${SongListTable.TYPE} int not null,
      ${SongListTable.CREATOR_ID} text,
      ${SongListTable.CREATOR_NAME} text,
      ${SongListTable.CREATOR_AVATAR} text,
      ${SongListTable.CREATED_TIME} text not null default(datetime('now', 'localtime')), 
      primary key (${SongListTable.PLT}, ${SongListTable.PLT_ID}, ${SongListTable.TYPE}))
    ''');

    //初始化歌单数据库，插入‘我喜欢的音乐’
    await db.insert(
        SongListTable.TABLE_NAME,
        {
          SongListTable.PLT: MusicPlatforms.LOCAL,
          SongListTable.PLT_ID: SongListTable.FAVOR_ID,
          SongListTable.TITLE: '我喜欢的音乐',
          SongListTable.TYPE: SongListType.playlist.index,
          SongListTable.CREATED_TIME: dateTimeToString(DateTime.now()),
        },
        conflictAlgorithm: ConflictAlgorithm.ignore);

    await db.execute('''
    create table if not exists ${SongTable.TABLE_NAME} (
      ${SongTable.PLT} text not null,
      ${SongTable.PLT_ID} text not null,
      ${SongTable.NAME} text not null,
      ${SongTable.COVER} text,
      ${SongTable.STREAM_URL} text,
      ${SongTable.DESCRIPTION} text,
      ${SongTable.LYRIC_URL} text,
      ${SongTable.SINGER_ID} text,
      ${SongTable.SINGER_NAME} text,
      ${SongTable.ALBUM_ID} text,
      ${SongTable.ALBUM_NAME} text,
      ${SongTable.PLAYED_TIME} text,
      primary key (${SongListTable.PLT}, ${SongListTable.PLT_ID}))
    ''');

    await db.execute('''
    create table if not exists ${SongListJoinSongTable.TABLE_NAME} (
      ${SongListJoinSongTable.SONG_LIST_ID} int not null,
      ${SongListJoinSongTable.SONG_ID} int not null,
      ${SongListJoinSongTable.ADDED_TIME} text not null default(datetime('now', 'localtime')),
      primary key (${SongListJoinSongTable.SONG_LIST_ID}, ${SongListJoinSongTable.SONG_ID}))
    ''');
  }
}
