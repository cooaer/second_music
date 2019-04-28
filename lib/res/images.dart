import 'package:audioplayers/audioplayers.dart';
import 'package:second_music/model/enum.dart';

class AppImages {
  static const test_002 = 'assets/images/test_002.jpg';

  static String playModeIcon(PlayMode mode) {
    switch (mode) {
      case PlayMode.repeatOne:
        return 'repeat_one';
      case PlayMode.random:
        return 'shuffle';
      case PlayMode.repeat:
      default:
        return 'repeat';
    }
  }

  static String favorIcon(bool isFavor) {
    return isFavor ? 'favorite' : 'favorite_border';
  }

  static String playIcon(AudioPlayerState state) {
    switch (state) {
      case AudioPlayerState.PLAYING:
        return 'pause_circle_outline';
        break;
      case AudioPlayerState.STOPPED:
      case AudioPlayerState.PAUSED:
      case AudioPlayerState.COMPLETED:
        return 'play_circle_outline';
        break;
    }
    return null;
  }
}
