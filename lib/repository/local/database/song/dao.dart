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

///WARN : 在插入的时候使用非默认的InsertMode，返回的结果无法预料；
class SongDao extends BasicDao {
  //创建歌单
  Future<bool> createSongList(String title) async {
    if (title.trim().isEmpty) {
      return false;
    }
    title = title.trim();

    final createdTime = dateTimeToString(DateTime.now());
    final pltId = md5(title + createdTime).substring(0, 8);
    final songListInsertable = SongListTableCompanion.insert(
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
        songTotal: 0);
    try {
      await db.into(db.songListTable).insert(songListInsertable);
    } on Exception catch (e) {
      debugPrint("dao.createSongList: failed, exception = $e");
      return false;
    }
    return true;
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
      innerJoin(db.songTable,
          db.songListJoinSongTable.songId.equalsExp(db.songTable.id))
    ])
          ..where(db.songListJoinSongTable.songListId.equals(songList.id)))
        .get();

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
      var songListId = 0;
      try {
        songListId =
            await db.into(db.songListTable).insert(songList.toInsertable());
      } on Exception catch (e) {
        debugPrint("saveSongList, exception details: $e");
        final songListWithId = await (db.select(db.songListTable)
              ..where((tbl) =>
                  tbl.plt.equals(songList.plt) &
                  tbl.pltId.equals(songList.pltId) &
                  tbl.type.equals(songList.type.index)))
            .getSingleOrNull();
        if (songListWithId == null) {
          return false;
        }
        songListId = songListWithId.id;
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
        final cover =
            songs.firstWhereOrNull((song) => song.cover.isNotEmpty)?.cover;
        if (cover != null) {
          await _fillDefaultCoverToMyPlaylist(songListId, cover);
        }
      }
      return addedRows;
    });
  }

  Future<bool> _addSongToSongList(int songListId, Song song) async {
    int songId = await _saveSong(song);
    if (songId <= 0) {
      return false;
    }
    try {
      final rowId = await db.into(db.songListJoinSongTable).insert(
          SongListJoinSongTableCompanion.insert(
              songListId: songListId, songId: songId));
      if (rowId > 0) {
        return true;
      }
    } on Exception catch (e) {
      debugPrint("addSongToSongList, exception details: $e");
      return false;
    }
    return false;
  }

  Future<int> _saveSong(Song song) async {
    int songId = 0;
    try {
      songId = await db.into(db.songTable).insert(song.toInsertable());
      debugPrint("SongDao.saveSong: insert result, songId = $songId");
    } on Exception catch (e) {
      debugPrint("_addSong, exception details: $e");

      final songWithId = await (db.select(db.songTable)
            ..where((tbl) =>
                tbl.plt.equals(song.plt.name) & tbl.pltId.equals(song.pltId)))
          .getSingleOrNull();
      if (songWithId == null) {
        debugPrint("_addSong: insert failed, songListId = null, song = $song");
        return 0;
      }
      songId = songWithId.id;
      debugPrint("SongDao.saveSong: query result, songId = $songId");
    }
    return songId;
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
    final songIdsInSongList = (await db.select(db.songListJoinSongTable).get())
        .map((e) => e.songId)
        .toList();
    final songIdsInPlayingSong = (await db.select(db.playingSongTable).get())
        .map((e) => e.songId)
        .toList();
    final allSongIds = songIdsInSongList + songIdsInPlayingSong;
    final deletedRows = await (db.delete(db.songTable)
          ..where((tbl) => tbl.id.isNotIn(allSongIds)))
        .go();
    return deletedRows;
  }

  //=============== now playing start ================

  Future<List<Song>> getPlayingSongs() async {
    final typedResult = await (db.select(db.playingSongTable).join([
      innerJoin(
          db.songTable, db.songTable.id.equalsExp(db.playingSongTable.songId))
    ])).get();
    return typedResult.map((e) => e.readTable(db.songTable)).toList();
  }

  Future<bool> savePlayingSong(Song song) async {
    return await savePlayingSongs([song]) == 1;
  }

  Future<int> savePlayingSongs(List<Song> songs) async {
    return db.transaction<int>(() async {
      var addedRows = 0;
      for (var song in songs) {
        final songId = await _saveSong(song);
        if (songId <= 0) {
          continue;
        }
        try {
          final rowId = await db
              .into(db.playingSongTable)
              .insert(PlayingSongTableCompanion.insert(songId: Value(songId)));
          if (rowId > 0) {
            addedRows++;
          }
        } on Exception catch (e) {
          debugPrint("dao.savePlayingSongs, failed, exception = $e");
        }
      }
      return addedRows;
    });
  }

  Future<bool> deletePlayingSong(int songId) async {
    return await deletePlayingSongs([songId]) == 1;
  }

  Future<int> deletePlayingSongs(List<int> songIds) async {
    return db.transaction(() async {
      final deletedRows = await (db.delete(db.playingSongTable)
            ..where((tbl) => db.playingSongTable.songId.isIn(songIds)))
          .go();
      await deleteUnusedSong();
      return deletedRows;
    });
  }

  Future<int> deleteAllPlayingSongs() async {
    return db.transaction(() async {
      final deletedRows = await (db.delete(db.playingSongTable)).go();
      await deleteUnusedSong();
      return deletedRows;
    });
  }
//=============== now playing end ================

}

// class SongDao extends BasicDao {
//   ///查询所有的历史
//   Future<List<Song>> queryAllHistories() async {
//     return await (db.select(db.songTable)
//           ..where((tbl) => tbl.playedTime.isNotNull())
//           ..orderBy([(t) => OrderingTerm.desc(db.songTable.playedTime)]))
//         .get();
//   }
//
//   ///插入或者更新
//   Future<bool> saveSong(Song song) async {
//     final songId = await db
//         .into(db.songTable)
//         .insert(song.toInsertable(), mode: InsertMode.insertOrIgnore);
//     return songId > 0;
//   }
//
// //更新播放时间
// }
