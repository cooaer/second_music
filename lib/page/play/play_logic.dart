import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:second_music/entity/song.dart';
import 'package:second_music/entity/song_list.dart';
import 'package:second_music/page/home/my_song_list/logic.dart';
import 'package:second_music/repository/local/database/song/dao.dart';
import 'package:second_music/service/music_service.dart';
import 'package:second_music/widget/infinite_page_view.dart';

class PlaySongListLogic extends GetxController {
  final int? playingIndex;
  final Song? currentSong;
  InfinitePageController? _pageController;

  ///InfinitePageView会在第一个位置和最后一个位置分别添加真是列表的最后一个和第一个元素，所以默认的初试页面应该为1
  PlaySongListLogic({this.playingIndex, this.currentSong}) {
    MusicService().currentIndexStream.listen(_onCurrentIndexChanged);
    MusicService().playingIndicesStream.listen((_onPlayingIndicesChanged));
  }

  @override
  void onInit() {
    super.onInit();
    if (currentSong != null) {
      MusicService().playSong(currentSong!);
    }
  }

  InfinitePageController newPageController() {
    final initialPage = max(MusicService().playingIndex + 1, 1);
    final newPageController = InfinitePageController(initialPage: initialPage);
    newPageController.addListener(_onPageChanged);
    _pageController = newPageController;
    return newPageController;
  }

  int get playingIndexInInfinitePageView =>
      (MusicService().playingIndex + 1) % MusicService().playlistSize;

  void _onPageChanged() {
    if (_pageController == null || _pageController!.positions.length != 1) {
      return;
    }
    final realPageIndex = _pageController!.realPage!;
    final playingIndex = MusicService().playingIndex;
    if (playingIndex < 0 || realPageIndex == playingIndex) {
      return;
    }
    debugPrint(
        "onPageChanged, realPageIndex = $realPageIndex, playingIndex = $playingIndex");
    MusicService().playSongWithPlayingIndicesIndex(realPageIndex);
  }

  void _onCurrentIndexChanged(int showingListIndex) {
    if (_pageController == null || _pageController!.positions.length != 1) {
      return;
    }
    final realPageIndex = _pageController!.realPage;
    final playingIndex =
        MusicService().convertShowingListIndexToPlayingIndex(showingListIndex);
    if (playingIndex < 0 || realPageIndex == playingIndex) {
      return;
    }
    debugPrint(
        "PlayLogic.onCurrentIndexChanged, pageIndex = $realPageIndex, showingListIndex = $showingListIndex, playingIndex = $playingIndex");
    _pageController?.jumpToPage(playingIndex);
  }

  void _onPlayingIndicesChanged(List<int> indices) {
    if (_pageController == null || _pageController!.positions.length != 1) {
      return;
    }
    final playingIndex = MusicService().playingIndex;
    if (playingIndex == -1) {
      return;
    }
    _pageController?.jumpToPage(playingIndex);
  }

  @override
  void onClose() {}
}

class SongLogic {
  final Song song;

  final _songDao = SongDao();

  SongLogic(this.song) {
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
