import 'dart:async';

import 'package:second_music/entity/enum.dart';
import 'package:second_music/entity/playing_progress.dart';
import 'package:second_music/entity/song.dart';
import 'package:second_music/page/play/model.dart';
import 'package:second_music/player/music_messages.dart';
import 'package:second_music/player/message_extension.dart';

enum PlayerState {
  PREPARED,
  PLAYING,
  PAUSED,
  STOPPED,
  COMPLETED,
  SEEK_COMPLETED,
  ERROR,
}

class MusicPlayer implements MusicPlayerCallbackApi {
  static MusicPlayer _instance;

  static MusicPlayer get instance {
    if (_instance == null) {
      _instance = new MusicPlayer._();
    }
    return _instance;
  }

  var _musicPlayerApi = new MusicPlayerControllerApi();

  MusicPlayer._() {
    MusicPlayerCallbackApi.setup(this);
    _initPlayer();
  }

  void _initPlayer() {}

  //=======  callback api  =======

  @override
  void onPlayerStateChanged(StateMessage arg) {
    PlayerState state;
    switch (arg.state) {
      case "prepared":
        state = PlayerState.PREPARED;
        break;
      case "playing":
        state = PlayerState.PLAYING;
        break;
      case "paused":
        state = PlayerState.PAUSED;
        break;
      case "stopped":
        state = PlayerState.STOPPED;
        break;
      case "completed":
        state = PlayerState.COMPLETED;
        break;
      case "seekCompleted":
        state = PlayerState.SEEK_COMPLETED;
        break;
      case "error":
        state = PlayerState.ERROR;
        break;
    }

    if (state != null) {
      this._setPlayerState(state);
    }
  }

  @override
  void onPlayingSongListChanged(SongsMessage message) {
    this._setPlayingSongList(message.toSongs());
  }

  @override
  void onShowingSongListChanged(SongsMessage message) {
    this._setShowingSongList(message.toSongs());
  }

  @override
  void onPositionChanged(PositionMessage message) {
    var progress = PlayingProgress.fromMessage(message);
    this._setPlayingProgress(progress);
  }

  @override
  void onPlayingSongChanged(SongMessage message) {
    this._setCurrentSong(Song.fromMessage(message));
  }

  //=======  callback api  ======

  //==============当前展示的播放列表===============
  var _showingSongList = List<Song>.empty();

  List<Song> get showingSongList => _showingSongList;
  var _showingSongListController = StreamController<List<Song>>.broadcast();

  Stream<List<Song>> get showingSongListStream =>
      _showingSongListController.stream;

  void _setShowingSongList(List<Song> songs) {
    if (songs == null) {
      return;
    }
    _showingSongList = songs;
    _showingSongListController.add(songs);
  }

  //==============当前真正播放中的歌曲列表=============

  var _playingSongList = List<Song>.empty();

  List<Song> get playingSongList => _playingSongList;
  var _playingSongListController = StreamController<List<Song>>.broadcast();

  Stream<List<Song>> get playingSongListStream =>
      _playingSongListController.stream;

  void _setPlayingSongList(List<Song> songs) {
    if (songs == null) {
      return;
    }
    _playingSongList = songs;
    _playingSongListController.add(songs);
    _resetCurrentIndex();
  }

  // ===============当前播放的歌曲================

  Song _currentSong;

  var _currentSongController = StreamController<Song>.broadcast();

  Stream<Song> get currentSongStream => _currentSongController.stream;

  Song get currentSong => _currentSong;

  void _setCurrentSong(Song song) {
    if (song == _currentSong) {
      return;
    }
    this._currentSong = song;
    this._currentSongController.add(song);
    _resetCurrentIndex();
  }

  int _currentIndex;

  int get currentIndex => _currentIndex;

  void _resetCurrentIndex() {
    this._currentIndex = _playingSongList.indexOf(_currentSong);
  }

  //===========播放状态===========
  var _playerState = PlayerState.STOPPED;

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

  bool get isPlaying => _playerState == PlayerState.PLAYING;

  // ===========切换播放模式===========

  var _playMode = PlayMode.repeat;

