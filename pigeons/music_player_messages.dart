import 'package:pigeon/pigeon.dart';

class SongMessage {
  String plt; //netease,qq,xiami,kugou,kuwo
  String id; //歌曲ID
  String name;
  String cover;
  String streamUrl; //歌曲播放流地址
  String albumName;
  String singerName;
}

class SongsMessage {
  List<SongMessage> songs;
}

class PositionMessage {
  int position;
  int duration;
}

@HostApi()
abstract class MusicPlayerControllerApi {
  void syncPlaylist(SongsMessage message);

  void playSong(SongMessage message);

  void play();

  void pause();

  void stop();

  void seek(PositionMessage message);
}

class StateMessage {
  String state;
}

@FlutterApi()
abstract class MusicPlayerCallbackApi {
  void onPlayerStateChanged(StateMessage message);

  void onSongChanged(SongMessage message);

  void onPositionChanged(PositionMessage message);
}

class StreamUrlMessage {
  String streamUrl;
}

@FlutterApi()
abstract class MusicPlayerDelegateApi {
  StreamUrlMessage retrieveStreamUrl(SongMessage message);
}

//回调歌曲播放进度、歌曲总时长、当前播放的歌曲
//回调获取最新的歌曲播放地址

// 输出配置
// flutter pub run pigeon --input pigeons/music_messages.dart
void configurePigeon(PigeonOptions opts) {
  opts.dartOut = './lib/player/music_messages.dart';
  opts.objcHeaderOut = 'ios/Runner/MusicMessages.h';
  opts.objcSourceOut = 'ios/Runner/MusicMessages.m';
  opts.objcOptions.prefix = 'FLT';
  opts.javaOut =
      'android/app/src/main/java/app/dier/music/MusicMessages.java';
  opts.javaOptions.package = 'app.dier.music';
}
