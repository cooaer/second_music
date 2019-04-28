import 'dart:async';

import 'package:flutter/material.dart';
import 'package:second_music/common/date.dart';
import 'package:second_music/common/md5.dart';
import 'package:second_music/model/enum.dart';
import 'package:second_music/model/song.dart';
import 'package:second_music/model/song_list.dart';
import 'package:second_music/storage/database/music/dao.dart';
import 'package:second_music/storage/database/music/table.dart';

void notifyMySongListChanged() {
  MySongListModel.instance.refresh();
}

class MySongListModel {
  static MySongListModel _instance;

  static MySongListModel get instance {
    if (_instance == null) {
      _instance = MySongListModel._();
    }
    return _instance;
  }

  static List<SongList> createdOfPlaylist(List<SongList> all) {
    if (all == null || all.isEmpty) return [];
    var songLists = all.where((playlist) => playlist.plt == MusicPlatforms.LOCAL).toList();
    var favorIndex = songLists.indexWhere((playlist) => playlist.id == SongListTable.FAVOR_ID);
    if (favorIndex != -1 && favorIndex != 0) {
      var favor = songLists.removeAt(favorIndex);
      songLists[0] = favor;
    }
    return songLists;
  }

  static List<SongList> collectedOfPlaylist(List<SongList> all) {
    if (all == null || all.isEmpty) return [];
    return all
        .where((playlist) =>
            playlist.plt != MusicPlatforms.LOCAL && playlist.type == SongListType.playlist)
        .toList();
  }

  static List<SongList> collectedOfAlbum(List<SongList> all) {
    if (all == null || all.isEmpty) return [];
    return all
        .where((playlist) =>
    playlist.plt != MusicPlatforms.LOCAL && playlist.type == SongListType.album)
        .toList();
  }

  var _mySongListDao = MySongListDao();

  MySongListModel._();

  var _mySongListController = StreamController<List<SongList>>.broadcast();

  Stream<List<SongList>> get mySongListStream => _mySongListController.stream;

  //我的所有歌单
  Future refresh() async {
    List<SongList> songLists = await _mySongListDao.queryAllWithoutSongs();
    _mySongListController.add(songLists);
  }

  //创建歌单
  Future<bool> createSongList(String title) async {
    if (title == null || title.isEmpty) return false;
    var songList = DbSongList();
    songList.plt = MusicPlatforms.LOCAL;
    songList.id = md5(title + DateTime.now().millisecond.toString()).substring(0, 16);
    songList.title = title;
    songList.type = SongListType.playlist;
    songList.createdTime = dateTimeToString(DateTime.now());
    var result = await _mySongListDao.saveSongList(songList);
    await refresh();
    return result;
  }

  //删除歌单（删除没有从属某个歌单且没有播放时间的歌曲）
  Future<bool> deleteSongList(String plt, String id, SongListType type) async {
    var result = await _mySongListDao.deleteSongList(plt, id, type);
    await refresh();
    return result;
  }

  //添加歌曲到歌单
  Future<bool> addSongToList(Song song, int songListRowId) async {
    var result = await _mySongListDao.addSongToSongListWithRowId(songListRowId, song);
    await refresh();
    return result;
  }

  //删除歌单中的歌曲
  Future<bool> deleteSongFromList(String songListType, String songListId, SongListType type,
      String songPlt, String songId) async {
    var result = await _mySongListDao.deleteSongFromSongList(
        songListType, songListId, type, songPlt, songId);
    await refresh();
    return result;
  }
}

class HistoryModel {
  // 获取所有历史播放歌曲总数

  // 获取所有历史歌曲

}

class CreatePlaylistModel {
  CreatePlaylistModel() {
    _titleEditingController.addListener(() {
      _titleController.add(_titleEditingController.text.trim());
    });
  }

  var _titleController = StreamController<String>.broadcast();

  Stream<String> get titleStream => _titleController.stream;

  var _titleEditingController = TextEditingController();

  TextEditingController get titleEditingController => _titleEditingController;

  void dispose() {
    _titleEditingController.dispose();
    _titleController.close();
  }
}
