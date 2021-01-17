import 'package:pigeon/pigeon.dart';

class InitializeMessage {
  int callbackHandle;
}

class SongMessage {
  Map<String, String> song;
}

class SongsMessage {
  List<Map<String, Object>> songs;
}

class PositionMessage {
  int position;
  int duration;
}

class PlayModeMessage {
  String playMode;
}

class StateMessage {
  String state;
}

@HostApi()
abstract class MusicPlayerControllerApi {
  //初始化音乐控制器
  void initialize(InitializeMessage message);

  void setPlayMode(PlayModeMessage message);

  void playSong(SongMessage message);

  void playSongList(SongsMessage message);

  void playPrev();

  void playNext();

  void play();

  void pause();

  void seekTo(PositionMessage message);

  //添加歌曲到播放列表下一个播放的位置
  void addSongToPlaylistNext(SongMessage message);

  //从播放列表中删除歌曲
  void deleteSongFromPlaylist(SongMessage message);

  //清空播放列表
  void clearPlaylist();
}

@FlutterApi()
abstract class MusicPlayerCallbackApi {
  void onShowingSongListChanged(SongsMessage message);

  void onPlayingSongListChanged(SongsMessage message);

  void onPlayerStateChanged(StateMessage message);

  void onPlayingSongChanged(SongMessage message);

  void onPositionChanged(PositionMessage message);
}

@FlutterApi()
abstract class StreamUrlServiceApi {
  //调用Dart实现的能力获取歌曲的地址
  void retrieveStreamUrl(SongMessage message);
}

@HostApi()
abstract class StreamUrlCallbackApi {
  //当获取歌曲地址后，通过该接口回调本地
  void setStreamUrl(SongMessage message);
}

//回调歌曲播放进度、歌曲总时长、当前播放的歌曲
//回调获取最新的歌曲播放地址

// 输出配置
// flutter pub run pigeon --input pigeons/music_player_messages.dart
void configurePigeon(PigeonOptions opts) {
  opts.dartOut = './lib/player/music_messages.dart';
  opts.objcHeaderOut = 'ios/Runner/MusicMessages.h';
  opts.objcSourceOut = 'ios/Runner/MusicMessages.m';
  opts.objcOptions.prefix = 'FLT';
  opts.javaOut = 'android/app/src/main/java/app/dier/music/MusicMessages.java';
  opts.javaOptions.package = 'app.dier.music';
}