  var _playModeController = StreamController<PlayMode>.broadcast();

  Stream<PlayMode> get playModeStream => _playModeController.stream;

  PlayMode get playMode => _playMode;

  set playMode(PlayMode mode) {
    if (mode == _playMode) {
      return;
    }
    _playMode = mode;
    _playModeController.add(mode);
  }

  // =================播放进度================

  // 当前歌曲的时常及当前播放位置
  // 默认总时长为7：09
  PlayingProgress _playingProgress = new PlayingProgress(0, 429);

  PlayingProgress get playingProgress => _playingProgress;
  var _playingProgressController =
      StreamController<PlayingProgress>.broadcast();

  Stream<PlayingProgress> get playingProgressStream =>
      _playingProgressController.stream;

  void _setPlayingProgress(PlayingProgress progress) {
    if (progress == null) return;
    this._playingProgress = progress;
    _playingProgressController.add(progress);
  }

  //当前播放歌曲的进度
  var _currentPosition = 0;

  int get currentPosition => _currentPosition;
  var _currentPositionController = StreamController<int>.broadcast();

  Stream<int> get currentPositionStream => _currentPositionController.stream;

  void _setCurrentPosition(int positionInSeconds) {
    if (_currentPosition == positionInSeconds) {
      return;
    }
    _currentPosition = positionInSeconds;
    _currentPositionController.add(positionInSeconds);
  }

  //当前播放的歌曲的时长
  var _currentDuration = 0;

  int get currentDuration => _currentDuration;
  var _currentDurationController = StreamController<int>.broadcast();

  Stream<int> get currentDurationStream => _currentDurationController.stream;

  void _setCurrentDuration(int durationInSeconds) {
    if (_currentDuration == durationInSeconds) {
      return;
    }
    _currentDuration = durationInSeconds;
    _currentDurationController.add(durationInSeconds);
  }

  void seekTo(int seconds) {
    var positionMessage = new PositionMessage();
    positionMessage.position = seconds;
    _musicPlayerApi.seekTo(positionMessage);
  }

  // ===========播放控制==========
  void playSongList(List<Song> songs) {
    _musicPlayerApi.playSongList(songs.toMessage());
  }

  void playSong(Song song) {
    _musicPlayerApi.playSong(song.toMessage());
  }

  void playNext() {
    _musicPlayerApi.playNext();
  }

  void playPrev() {
    _musicPlayerApi.playPrev();
  }

  void playOrPause() {
    if (isPlaying) {
      pause();
    } else {
      play();
    }
  }

  void play() {
    _musicPlayerApi.play();
  }

  void pause() {
    _musicPlayerApi.pause();
  }

  /// 切换播放模式，当前播放的歌曲继续
  void switchPlayMode() {
    var nextIndex = (_playMode.index + 1) % PlayMode.values.length;
    var nextMode = PlayMode.values[nextIndex];
    var playModeMessage = new PlayModeMessage();
    playModeMessage.playMode = nextMode.toString().split('.').last;
    _musicPlayerApi.setPlayMode(playModeMessage);
  }

  void addSongToPlaylistNext(Song song) {
    _musicPlayerApi.addSongToPlaylistNext(song.toMessage());
  }

  void deleteSongFromPlaylist(Song song) {
    _musicPlayerApi.deleteSongFromPlaylist(song.toMessage());
  }

  void clearPlaylist() {
    _musicPlayerApi.clearPlaylist();
  }

  //PlayControllers
  var _songControllerModels = <SongControllerModel>[];

  void registerSongControllerModel(SongControllerModel model) {
    _songControllerModels.add(model);
  }

  void unregisterSongControllerModel(SongControllerModel model) {
    _songControllerModels.remove(model);
  }

  void playIndexWithoutAnimation(int index,
      {SongControllerModel withoutModel}) async {
    if (index == null || index >= _playingSongList.length) return;
    if (currentIndex == index) return;

    for (var model in _songControllerModels) {
      if (model != withoutModel) {
        model.jumpTo(index);
      }
    }

    playSong(playingSongList[index]);
  }
//=============== utils ===============

}
