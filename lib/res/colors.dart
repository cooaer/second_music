import 'package:flutter/material.dart';
import 'package:second_music/entity/enum.dart';

class AppColors {
  static final primary = Colors.white;
  static final accent = Color(0xffff0000);
  static final divider = Color(0xffe6e6e6);
  static final mask = Color(0x33000000);
  static final transparent = Color(0x00ffffff);
  static final common_bg = Color(0xfff6f6f6);
  static final main_bg = Color(0xffffffff);
  static final cover_bg = Color(0xfff0f0f0);
  static final disabled = Color(0xffbbbbbb);
  static final grey_bg = Color(0xff7f7f7f);

  static final page_background = Color(0xfff6f6f6);

  static final text_dark = Color(0xff1d1d1d);
  static final text_title = Color(0xff444444);
  static final text_light = Color(0xff999999);
  static final text_accent = Color(0xffff0000);
  static final text_embed = Color(0xffffffff);
  static final text_embed_half_transparent = Color(0x7fffffff);

  static final tint_rounded = Color(0xff999999);
  static final tint_outlined = Color(0xff646464);

  static final search_bg = Colors.grey.shade200;

  static Color platform(MusicPlatform plt) {
    switch (plt) {
      case MusicPlatform.netease:
        return Color(0xffd22a0d);
      case MusicPlatform.qq:
        return Color(0xff59be7c);
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
