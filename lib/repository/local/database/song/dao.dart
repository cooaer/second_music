import 'package:dart_extensions_methods/dart_extension_methods.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:second_music/common/date.dart';
import 'package:second_music/common/md5.dart';
import 'package:second_music/entity/enum.dart';
import 'package:second_music/entity/song.dart';
import 'package:second_music/entity/song_list.dart';
import 'package:second_music/repository/local/database/song/helper.dart';
import 'package:second_music/repository/local/database/song/song.dart';

class BasicDao {
  SongDatabase get db {
    return SongDatabaseProvider.instance.db;
  }
}

class MySongListDao extends BasicDao {
  //创建歌单
  Future<bool> createSongList(String title) async {
    if (title.trim().isEmpty) {
      return false;
    }
    title = title.trim();

    final createdTime = dateTimeToString(DateTime.now());
    final pltId = md5(title + createdTime).substring(0, 8);
    final songListId = await db.into(db.songListTable).insert(
        SongListTableCompanion.insert(
            plt: MusicPlatforms.local,
            pltId: pltId,
            title: title,
            cover: "",
            description: "",
            playCount: 0,
            favorCount: 0,
            userPlt: "",
            userId: "",
            userName: "",
            userAvatar: "",
            type: SongListType.playlist,
            songTotal: 0),
        mode: InsertMode.insertOrIgnore);
    return songListId > 0;
  }

  //查询某个歌单
  Future<SongList?> getSongList(
      String plt, String pltId, SongListType type) async {
    final songList = await (db.select(db.songListTable)
          ..where((tbl) =>
              tbl.plt.equals(plt) &
              tbl.pltId.equals(pltId) &
              tbl.type.equals(type.index)))
        .getSingleOrNull();
    if (songList == null) {
      return null;
    }

    final result = await (db.select(db.songListJoinSongTable).join([
      innerJoin(
          db.songTable,
          db.songListJoinSongTable.songId.equalsExp(db.songTable.id) &
              db.songListJoinSongTable.songListId.equals(songList.id))
    ])).get();

    songList.songs = result.map((row) {
      return row.readTable(db.songTable);
    }).toList();

    return songList;
  }

  Future<bool> isSongListExists(
      String plt, String pltId, SongListType type) async {
    final result = await (db.select(db.songListTable)
          ..where((tbl) =>
              tbl.plt.equals(plt) &
              tbl.pltId.equals(pltId) &
              tbl.type.equals(type.index)))
        .getSingleOrNull();
    return result != null;
  }

  Future<bool> isSongInFavoriteList(String songPlt, String songPltId) async {
    final result = await (db.select(db.songListJoinSongTable).join([
      innerJoin(db.songListTable,
          db.songListJoinSongTable.songListId.equalsExp(db.songListTable.id)),
      innerJoin(db.songTable,
          db.songListJoinSongTable.songId.equalsExp(db.songTable.id))
    ])
          ..where(db.songTable.plt.equals(songPlt) &
              db.songTable.pltId.equals(songPltId) &
              db.songListTable.plt.equals(MusicPlatforms.local) &
              db.songListTable.pltId.equals(SongList.FAVOR_PLT_ID) &
              db.songListTable.type.equals(SongListType.playlist.index)))
        .getSingleOrNull();
    return result != null;
  }

  //查询所有的歌单
  Future<List<SongList>> queryAllSongListWithoutSongs({String? plt}) async {
    final selectStatement = db.select(db.songListTable);
    if (plt.isNotNullOrEmpty()) {
      selectStatement.where((tbl) => tbl.plt.equals(plt));
    }
    final songLists = await selectStatement.get();
    return songLists;
  }

  ///保存歌单，如果已经存在则替换
  Future<bool> saveSongList(SongList songList) async {
    return db.transaction<bool>(() async {
      int songListId = 0;
      try {
        songListId = await db
            .into(db.songListTable)
            .insert(songList.toInsertable(), mode: InsertMode.insertOrIgnore);
      } on Exception catch (e) {
        debugPrint("saveSongList, exception details: $e");
      }
      if (songListId <= 0) {
        return false;
      }
      for (var song in songList.songs) {
        if (!(await _addSongToSongList(songListId, song))) {
          return false;
        }
      }
      return true;
    });
  }

