import 'dart:async';

import 'package:dart_extensions_methods/dart_extension_methods.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:second_music/entity/enum.dart';
import 'package:second_music/entity/playing_progress.dart';
import 'package:second_music/entity/song.dart';
import 'package:second_music/repository/local/preference/playing.dart';
import 'package:second_music/repository/remote/platform/music_provider.dart';

enum PlayerState {
  idle,
  loading,
  buffering,
  ready,
  completed,
}

class MusicService {
  static MusicService? _instance;

  static MusicService get instance {
    if (_instance == null) {
      _instance = new MusicService._();
    }
    return _instance!;
  }

  final _audioPlayer = AudioPlayer();
  ConcatenatingAudioSource? _playlist;

  MusicService._() {
    _initPlayer();
  }

  void _initPlayer() async {
    await JustAudioBackground.init(
      androidNotificationChannelId:
          "com.github.cooaer.second_music.channel.audio",
      androidNotificationChannelName: "Audio playback",
      androidNotificationOngoing: true,
    );

    _listenStateChanged();

    _initPlayMode();
  }

  void _listenStateChanged() {
    _audioPlayer.processingStateStream
        .listen(_onProcessingStateChanged, onError: _onStreamError);
    _audioPlayer.playingStream
        .listen(_onPlayingChanged, onError: _onStreamError);
    _audioPlayer.durationStream
        .listen(_onDurationChanged, onError: _onStreamError);
    _audioPlayer.positionStream
        .listen(_onPositionChanged, onError: _onStreamError);
    _audioPlayer.currentIndexStream
        .listen(_onCurrentIndexChanged, onError: _onStreamError);
    _audioPlayer.sequenceStream
        .listen(_onShowingSongListChanged, onError: _onStreamError);
    _audioPlayer.shuffleIndicesStream
        .listen(_onShuffleIndicesChanged, onError: _onStreamError);
    _audioPlayer.loopModeStream
        .listen(_onPlayModeChanged, onError: _onStreamError);
    _audioPlayer.shuffleModeEnabledStream
        .listen(_onShuffleModeChanged, onError: _onStreamError);
  }

  void _initPlayMode() {
    _playMode = PlayingStorage.instance.playMode();
    setAudioPlayerPlayMode(_playMode);
  }

  //=======  callback api  =======

  void _onProcessingStateChanged(ProcessingState justState) {
    PlayerState? appState;
    switch (justState) {
      case ProcessingState.idle:
        appState = PlayerState.idle;
        break;
      case ProcessingState.loading:
        appState = PlayerState.loading;
        break;
      case ProcessingState.buffering:
        appState = PlayerState.buffering;
        break;
      case ProcessingState.ready:
        appState = PlayerState.ready;
        break;
      case ProcessingState.completed:
        appState = PlayerState.completed;
        break;
    }

    this._setPlayerState(appState);
  }

  void _onPlayingChanged(bool playing) {
    _setPlaying(playing);
  }

  void _onDurationChanged(Duration? duration) {
    // debugPrint("onDurationChanged, duration = ${duration?.inMilliseconds}");
    this._setPlayingProgress(duration: duration);
  }

  void _onPositionChanged(Duration position) {
    // debugPrint("onPositionChanged, position= ${position.inMilliseconds}");
    this._setPlayingProgress(position: position);
  }

  void _onCurrentIndexChanged(int? currentIndex) {
    debugPrint("onCurrentIndexChanged: currentIndex = $currentIndex");
    if (currentIndex == null) return;
    _setCurrentIndex(currentIndex);
  }

  void _onShowingSongListChanged(List<IndexedAudioSource>? sources) {
    debugPrint("onShowingSongListChanged: sourceCount = ${sources?.length}");
    if (sources.isNullOrEmpty()) {
      _setShowingSongList([]);
      return;
    }
    final newSongs = sources!
        .map((source) => _allSongs[(source.tag as MediaItem).id])
        .whereType<Song>()
        .toList();
    _setShowingSongList(newSongs);
  }

