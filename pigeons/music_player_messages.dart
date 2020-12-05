import 'package:pigeon/pigeon.dart';

class SongMessage{
  String plt; //netease,qq,xiami,kugou,kuwo
  String id; //歌曲ID
  String name;
  String subtitle;//子标题
  String cover;
  String streamUrl; //歌曲播放流地址
  String description; //描述

  String albumId;
  String albumName;
  String albumCover;

  String singerId;
  String singerName;
  String singerAvatar;
}

class SongsMessage{
  List<SongMessage> songs;
}

class PositionMessage{
  int position;
}

class DurationMessage{
  int duration;
}

class PlayModeMessage{
  int playMode;
}

@HostApi()
abstract class MusicPlayerControllerApi{

  void addToPlaylist(SongsMessage message);

  void removeFromPlaylist(SongsMessage message);

  void replacePlaylist(SongsMessage message);

  void setPlayMode(PlayModeMessage message);

  void play(SongMessage message);

  void pause();

  void resume();

  void stop();

  void seek(PositionMessage message);

}

class StateMessage{
  int state;
}

class StreamUrlMessage{
  String streamUrl;
}

@FlutterApi()
abstract class MusicPlayerCallbackApi{

  StreamUrlMessage streamUrl(SongMessage message);

  void onPlayerStateChange(StateMessage message);

  void onSongChanged(SongMessage message);

  void onPositionChanged(PositionMessage message);

  void onDurationChanged(DurationMessage message);

}

//回调歌曲播放进度、歌曲总时长、当前播放的歌曲
//回调获取最新的歌曲播放地址

// 输出配置
void configurePigeon(PigeonOptions opts) {
  opts.dartOut = './lib/player/music_player_messages.dart';
  opts.objcHeaderOut = 'ios/Runner/MusicPlayerMessages.h';
  opts.objcSourceOut = 'ios/Runner/MusicPlayerMessages.m';
  opts.objcOptions.prefix = 'FLT';
  opts.javaOut =
  'android/app/src/main/java/app/dier/music/MusicPlayerMessages.java';
  opts.javaOptions.package = 'app.dier.music';
}