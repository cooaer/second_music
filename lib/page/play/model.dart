import 'dart:async';

import 'package:second_music/model/enum.dart';
import 'package:second_music/model/song.dart';
import 'package:second_music/model/song_list.dart';
import 'package:second_music/page/home/my_song_list/model.dart';
import 'package:second_music/storage/database/music/dao.dart';
import 'package:second_music/storage/database/music/table.dart';
import 'package:flutter/material.dart';
import 'package:second_music/page/model.dart';

class SongControllerModel {
  static final initialPage = 1000000;

  static int realIndexOf(int index) {
    var listCount = PlayControlModel.instance.playingList.length;
    return (index - initialPage) % listCount;
  }

  SongControllerModel() {
    PlayControlModel.instance.registerSongControllerModel(this);
  }

  PageController _songPageController;

  PageController get currentPageController => _songPageController;

  PageController newSongPageController() {
    var page = initialPage + PlayControlModel.instance.currentIndex;
    _songPageController = PageController(initialPage: page, keepPage: true);
    return _songPageController;
  }

  void jumpToCurrent() {
    if (_songPageController == null) return;

    var listCount = PlayControlModel.instance.playingList.length;
    if (listCount == 0) return;

    var listIndex = PlayControlModel.instance.currentIndex;
    var controllerIndex = realIndexOf(_songPageController.page.round());
    print('jumpToCurrent, currentIndex : ${_songPageController.page.round()}');
    if (listIndex == controllerIndex) return;

    _songPageController.jumpToPage(initialPage + PlayControlModel.instance.currentIndex);
  }

  void jumpTo(int index){
    if (_songPageController == null) return;

    var listCount = PlayControlModel.instance.playingList.length;
    if (listCount == 0) return;

    _songPageController.jumpToPage(initialPage + index);
  }

  void scrollToNext() {
    if (_songPageController == null) return;

    var listCount = PlayControlModel.instance.playingList.length;
    if (listCount == 0) return;

    var listIndex = PlayControlModel.instance.currentIndex;
    var controllerIndex = realIndexOf(_songPageController.page.round());
    if (listIndex != controllerIndex) {
      _songPageController.jumpToPage(initialPage + listIndex + 1);
    } else {
      _songPageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.linear);
    }
  }

  void scrollToPrev() {
    if (_songPageController == null) return;

    var listCount = PlayControlModel.instance.playingList.length;
    if (listCount == 0) return;

    var listIndex = PlayControlModel.instance.currentIndex;
    var controllerIndex = realIndexOf(_songPageController.page.round());
    if (listIndex != controllerIndex) {
      _songPageController.jumpToPage(initialPage + listIndex - 1);
    } else {
      _songPageController.previousPage(duration: Duration(milliseconds: 300), curve: Curves.linear);
    }
  }

  void dispose() {
    PlayControlModel.instance.unregisterSongControllerModel(this);
    _songPageController.dispose();
  }
}

class SongModel {
  final Song song;

  final _mySongListDao = MySongListDao();

  SongModel(this.song){
    refresh();
  }

  void refresh() async {
    if (song == null) return;

    _isFavorite = await _mySongListDao.hasSongInFavoriteList(song.plt, song.id);
    _isFavoriteController.add(_isFavorite);
  }

  bool _isFavorite = false;

  bool get isFavorite => _isFavorite;

  var _isFavoriteController = StreamController<bool>.broadcast();

  Stream<bool> get isFavoriteStream => _isFavoriteController.stream;

  void toggleFavorite() async {
    if (song == null) return;

    _isFavoriteController.add(!_isFavorite);
    var result = false;
    if (isFavorite) {
      result = await _mySongListDao.deleteSongFromSongList(
          MusicPlatforms.LOCAL, SongListTable.FAVOR_ID, SongListType.playlist, song.plt, song.id);
      if (result) _isFavorite = false;
    } else {
      result = await _mySongListDao.addSongToSongList(
          MusicPlatforms.LOCAL, SongListTable.FAVOR_ID, SongListType.playlist, song);
      if (result) _isFavorite = true;
    }
    if (result) {
      notifyMySongListChanged();
    }
    _isFavoriteController.add(_isFavorite);
  }

  void dispose() {
    _isFavoriteController.close();
    _mySongListDao.close();
  }
}
