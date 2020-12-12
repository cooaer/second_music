import 'package:second_music/player/music_player_messages.dart';

enum PlayerState {
  STOPPED,
  PLAYING,
  PAUSED,
  COMPLETED,
}

class MusicPlayerModel extends MusicPlayerCallbackApi {
  static MusicPlayerModel _instance;

  MusicPlayerModel getInstance() {
    if (_instance == null) {
      _instance = new MusicPlayerModel._();
    }
    return _instance;
  }

  var _musicPlayerApi = new MusicPlayerControllerApi();
  var _playlistApi = new PlaylistControllerApi();

  MusicPlayerModel._() {
    MusicPlayerCallbackApi.setup(this);
  }

  //=======  callback api  =======

  @override
  void onPlayerStateChanged(StateMessage arg) {
    switch (arg.state) {
      case "prepared":
        break;
      case "completed":

        break;
      case "seekCompleted":
        break;
      case "error":
        break;
    }
  }

  @override
  void onPositionChanged(PositionMessage arg) {}

  @override
  void onSongChanged(SongMessage arg) {}

  //=======  callback api  ======



}
