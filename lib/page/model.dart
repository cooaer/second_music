import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:second_music/model/enum.dart';
import 'package:second_music/model/song.dart';
import 'package:second_music/network/platform/music_provider.dart';
import 'package:second_music/page/play/model.dart';
import 'package:second_music/storage/preference/playing.dart';

//播放控制
class PlayControlModel {
  static PlayControlModel _instance;

  static PlayControlModel get instance {
    if (_instance == null) {
      _instance = PlayControlModel._();
      AudioPlayer.logEnabled = true;
    }
    return _instance;
  }

  var _audioPlayer = AudioPlayer();

  PlayControlModel._() {
    initAudioPlayer();
    initSongList();
  }

  void initAudioPlayer() {
    _audioPlayer.setReleaseMode(ReleaseMode.STOP);
    _audioPlayer.onDurationChanged.listen((duration) {
      _currentDurationController.add(duration.inSeconds);
    });
    _audioPlayer.onAudioPositionChanged.listen((position) {
      _currentPositionController.add(position.inSeconds);
    });
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _setPlayerState(state);
    });
    _audioPlayer.onPlayerCompletion.listen((event) {
      _onPlayerCompletion();
    });
    _audioPlayer.onPlayerError.listen((msg) {});
  }

  void _onPlayerCompletion(){
    switch(playMode){
      case PlayMode.repeatOne:
        playIndexWithoutAnimation(currentIndex, force: true);
        break;
      case PlayMode.repeat:
      case PlayMode.random:
        playNext();
        break;
    }
  }

  void initSongList() {
    _playMode = PlayingStorage.instance.playMode();
    _currentIndex = PlayingStorage.instance.playingIndex();
    _showingList = PlayingStorage.instance.playingList();
    _playingList = _refreshPlayingList(_showingList);
  }

  // ===============当前播放的歌曲================

  var _currentSongController = StreamController<Song>.broadcast();

  Stream<Song> get currentSongStream => _currentSongController.stream;

  Song get currentSong {
    if (_currentIndex < 0 || _currentIndex >= _playingList.length) {
      return null;
    }
    return _currentIndex < _playingList.length ? _playingList[_currentIndex] : null;
  }

  // ===============播放列表================
  /// 当前播放歌曲的位置
  var _currentIndex = -1;

  int get currentIndex => _currentIndex;

  /// 真正的播放列表
  var _playingList = <Song>[];

  List<Song> get playingList => _playingList;
  var _playingListController = StreamController<List<Song>>.broadcast();

  Stream<List<Song>> get playingListStream => _playingListController.stream;

  /// 展示的播放列表
  var _showingList = <Song>[];

  List<Song> get showingList => _showingList;

  var _showingListController = StreamController<List<Song>>.broadcast();

  Stream<List<Song>> get showingListStream => _showingListController.stream;

  List<Song> _refreshPlayingList(List<Song> showingList, {PlayMode playMode}) {
    playMode = playMode ?? _playMode;
    final songs = List.of(showingList);
    final newPlayingList = <Song>[];
    switch (playMode) {
      case PlayMode.repeat:
      case PlayMode.repeatOne:
        newPlayingList.addAll(songs);
        break;
      case PlayMode.random:
        newPlayingList.addAll(List.from(songs)..shuffle());
        break;
    }
    return newPlayingList;
  }

  // 从播放列表中删除
  void deleteSongFromList(Song song) async {
    final showingList = List.of(_showingList);
    if (showingList.remove(song)) {
      _onShowingSongChanged(showingList);
    }

    final playingList = List.of(_playingList);
    var deleteIndex = playingList.indexOf(song);
    if (deleteIndex != null) {
      playingList.removeAt(deleteIndex);
      _onPlayingListChanged(playingList);
    }

    if (deleteIndex < _currentIndex) {
      _currentIndex--;
    } else if (deleteIndex == _currentIndex) {
      await _stop();
      await play();
    }
    _onCurrentIndexChanged(_currentIndex);
    _onCurrentSongChanged(getSongFromList(playingList, _currentIndex));
  }

  // 添加到下一首播放，不影响当前播放的歌曲
  void addToNext(Song song) {
    final showingList = List.of(_showingList);
    final playingList = List.of(_playingList);

    showingList.remove(song);
    final showIndex = showingList.indexOf(currentSong);
    showingList.insert(showIndex + 1, song);
    _onShowingSongChanged(showingList);

    final index = playingList.indexOf(song);
    if (index >= 0) {
      playingList.removeAt(index);
      if (index < _currentIndex) {
        _currentIndex--;
      }
    }

    playingList.insert(_currentIndex + 1, song);
    _onPlayingListChanged(playingList);
    _onCurrentIndexChanged(_currentIndex);
  }

  // 清空播放列表
  void clear() async {
    await _stop();

    _currentIndex = -1;

    _onPlayingListChanged([]);
    _onShowingSongChanged([]);
    _onCurrentSongChanged(null);
  }

  // 立即播放，添加到当前播放列表中
  void playSongNow(Song song) {
    if (song == currentSong && _state == AudioPlayerState.PLAYING) return;
    _stop();
    addToNext(song);
//    playNext();
    playSongWithoutAnimation(song);
  }

  // 替换播放列表
  void playAndReplaceSongList(List<Song> songs) async {
    if (songs == null || songs.isEmpty) return;

    await _stop();

    _currentIndex = 0;

    final newList = List.of(songs);
    _onShowingSongChanged(newList);

    var newPlayingList = _refreshPlayingList(newList);
    _onPlayingListChanged(newPlayingList);

    play();

    _onCurrentIndexChanged(_currentIndex);
    _onCurrentSongChanged(getSongFromList(newPlayingList, _currentIndex));
  }

  void _onShowingSongChanged(List<Song> songs) {
    _showingList = songs;
    _showingListController.add(songs);
    PlayingStorage.instance.savePlayingList(songs);
  }

  void _onPlayingListChanged(List<Song> songs) {
    _playingList = songs;
    _playingListController.add(songs);
  }

  void _onCurrentIndexChanged(int currentIndex) {
    if(playingList.isEmpty) return;

    for (var model in _songControllerModels) {
      model.jumpToCurrent();
    }
  }

  void _onCurrentSongChanged(Song song) {
    _currentSongController.add(song);
    PlayingStorage.instance.savePlayingIndex(_currentIndex);
  }

  // ===============播放模式================

  // 切换播放模式
  var _playMode = PlayMode.repeat;

  PlayMode get playMode => _playMode;

  var _playModeController = StreamController<PlayMode>.broadcast();

  Stream<PlayMode> get playModeStream => _playModeController.stream.map((item) {
        _playMode = item;
        return item;
      });

  /// 切换播放模式，当前播放的歌曲继续
  ///
  void switchPlayMode() {
    var song = currentSong;

    var nextIndex = (_playMode.index + 1) % PlayMode.values.length;
    var nextMode = PlayMode.values[nextIndex];
    _playModeController.add(nextMode);
    PlayingStorage.instance.savePlayMode(nextMode);

    final showingList = List.of(_showingList);
    var newPlayingList = _refreshPlayingList(showingList, playMode: nextMode);
    _currentIndex = newPlayingList.indexOf(song);
    _onPlayingListChanged(newPlayingList);
    _onCurrentIndexChanged(_currentIndex);
  }

  // =================播放进度================

  // 当前歌曲的时常及当前播放位置
  var _currentPosition = 0;

  int get currentPosition => _currentPosition;
  var _currentPositionController = StreamController<int>.broadcast();

  Stream<int> get currentPositionStream => _currentPositionController.stream.map((item) {
        _currentPosition = item;
        return item;
      });

  var _currentDuration = 0;

  int get currentDuration => _currentDuration;
  var _currentDurationController = StreamController<int>.broadcast();

  Stream<int> get currentDurationStream => _currentDurationController.stream.map((item) {
        _currentDuration = item;
        return item;
      });

  void seekTo(int seconds) {
    _audioPlayer.seek(Duration(seconds: seconds));
  }

  // ===============播放控制=================

  // 播放控制
  var _state = AudioPlayerState.STOPPED;

  AudioPlayerState get playerState => _state;
  var _playerStateController = StreamController<AudioPlayerState>.broadcast();

  Stream<AudioPlayerState> get playerStateStream => _playerStateController.stream;

  void _setPlayerState(AudioPlayerState state) {
    if (_state == state) {
      return;
    }
    _state = state;
    _playerStateController.add(state);
  }

  Future playOrPause() async {
    if (_state == AudioPlayerState.PLAYING) {
      return await pause();
    } else {
      return await play();
    }
  }

  // 播放
  Future play() async {
    if (_state == AudioPlayerState.PLAYING) {
      return;
    }

    int result;
    if (_state == AudioPlayerState.PAUSED) {
      result = await _audioPlayer.resume();
    } else {
      var song = currentSong;
      await _parseCurrentSongStreamUrl(song);
      result = await _audioPlayer.play(song.streamUrl);
    }
    if (result == 1) {
      _setPlayerState(AudioPlayerState.PLAYING);
    }
  }

  // 暂停
  Future pause() async {
    if (_state != AudioPlayerState.PLAYING) {
      return;
    }
    var result = await _audioPlayer.pause();
    if (result == 1) {
      _setPlayerState(AudioPlayerState.PAUSED);
    }
  }

  // 停止播放
  Future _stop() async {
    var result = await _audioPlayer.stop();
    if (result == 1) {
      await _audioPlayer.release();
      _setPlayerState(AudioPlayerState.STOPPED);
    }
  }

  // 播放上一首
  Future playPre() async {
    if (_playingList.isEmpty) return;
    for (var model in _songControllerModels) {
      model.scrollToPrev();
    }
  }

  // 播放下一首
  Future playNext() async {
    if (_playingList.isEmpty) return;
    for (var model in _songControllerModels) {
      model.scrollToNext();
    }
  }

  /// song models
  var _songControllerModels = <SongControllerModel>[];

  void registerSongControllerModel(SongControllerModel model) {
    _songControllerModels.add(model);
  }

  void unregisterSongControllerModel(SongControllerModel model) {
    _songControllerModels.remove(model);
  }


  void playSongWithoutAnimation(Song song, {SongControllerModel withoutModel}) async {
    var index = _playingList.indexOf(song);
    if(index == -1){
      print('\n playSongWithoutAnimation don\'t find song in the list: ${song.name}');
      return ;
    }
    playIndexWithoutAnimation(index, withoutModel: withoutModel);
  }

  // 播放已经在播放列表中的歌曲
  Future playIndexWithoutAnimation(int index, {SongControllerModel withoutModel, bool force = false}) async {
    if (index == null || index >= _playingList.length) return;
    if (currentIndex == index && !force) return;

    var song = _playingList[index];
    _currentIndex = index;
    _onCurrentSongChanged(song);

    for(var model in _songControllerModels){
      if(model != withoutModel){
        model.jumpTo(index);
      }
    }

    var parseResult = await _parseCurrentSongStreamUrl(song);
    if (!parseResult) return;

    var result = await _audioPlayer.play(song.streamUrl);
    if (result == 1) {
      _setPlayerState(AudioPlayerState.PLAYING);
    }
  }

  Future<bool> _parseCurrentSongStreamUrl(Song song) async {
    if (song == null) return false;
    var result = await MusicProvider(song.plt).parseTrack(song);
    return result != null && result && song.streamUrl != null && song.streamUrl.isNotEmpty;
  }

  // 其他的一些工具方法

  Song getSongFromList(List<Song> songs, int index) {
    return songs != null && index < songs.length ? songs[index] : null;
  }
}
