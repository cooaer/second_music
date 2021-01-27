import 'dart:async';
import 'dart:collection';

import 'package:second_music/entity/enum.dart';
import 'package:second_music/entity/playing_progress.dart';
import 'package:second_music/entity/song.dart';
import 'package:second_music/player/music_messages.dart';
import 'package:second_music/player/message_extension.dart';
import 'package:second_music/repository/remote/platform/music_provider.dart';

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

  //缓存包含完整歌曲信息的原始歌曲
  var _songsCache = SongsCache();
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
  void onShowingSongListChanged(SongsMessage message) {
    this._setShowingSongList(_songsCache.getCachedSongs(message));
  }

  @override
  void onPlayingSongListChanged(SongsMessage message) {
    this._setPlayingSongList(_songsCache.getCachedSongs(message));
  }

  @override
  void onPositionChanged(PositionMessage message) {
    var progress = PlayingProgress.fromMessage(message);
    this._setPlayingProgress(progress);
  }

  @override
  void onPlayingSongChanged(SongMessage message) {
    this._setCurrentSong(_songsCache.getCachedSong(message));
  }

  //=======  callback api  ======

  //==============当前展示的播放列表中的歌曲，按照加入的书序排列===============
  var _showingSongList = <Song>[];

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

  //==============当前真正播放中的歌曲列表，按照播放顺序排列=============

  var _playingSongList = <Song>[];

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
    print(
        "musicPlayer: _setPlayingSongList, resetCurrentIndex, currentIndex=$_currentIndex, currentSong=${currentSong?.name}");
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
    print(
        "musicPlayer: setCurrentSong, resetCurrentIndex, currentIndex=$_currentIndex, currentSong=${song?.name}");
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

  void seekTo(int seconds) {
    var positionMessage = new PositionMessage();
    positionMessage.position = seconds;
    _musicPlayerApi.seekTo(positionMessage);
  }

  // ===========播放控制==========
  void playSongList(List<Song> songs) {
    _musicPlayerApi.playSongList(songs.toMessage());
    _songsCache.replaceSongs(songs);
  }

  void playSong(Song song) async {
    if (song.streamUrl == null || song.streamUrl.isEmpty) {
      await MusicProvider(song.plt).parseTrack(song);
    }
    _musicPlayerApi.playSong(song.toMessage());
    _songsCache.addSong(song);
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

  void addSongToPlaylistNext(Song song) async {
    if (song.streamUrl == null || song.streamUrl.isEmpty) {
      await MusicProvider(song.plt).parseTrack(song);
    }
    _musicPlayerApi.addSongToPlaylistNext(song.toMessage());
    _songsCache.addSong(song);
  }

  void deleteSongFromPlaylist(Song song) {
    _musicPlayerApi.deleteSongFromPlaylist(song.toMessage());
    _songsCache.deleteSong(song);
  }

  void clearPlaylist() {
    _musicPlayerApi.clearPlaylist();
    _songsCache.clear();
  }

  //PlayControllers
  var _playingSongListControllerModels = <SongListController>[];

  void registerSongControllerModel(SongListController model) {
    _playingSongListControllerModels.add(model);
  }

  void unregisterSongControllerModel(SongListController model) {
    _playingSongListControllerModels.remove(model);
  }

  void playIndexWithoutAnimation(int index,
      {SongListController withoutModel}) async {
    if (index == null || index >= _playingSongList.length) return;
    if (currentIndex == index) return;

    this._currentIndex = index;

    for (var model in _playingSongListControllerModels) {
      if (model != withoutModel) {
        model.jumpTo(index);
      }
    }

    playSong(playingSongList[index]);
  }
//=============== utils ===============

}

abstract class SongListController {
  void jumpTo(int index);
}

//歌曲缓存器
class SongsCache {
  var _unorderedSongs = LinkedHashMap<String, Song>();

  Map<String, Song> get unorderedSongs => _unorderedSongs;

  void replaceSongs(List<Song> songs) {
    var newMap = LinkedHashMap<String, Song>();
    for (var song in songs) {
      newMap[song.uniqueId] = song;
    }
    _unorderedSongs.clear();
    _unorderedSongs.addAll(newMap);
  }

  void addSong(Song song) {
    _unorderedSongs[song.uniqueId] = song;
  }

  void deleteSong(Song song) {
    _unorderedSongs.remove(song.uniqueId);
  }

  void clear() {
    _unorderedSongs.clear();
  }

  List<Song> getCachedSongs(SongsMessage message) {
    var cachedSongs = <Song>[];
    for (var song in message.songs) {
      if (song is Map) {
        var uniqueId = song['plt'].toString() + song['id'].toString();
        if (_unorderedSongs.containsKey(uniqueId)) {
          cachedSongs.add(_unorderedSongs[uniqueId]);
        }
      }
    }
    return cachedSongs;
  }

  Song getCachedSong(SongMessage message) {
    return _unorderedSongs[message.uniqueId];
  }
}
