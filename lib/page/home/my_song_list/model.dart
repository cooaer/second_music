import 'dart:async';

import 'package:flutter/material.dart';
import 'package:second_music/entity/enum.dart';
import 'package:second_music/entity/song_list.dart';
import 'package:second_music/repository/local/database/song/dao.dart';

void notifyMySongListChanged() {
  MySongListModel.instance.refresh();
}

class MySongListModel {
  static MySongListModel? _instance;

  static MySongListModel get instance {
    if (_instance == null) {
      _instance = MySongListModel._();
    }
    return _instance!;
  }

  static List<SongList> createdOfPlaylist(List<SongList> all) {
    if (all.isEmpty) return [];
    var songLists =
        all.where((playlist) => playlist.plt == MusicPlatforms.local).toList();
    var favorIndex = songLists
        .indexWhere((playlist) => playlist.pltId == SongList.FAVOR_PLT_ID);
    if (favorIndex != -1 && favorIndex != 0) {
      var favor = songLists.removeAt(favorIndex);
      songLists[0] = favor;
    }
    return songLists;
  }

  static List<SongList> collectedOfPlaylist(List<SongList> all) {
    if (all.isEmpty) return [];
    return all
        .where((playlist) =>
            playlist.plt != MusicPlatforms.local &&
            playlist.type == SongListType.playlist)
        .toList();
  }

  static List<SongList> collectedOfAlbum(List<SongList> all) {
    if (all.isEmpty) return [];
    return all
        .where((playlist) =>
            playlist.plt != MusicPlatforms.local &&
            playlist.type == SongListType.album)
        .toList();
  }

  var _mySongListDao = MySongListDao();

  MySongListModel._();

  var _mySongListController = StreamController<List<SongList>>.broadcast();

  Stream<List<SongList>> get mySongListStream => _mySongListController.stream;

  //我的所有歌单
  Future refresh() async {
    List<SongList> songLists =
        await _mySongListDao.queryAllSongListWithoutSongs();
    _mySongListController.add(songLists);
  }

  //创建歌单
  Future<bool> createSongList(String title) async {
    if (title.isEmpty) return false;
    var result = await _mySongListDao.createSongList(title);
    await refresh();
    return result;
  }

  //删除歌单（删除没有从属某个歌单且没有播放时间的歌曲）
  Future<bool> deleteSongList(int songListId) async {
    var result = await _mySongListDao.deleteSongList(songListId);
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
