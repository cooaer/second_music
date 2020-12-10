import 'package:second_music/entity/enum.dart';

class AppImages {
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

  static String playIcon(bool playing) {
    return playing ? 'pause_circle_outline' : 'play_circle_outline';
  }
}