  List<int> _shuffleIndices = <int>[];

  void _onShuffleIndicesChanged(List<int>? indices) {
    debugPrint("onPlayingSongListChanged: indicesCount = ${indices?.length}");
    _shuffleIndices = indices ?? [];
    _resetPlayingIndices();
  }

  void _onPlayModeChanged(LoopMode loopMode) {
    if (loopMode == LoopMode.all) {
      _setPlayMode(PlayMode.repeat);
    } else if (loopMode == LoopMode.one) {
      _setPlayMode(PlayMode.repeatOne);
    }
  }

  void _onShuffleModeChanged(bool enable) {
    if (enable) {
      _setPlayMode(PlayMode.random);
    }
  }

  void _onStreamError(Object e, StackTrace stackTrace) {
    if (e is PlayerException) {
      print('Error: code = ${e.code}, msg = ${e.message}');
    } else {
      print('An error occurred: $e');
    }
    debugPrint("streamError, stackTrace = $stackTrace");
  }

  //==============播放中===============

  var _playing = false;

  bool get playing => _playing;
  var _playingController = StreamController<bool>.broadcast();

  Stream<bool> get playingStream => _playingController.stream;

  void _setPlaying(bool playing) {
    if (_playing == playing) {
      return;
    }
    _playing = playing;
    _playingController.add(_playing);
  }

  //==============当前展示的播放列表中的歌曲，按照加入的顺序排列===============
  final _allSongs = <String, Song>{};

  int get playlistSize => _showingSongList.length;

  var _showingSongList = <Song>[];

  List<Song> get showingSongList => _showingSongList;
  var _showingSongListController = StreamController<List<Song>>.broadcast();

  Stream<List<Song>> get showingSongListStream =>
      _showingSongListController.stream;

  void _setShowingSongList(List<Song> songs) {
    _showingSongList = songs;
    _showingSongListController.add(songs);
    _resetPlayingIndices();
  }

  //===============播放列表中歌曲的索引列表,按照播放顺序排列================
  var _playingIndices = <int>[];

  List<int> get playingIndices => _playingIndices;

  final _playingIndicesController = StreamController<List<int>>.broadcast();

  Stream<List<int>> get playingIndicesStream =>
      _playingIndicesController.stream;

  ///playingIndices依赖playMode、showingSongList和shuffleIndices，任一改变都要重置payingIndices
  void _resetPlayingIndices() {
    List<int> playingIndices;
    switch (_playMode) {
      case PlayMode.repeatOne:
      case PlayMode.repeat:
        playingIndices = _showingSongList.asMap().keys.toList();
        break;
      case PlayMode.random:
        playingIndices = _shuffleIndices;
        break;
    }
    if (_playingIndices == playingIndices) {
      return;
    }
    _playingIndices = playingIndices;
    _playingIndicesController.add(_playingIndices);
  }

  // var _shuffleIndices = <int>[];
  //
  // var _playingSongList = <Song>[];
  //
  // List<Song> get playingSongList => _playingSongList;
  // var _playingSongListController = StreamController<List<Song>>.broadcast();
  //
  // Stream<List<Song>> get playingSongListStream =>
  //     _playingSongListController.stream;
  //
  // void _setPlayingSongList(List<int> indices) {
  //   if (_shuffleIndices == indices) {
  //     return;
  //   }
  //   _shuffleIndices = indices;
  //   List<Song> songList;
  //   switch (_playMode) {
  //     case PlayMode.repeatOne:
  //     case PlayMode.repeat:
  //       songList = _showingSongList;
  //       break;
  //     case PlayMode.random:
  //       songList = indices.map((index) => _showingSongList[index]).toList();
  //       break;
  //   }
  //   _playingSongList = songList;
  //   _playingSongListController.add(songList);
  // }

  // ===============当前播放的歌曲================

  Song? get currentSong => _currentIndex >= 0 && _currentIndex < playlistSize
      ? _showingSongList[_currentIndex]
      : null;

  // 当前播放歌曲在列表的索引
  int _currentIndex = -1;