  ///删除歌单
  Future<bool> deleteSongList(int songListId) async {
    return db.transaction<bool>(() async {
      final rows = await (db.delete(db.songListTable)
            ..where((tbl) => tbl.id.equals(songListId)))
          .go();
      if (rows == 0) {
        return false;
      }
      await (db.delete(db.songListJoinSongTable)
            ..where((tbl) => tbl.songListId.equals(songListId)))
          .go();
      await deleteUnusedSong();
      return true;
    });
  }

  ///添加歌曲
  Future<int> addSongsToSongList(int songListId, List<Song> songs) async {
    return await db.transaction<int>(() async {
      int addedRows = 0;
      for (Song song in songs) {
        final result = await _addSongToSongList(songListId, song);
        if (result) {
          addedRows++;
        }
      }
      if (addedRows > 0) {
        await _addSongTotal(songListId, addedRows);
        final cover = songs.firstWhere((song) => song.cover.isNotEmpty).cover;
        await _fillDefaultCoverToMyPlaylist(songListId, cover);
      }
      return addedRows;
    });
  }

  Future<bool> _addSongToSongList(int songListId, Song song) async {
    int songId = 0;
    try {
      songId = await db
          .into(db.songTable)
          .insert(song.toInsertable(), mode: InsertMode.insertOrIgnore);
    } on Exception catch (e) {
      debugPrint("_addSongToSongList, exception details: $e");
    }
    if (songId <= 0) {
      final songWithId = await (db.select(db.songTable)
            ..where((tbl) =>
                tbl.plt.equals(song.plt.name) & tbl.pltId.equals(song.pltId)))
          .getSingleOrNull();
      if (songWithId == null) {
        debugPrint(
            "addSongToSongList: insert failed, songListId = $songListId, song = $song");
        return false;
      }
      songId = songWithId.id;
    }
    int joinId = 0;
    try {
      joinId = await db.into(db.songListJoinSongTable).insert(
          SongListJoinSongTableCompanion.insert(
              songListId: songListId, songId: songId),
          mode: InsertMode.insertOrIgnore);
    } on Exception catch (e) {
      debugPrint("addSongToSongList, exception details: $e");
    }
    return joinId > 0;
  }

  //添加默认的封面，仅针对创建的歌单
  Future<bool> _fillDefaultCoverToMyPlaylist(
      int songListId, String cover) async {
    final updateRows = await (db.update(db.songListTable)
          ..where((tbl) => tbl.id.equals(songListId) & tbl.cover.equals("")))
        .write(SongListTableCompanion(cover: Value(cover)));
    return updateRows > 0;
  }

  ///删除歌曲
  Future<bool> deleteSongFromSongList(int songListId, int songId) async {
    return await db.transaction<bool>(() async {
      final deletedRows = await (db.delete(db.songListJoinSongTable)
            ..where((tbl) =>
                tbl.songListId.equals(songListId) & tbl.songId.equals(songId)))
          .go();
      if (deletedRows <= 0) {
        return false;
      }
      final deletedSongRows = await deleteUnusedSong();
      if (deletedSongRows > 0) {
        await _addSongTotal(songListId, -1);
      }
      return true;
    });
  }

  Future<bool> _addSongTotal(int songListId, int add) async {
    final songList = await (db.select(db.songListTable)
          ..where((tbl) => tbl.id.equals(songListId)))
        .getSingle();
    final updateRows = await (db.update(db.songListTable)
          ..where((tbl) => tbl.id.equals(songListId)))
        .write((SongListTableCompanion(
            songTotal: Value(songList.songTotal + add))));
    return updateRows > 0;
  }

  //删除无用的歌曲
  Future<int> deleteUnusedSong() async {
    final allSongIds =
        (await db.select(db.songListJoinSongTable).get()).map((e) => e.songId);
    final result = await (db.delete(db.songTable)
          ..where((tbl) => tbl.id.isNotIn(allSongIds)))
        .go();

    return result;
  }
}

class SongDao extends BasicDao {
  ///查询所有的历史
  Future<List<Song>> queryAllHistories() async {
    return await (db.select(db.songTable)
          ..where((tbl) => tbl.playedTime.isNotNull())
          ..orderBy([(t) => OrderingTerm.desc(db.songTable.playedTime)]))
        .get();
  }

  ///插入或者更新
  Future<bool> saveSong(Song song) async {
    final songId = await db
        .into(db.songTable)
        .insert(song.toInsertable(), mode: InsertMode.insertOrIgnore);
    return songId > 0;
  }

//更新播放时间
}
