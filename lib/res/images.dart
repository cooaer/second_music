import 'package:second_music/entity/enum.dart';
import 'package:second_music/player/music_player.dart';

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

  static String playIcon(PlayerState state) {
    switch (state) {
      case PlayerState.PLAYING:
        return 'pause_circle_outline';
        break;
      case PlayerState.STOPPED:
      case PlayerState.PAUSED:
      case PlayerState.COMPLETED:
        return 'play_circle_outline';
        break;
    }
    return null;
  }
}
