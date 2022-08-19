import 'package:flutter/material.dart';
import 'package:second_music/entity/enum.dart';

class AppColors {
  AppColors._();

  static final primary = Colors.white;
  static final accent = Color(0xffff0000);
  static final divider = Color(0xffe6e6e6);
  static final mask = Color(0x33000000);
  static final transparent = Color(0x00ffffff);
  static final commonBg = Color(0xfff6f6f6);
  static final mainBg = Color(0xffffffff);
  static final coverBg = Color(0xfff0f0f0);
  static final disabled = Color(0xffbbbbbb);
  static final greyBg = Color(0xff7f7f7f);

  static final pageBackground = Color(0xfff6f6f6);

  static final textDark = Color(0xff1d1d1d);
  static final textTitle = Color(0xff444444);
  static final textLight = Color(0xff999999);
  static final textAccent = Color(0xffff0000);
  static final textEmbed = Color(0xffffffff);
  static final textEmbedHalfTransparent = Color(0x7fffffff);
  static final textDisabled = Color(0xffc0c0c0);

  static final tintRounded = Color(0xff999999);
  static final tintOutlined = Color(0xff646464);

  static final searchBg = Colors.grey.shade200;

  static Color platform(MusicPlatform plt) {
    switch (plt) {
      case MusicPlatform.netease:
        return Color(0xffd22a0d);
      case MusicPlatform.qq:
        return Color(0xff59be7c);
      case MusicPlatform.migu:
        return Color(0xfff7206c);
      // case MusicPlatform.kuwo:
      //   return Color(0xfffdb340);
      // case MusicPlatform.kugou:
      //   return Color(0xff3f80f6);
      // case MusicPlatform.bilibili:
      //   return Color(0xffde819d);
      // default:
      //   return accent;
    }
  }
}
