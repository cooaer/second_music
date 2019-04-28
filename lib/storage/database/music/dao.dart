import 'package:second_music/common/date.dart';
import 'package:second_music/common/md5.dart';
import 'package:second_music/model/enum.dart';
import 'package:second_music/model/song.dart';
import 'package:second_music/model/song_list.dart';
import 'package:second_music/storage/database/music/db.dart';
import 'package:second_music/storage/database/music/table.dart';
import 'package:sqflite/sqflite.dart';

class BasicDao {
  Database _db;

  Future<bool> _open() async {
    if (this._db == null) {
      this._db = await SongDbHelper().open();
    }
    return this._db != null;
  }

  void close() {
    this._db?.close();
  }
}

class MySongListDao extends BasicDao {
  //创建歌单
  Future<bool> createSongList(String title) async {
    if (title == null || title.trim().isEmpty) {
      return false;
    }
    title = title.trim();

    await _open();
    var createdTime = dateTimeToString(DateTime.now());
    var pltId = md5(title + createdTime).substring(0, 8);
    var result = await _db.insert(
        SongListTable.TABLE_NAME,
        {
          SongListTable.PLT: MusicPlatforms.LOCAL,
          SongListTable.PLT_ID: pltId,
          SongListTable.TITLE: title,
          SongListTable.TYPE: SongListType.playlist.index,
          SongListTable.CREATED_TIME: createdTime,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore);
    return result != null && result > 0;
  }

  //查询某个歌单
  Future<DbSongList> querySongList(String plt, String id, SongListType type) async {
    await _open();

    var result = await _db.query(SongListTable.TABLE_NAME,
        columns: ['*', SongListTable.ROW_ID],
        where: '${SongListTable.PLT} = ? '
            'and ${SongListTable.PLT_ID} = ? '
            'and ${SongListTable.TYPE} = ?',
        whereArgs: [plt, id, type.index]);
    if (result == null || result.isEmpty) {
      return null;
    }

    var songList = DbSongList.fromDb(result.first);

    var sql2 = 'select ${SongTable.tableColumns} '
        'from ${SongListJoinSongTable.TABLE_NAME}, ${SongTable.TABLE_NAME} '
        'where ${SongListJoinSongTable.TABLE_NAME}.${SongListJoinSongTable.SONG_ID} = '
        '${SongTable.TABLE_NAME}.${SongTable.ROW_ID} '
        'and ${SongListJoinSongTable.TABLE_NAME}.${SongListJoinSongTable.SONG_LIST_ID} = ${songList.rowId}';
    print('querySongList sql2 : $sql2');
    var result2 = await _db.rawQuery(sql2);
    songList.songs = result2.map((item) => DbSong.fromDb(item)).toList();

    return songList;
  }

  Future<bool> hasSongList(String plt, String id, SongListType type) async {
    await _open();

    var result = await _db.query(SongListTable.TABLE_NAME,
        where: '${SongListTable.PLT} = ? and '
            '${SongListTable.PLT_ID} = ? and '
            '${SongListTable.TYPE} = ?',
        whereArgs: [plt, id, type.index]);
    return result != null && result.isNotEmpty;
  }

  Future<bool> hasSongInFavoriteList(String songPlt, String songId) async {
    await _open();
    var sql = 'select ${SongTable.TABLE_NAME}.${SongTable.ROW_ID} '
        'from ${SongListTable.TABLE_NAME}, ${SongTable.TABLE_NAME}, ${SongListJoinSongTable.TABLE_NAME} '
        'where ${SongListTable.TABLE_NAME}.${SongListTable.PLT_ID} = ? '
        'and ${SongListTable.TABLE_NAME}.${SongListTable.ROW_ID} '
        '= ${SongListJoinSongTable.TABLE_NAME}.${SongListJoinSongTable.SONG_LIST_ID} '
        'and ${SongTable.TABLE_NAME}.${SongTable.ROW_ID} '
        '= ${SongListJoinSongTable.TABLE_NAME}.${SongListJoinSongTable.SONG_ID} '
        'and ${SongTable.TABLE_NAME}.${SongTable.PLT} = ? '
        'and ${SongTable.TABLE_NAME}.${SongTable.PLT_ID} = ? ';
    print('hasSongInFavoriteList sql : $sql');
    var args = [SongListTable.FAVOR_ID, songPlt, songId];
    var result = await _db.rawQuery(sql, args);
    return result != null && result.isNotEmpty;
  }

  //查询所有的歌单
  Future<List<DbSongList>> queryAllWithoutSongs({String plt}) async {
    await _open();

    var sql1 = 'select ${SongListTable.ROW_ID}, * from ${SongListTable.TABLE_NAME}';
    if(plt != null && plt.isNotEmpty){
      sql1 += " where ${SongListTable.PLT} = '$plt'";
    }

    var dbSongLists = await _db.rawQuery(sql1);
    var dbTotals =
        await _db.rawQuery('select ${SongListJoinSongTable.SONG_LIST_ID}, count(*) as total '
            'from ${SongListJoinSongTable.TABLE_NAME} '
            'group by ${SongListJoinSongTable.SONG_LIST_ID}');

    var songLists = <DbSongList>[];
    for (var songListMap in dbSongLists) {
      var songList = DbSongList.fromDb(songListMap);
      var total = dbTotals.firstWhere((totalMap) {
        return totalMap[SongListJoinSongTable.SONG_LIST_ID] == songList.rowId;
      }, orElse: () => null);
      songList.songTotal = total == null ? null : total['total'];
      if (songList.cover == null || songList.cover.isEmpty) {
        songList.cover = await _queryFirstSongCoverForList(songList.rowId);
      }
      songLists.add(songList);
    }
    return songLists;
  }

  // 找出每个歌单的第一首歌的封面
  Future<String> _queryFirstSongCoverForList(int songListRowId) async {
    await _open();
    String sql = 'select st.${SongTable.COVER} '
        'from ${SongListJoinSongTable.TABLE_NAME} as slst, ${SongTable.TABLE_NAME} as st '
        'where slst.${SongListJoinSongTable.SONG_ID} = st.${SongTable.ROW_ID} '
        'and slst.${SongListJoinSongTable.SONG_LIST_ID} = $songListRowId '
        'order by slst.${SongListJoinSongTable.ADDED_TIME} asc limit 1';
    var result = await _db.rawQuery(sql);
    return result != null && result.isNotEmpty ? result.first[SongTable.COVER] : null;
  }

  ///保存歌单，如果已经存在则替换
  Future<bool> saveSongList(SongList songList) async {
    if (songList == null) return false;

    await _open();

    var values = songList.toDb();
    int rowId = await _db.insert(SongListTable.TABLE_NAME, values,
        conflictAlgorithm: ConflictAlgorithm.replace);

    if (songList.songs != null && songList.songs.isNotEmpty) {
      for (var song in songList.songs) {
        await addSongToSongListWithRowId(rowId, song);
      }
    }

    return rowId != null && rowId > 0;
  }

  ///删除歌单
  Future<bool> deleteSongListWithRowId(int rowId) async {
    await _open();

    return await _db.transaction<bool>((txn) async {
      var ret = await txn.delete(SongListTable.TABLE_NAME,
          where: '${SongListTable.ROW_ID} = ?', whereArgs: [rowId.toString()]);
      if (ret == null || ret == 0) return false;

      await txn.delete(SongListJoinSongTable.TABLE_NAME,
          where: '${SongListJoinSongTable.SONG_LIST_ID} = ?', whereArgs: [rowId]);

      await deleteUnusedSong(exeObj: txn);
      return true;
    });
  }

  ///删除歌单
  Future<bool> deleteSongList(String plt, String id, SongListType type) async {
    await _open();

    return await _db.transaction<bool>((txn) async {
      var rowId = await _querySongListRowId(txn, plt, id, type);
      if (rowId == null) return false;

      var ret = await txn.delete(SongListTable.TABLE_NAME,
          where:
              '${SongListTable.PLT} = ? and ${SongListTable.PLT_ID} = ? and ${SongListTable.TYPE} = ?',
          whereArgs: [plt, id, type.index]);
      if (ret == null || ret == 0) return false;

      await txn.delete(SongListJoinSongTable.TABLE_NAME,
          where: '${SongListJoinSongTable.SONG_LIST_ID} = ?', whereArgs: [rowId]);

      await deleteUnusedSong(exeObj: txn);

      return true;
    });
  }

  ///添加歌曲
  Future<bool> addSongsToSongList(
      String songListPlt, String songListId, SongListType songListType, List<Song> songs) async {
    var result = false;
    for(Song song in songs){
      result = await addSongToSongList(songListPlt, songListId, songListType, song) || result;
    }
    return result;
  }

  Future<bool> addSongToSongList(
      String songListPlt, String songListId, SongListType songListType, Song song) async {
    await _open();

    var rowId = await _querySongListRowId(_db, songListPlt, songListId, songListType);
    if (rowId == null) return false;
    return addSongToSongListWithRowId(rowId, song);
  }

  Future<bool> addSongToSongListWithRowId(int songListRowId, Song song) async {
    await _open();

    return await _db.transaction<bool>((txn) async {
      var values = song.toDb();

      var list = await txn.rawQuery('select ${SongTable.ROW_ID}, * '
          'from ${SongTable.TABLE_NAME} '
          'where ${SongTable.PLT} = "${song.plt}" '
          'and ${SongTable.PLT_ID} = "${song.id}" ');
      int songRowId;
      if (list.isEmpty) {
        //插入数据
        songRowId = await txn.insert(SongTable.TABLE_NAME, values,
            conflictAlgorithm: ConflictAlgorithm.ignore);
      } else {
        songRowId = list.first[SongTable.ROW_ID];
        //如果歌曲已存在，则更新数据
        await txn.update(SongTable.TABLE_NAME, values,
            where: '${SongTable.PLT} = ? and ${SongTable.PLT_ID} = ?',
            whereArgs: [song.plt, song.id]);
      }

      await txn.insert(
          SongListJoinSongTable.TABLE_NAME,
          {
            SongListJoinSongTable.SONG_LIST_ID: songListRowId,
            SongListJoinSongTable.SONG_ID: songRowId
          },
          conflictAlgorithm: ConflictAlgorithm.ignore);
      return true;
    });
  }

  ///删除歌曲
  Future<bool> deleteSongFromSongList(String songListPlt, String songListId,
      SongListType songListType, String songPlt, String songId) async {
    await _open();

    var result = await _db.transaction<bool>((txn) async {
      var songListRowId = await _querySongListRowId(txn, songListPlt, songListId, songListType);
      if (songListRowId == null) return false;
      var result2 = await txn.query(SongTable.TABLE_NAME,
          columns: [SongTable.ROW_ID],
          where: '${SongTable.PLT} = ? and ${SongTable.PLT_ID} = ?',
          whereArgs: [songPlt, songId]);
      if (result2 == null || result2.isEmpty) return false;
      var result3 = await txn.delete(SongListJoinSongTable.TABLE_NAME,
          where: '${SongListJoinSongTable.SONG_LIST_ID} = ? '
              'and ${SongListJoinSongTable.SONG_ID} = ?',
          whereArgs: [songListRowId, result2.first[SongTable.ROW_ID]]);
      return result3 != null && result3 > 0;
    });

    if (result) {
      await deleteUnusedSong();
    }
    return result;
  }

  Future<int> _querySongListRowId(dynamic obj, String plt, String id, SongListType type) async {
    var result = await obj.query(SongListTable.TABLE_NAME,
        columns: [SongListTable.ROW_ID],
        where: '${SongListTable.PLT} = ? '
            'and ${SongListTable.PLT_ID} = ? '
            'and ${SongListTable.TYPE} = ?',
        whereArgs: [plt, id, type.index]);
    return result != null && result.isNotEmpty ? result.first[SongListTable.ROW_ID] : null;
  }

  ///删除歌曲
  Future<bool> deleteSongFromSongListWithRowId(int songListRowId, int songRowId) async {
    await _open();

    int result = await _db.delete(SongListJoinSongTable.TABLE_NAME,
        where: '${SongListJoinSongTable.SONG_LIST_ID} = ? and ${SongListJoinSongTable.SONG_ID} = ?',
        whereArgs: [songListRowId, songRowId]);
    if (result != null && result > 0) {
      await deleteUnusedSong();
      return true;
    }
    return false;
  }

  //删除无用的歌曲
  Future<int> deleteUnusedSong({dynamic exeObj}) async {
    await _open();

    var sql = 'delete from ${SongTable.TABLE_NAME} '
        'where ${SongTable.PLAYED_TIME} = null '
        'and ${SongTable.ROW_ID} not in ('
        'select ${SongListJoinSongTable.SONG_ID} from ${SongListJoinSongTable.TABLE_NAME})';

    return await (exeObj ?? _db).rawDelete(sql);
  }
}

class SongDao extends BasicDao {
  ///查询所有的历史
  Future<List<DbSong>> queryAllHistories() async {
    var list = await this._db.query(SongTable.TABLE_NAME,
        columns: [SongTable.ROW_ID, '*'], where: '${SongTable.PLAYED_TIME} is not null');
    var result = <DbSong>[];
    list.forEach((element) => result.add(DbSong.fromDb(element)));
    return result;
  }

  ///插入或者更新
  Future<bool> insertOrUpdate(Song song) async {
    var values = song.toDb();
    //插入数据
    var result =
        await _db.insert(SongTable.TABLE_NAME, values, conflictAlgorithm: ConflictAlgorithm.ignore);
    //如果插入成功则返回
    if (result != null) {
      return result > 0;
    }
    //如果歌曲已存在，则更新数据
    result = await this._db.update(SongTable.TABLE_NAME, values,
        where: '${SongTable.PLT} = ? and ${SongTable.PLT_ID} = ?', whereArgs: [song.plt, song.id]);
    return result != null && result == 1;
  }

  ///更新播放时间
  Future<bool> updatePlayedTime(int rowId) async {
    var values = {SongTable.PLAYED_TIME: dateTimeToString(DateTime.now())};
    var result = await this
        ._db
        .update(SongTable.TABLE_NAME, values, where: '${SongTable.ROW_ID} = ?', whereArgs: [rowId]);
    return result != null && result == 1;
  }
}
