import 'dart:async';

import 'package:flutter/material.dart';
import 'package:second_music/entity/song.dart';
import 'package:second_music/entity/song_list.dart';
import 'package:second_music/page/home/my_song_list/model.dart';
import 'package:second_music/repository/local/database/song/dao.dart';
import 'package:second_music/service/music_service.dart';
import 'package:second_music/widget/infinite_page_view.dart';

class PlaySongListModel {
  final InfinitePageController _pageController;

  InfinitePageController get pageController => _pageController;

  ///InfinitePageView会在第一个位置和最后一个位置分别添加真是列表的最后一个和第一个元素，所以默认的初试页面应该为1
  PlaySongListModel() : _pageController = InfinitePageController() {
    _pageController.addListener(_onPageChanged);
    MusicService.instance.currentIndexStream
        .listen(_onPlayerCurrentIndexChanged);
  }

  void _onPageChanged() {
    if (_pageController.positions.length != 1) {
      return;
    }
    final realPageIndex = _pageController.page!.round();
    final playingIndex = MusicService.instance.playingIndex;
    if (playingIndex < 0 || realPageIndex == playingIndex) {
      return;
    }
    debugPrint(
        "onPageChanged, realPageIndex = $realPageIndex, playingIndex = $playingIndex");
    MusicService.instance.playSongWithPlayingIndicesIndex(realPageIndex);
  }

  void _onPlayerCurrentIndexChanged(int showingListIndex) {
    if (_pageController.positions.length != 1) {
      return;
    }
    final realPageIndex = _pageController.page!.round();
    final playingIndex = MusicService.instance
        .convertShowingListIndexToPlayingIndex(showingListIndex);
    if (playingIndex < 0 || realPageIndex == playingIndex) {
      return;
    }
    debugPrint(
        "onPlayerCurrentIndexChanged, pageIndex = $realPageIndex, showingListIndex = $showingListIndex, playingIndex = $playingIndex");
    _pageController.jumpToPage(playingIndex);
  }

  void dispose() {
    _pageController.dispose();
  }
}

class SongModel {
  final Song song;

  final _songDao = SongDao();

  SongModel(this.song) {
    refresh();
  }

  void refresh() async {
    _isFavorite =
        await _songDao.isSongInFavoriteList(song.plt.name, song.pltId);
    _isFavoriteController.add(_isFavorite);
  }

  bool _isFavorite = false;

  bool get isFavorite => _isFavorite;

  var _isFavoriteController = StreamController<bool>.broadcast();

  Stream<bool> get isFavoriteStream => _isFavoriteController.stream;

  void toggleFavorite() async {
    _isFavoriteController.add(!_isFavorite);
    var isSuccessful = false;
    if (isFavorite) {
      isSuccessful =
          await _songDao.deleteSongFromSongList(SongList.FAVOR_ID, song.id);
      if (isSuccessful) _isFavorite = false;
    } else {
      final addedSongs =
          await _songDao.addSongsToSongList(SongList.FAVOR_ID, [song]);
      isSuccessful = addedSongs == 1;
      if (isSuccessful) _isFavorite = true;
    }
    if (isSuccessful) {
      notifyMySongListChanged();
    }
    _isFavoriteController.add(_isFavorite);
  }

  void dispose() {
    _isFavoriteController.close();
  }
}