  int get currentIndex => _currentIndex;

  final _currentIndexController = StreamController<int>.broadcast();

  Stream<int> get currentIndexStream => _currentIndexController.stream;

  void _setCurrentIndex(int index) {
    debugPrint("setCurrentIndex: index = $index");
    if (_currentIndex == index) {
      return;
    }
    _currentIndex = index;
    _currentIndexController.add(index);
    debugPrint("setCurrentIndex: currentSong = ${currentSong?.name}");
  }

  //===========播放状态===========
  var _playerState = PlayerState.idle;

  var _playerStateController = StreamController<PlayerState>.broadcast();

  Stream<PlayerState> get playerStateStream => _playerStateController.stream;

  PlayerState get playerState => _playerState;

  void _setPlayerState(PlayerState state) {
    if (state == _playerState) {
      return;
    }
    _playerState = state;
    _playerStateController.add(state);
  }

  // ===========切换播放模式===========

  var _playMode = PlayMode.repeat;

  var _playModeController = StreamController<PlayMode>.broadcast();

  Stream<PlayMode> get playModeStream => _playModeController.stream;

  PlayMode get playMode => _playMode;

  void _setPlayMode(PlayMode mode) {
    debugPrint("setPlayMode, mode = ${mode.name}");
    if (mode == _playMode) {
      return;
    }
    _playMode = mode;
    _playModeController.add(mode);
    PlayingStorage.instance.savePlayMode(mode);
    //如果播放模式改变，需要切换播放列表
    _resetPlayingIndices();
  }

  // =================播放进度================

  // 当前歌曲的时常及当前播放位置
  // 默认总时长为7：09
  PlayingProgress _playingProgress = PlayingProgress(0, 429);

  PlayingProgress get playingProgress => _playingProgress;
  var _playingProgressController =
      StreamController<PlayingProgress>.broadcast();

  Stream<PlayingProgress> get playingProgressStream =>
      _playingProgressController.stream;

  void _setPlayingProgress({Duration? duration, Duration? position}) {
    if (duration != null) {
      this._playingProgress.duration = duration.inMilliseconds;
    }
    if (position != null) {
      this._playingProgress.position = position.inMilliseconds;
    }
    if (_playingProgress.position > _playingProgress.duration) {
      _playingProgress.duration = _playingProgress.position;
    }
    _playingProgressController.add(_playingProgress);
  }

  Future<void> seekTo(int milliseconds) async {
    await _audioPlayer.seek(Duration(milliseconds: milliseconds));
  }

  // ===========播放控制==========

  //切换播放模式（列表循环、单曲循环、随机）
  Future<void> switchPlayMode() async {
    final nextIndex = (_playMode.index + 1) % PlayMode.values.length;
    final nextMode = PlayMode.values[nextIndex];
    await setAudioPlayerPlayMode(nextMode);
  }

  Future<void> setAudioPlayerPlayMode(PlayMode mode) async {
    if (mode == PlayMode.random) {
      await _audioPlayer.setShuffleModeEnabled(true);
      await _audioPlayer.setLoopMode(LoopMode.off);
    } else {
      await _audioPlayer.setShuffleModeEnabled(false);
      if (mode == PlayMode.repeatOne) {
        await _audioPlayer.setLoopMode(LoopMode.one);
      } else if (mode == PlayMode.repeat) {
        await _audioPlayer.setLoopMode(LoopMode.all);
      }
    }
  }

  Future<void> playSongList(List<Song> songs) async {
    _allSongs.clear();
    for (var song in songs) {
      _allSongs[song.uniqueId] = song;
    }
    if (_playlist == null) {
      await _createAndSetPlayList(songs);
    } else {
      await _playlist!.removeRange(0, playlistSize);
      await _playlist!.addAll(songs.map((e) => e.toAudioSource()).toList());
    }
    await _audioPlayer.seek(Duration.zero, index: _playingIndices[0]);
  }

