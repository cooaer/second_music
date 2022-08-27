import 'package:flutter/material.dart';
import 'package:second_music/entity/enum.dart';

class AppImages {
  static const appIcon = 'assets/images/icon.png';

  static IconData playModeIcon(PlayMode mode) {
    switch (mode) {
      case PlayMode.repeatOne:
        return Icons.repeat_one_rounded;
      case PlayMode.random:
        return Icons.shuffle_rounded;
      case PlayMode.repeat:
      default:
        return Icons.repeat_rounded;
    }
  }

  static IconData favorIcon(bool isFavor) {
    return isFavor ? Icons.favorite_rounded : Icons.favorite_border_rounded;
  }
}