  Future<void> _createAndSetPlayList(List<Song> songs) async {
    final sources = songs.map((song) => song.toAudioSource()).toList();
    final playlist = ConcatenatingAudioSource(
        useLazyPreparation: true,
        shuffleOrder: DefaultShuffleOrder(),
        children: sources);
    await _audioPlayer.setAudioSource(playlist);
    _playlist = playlist;
  }

  Future<void> playSong(Song song) async {
    if (_allSongs.containsKey(song.uniqueId)) {
      final index = _showingSongList.indexOf(song);
      playSongWithShowingListIndex(index);
      return;
    }
    if (song.streamUrl.isEmpty) {
      await MusicProvider(song.plt).parseTrack(song);
    }
    debugPrint("playSong: name = ${song.name}, streamUrl = ${song.streamUrl}");
    _allSongs[song.uniqueId] = song;
    final int songIndex;
    if (_playlist == null) {
      await _createAndSetPlayList([song]);
      songIndex = 0;
    } else {
      await _playlist!.add(song.toAudioSource());
      songIndex = playlistSize - 1;
    }
    await _audioPlayer.seek(Duration.zero, index: songIndex);
  }

  Future<void> playSongWithShowingListIndex(int index) async {
    if (currentIndex == index) {
      return;
    }
    await _audioPlayer.seek(Duration.zero, index: index);
  }

  Future<void> playSongWithPlayingIndicesIndex(int index) async {
    if (currentIndex == _playingIndices[index]) {
      return;
    }
    await _audioPlayer.seek(Duration.zero, index: _playingIndices[index]);
  }

  Future<void> playNext() async {
    final currentIndexIndex = _playingIndices.indexOf(currentIndex);
    if (currentIndexIndex == -1) {
      debugPrint(
          "musicService.playNext, error, currentIndexIndex = $currentIndexIndex");
      return;
    }
    final nextIndex = _playingIndices[currentIndexIndex + 1];
    await _audioPlayer.seek(Duration.zero, index: nextIndex);
  }

  Future<void> playPrev() async {
    final currentIndexIndex = _playingIndices.indexOf(currentIndex);
    if (currentIndexIndex == -1) {
      debugPrint(
          "musicService.playPrev, error, currentIndexIndex = $currentIndexIndex");
      return;
    }
    final prevIndex = _playingIndices[currentIndexIndex - 1];
    await _audioPlayer.seek(Duration.zero, index: prevIndex);
  }

  Future<void> playOrPause() async {
    if (playing) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> play() async {
    await _audioPlayer.play();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> addToPlayListAndPlayNext(Song song) async {}

  Future<void> deleteSongFromPlaylist(Song song) async {
    final index = _showingSongList.indexOf(song);
    if (index >= 0) {
      _allSongs.remove(song.uniqueId);
      await _playlist?.removeAt(index);
    }
  }

  void clearPlaylistWithoutCurrentSong() {
    if (currentIndex != 0) {
      _playlist?.removeRange(0, currentIndex);
    }
    if (currentIndex != playlistSize - 1) {
      _playlist?.removeRange(currentIndex + 1, playlistSize);
    }
  }

//=============== utils ===============

  //获取在播放列表中真实的索引地址
  int _getShowingListIndex(int playingListIndex) {
    int showingListIndex;
    switch (_playMode) {
      case PlayMode.repeatOne:
      case PlayMode.repeat:
        showingListIndex = playingListIndex;
        break;
      case PlayMode.random:
        showingListIndex = _shuffleIndices[playingListIndex];
        break;
    }
    return showingListIndex;
  }

  List<Song> _filterInPlaylist(List<Song> songs) {
    return songs
        .where((song) => !_allSongs.containsKey(song.uniqueId))
        .toList();
  }
}

extension PlayerSongExtension on Song {
  AudioSource toAudioSource() {
    return AudioSource.uri(Uri.parse(this.streamUrl),
        tag: MediaItem(
          id: this.uniqueId,
          title: this.name,
          album: this.album?.name,
          artist: this.singer?.name,
          artUri: Uri.tryParse(this.cover),
        ));
  }
}