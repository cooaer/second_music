import 'package:dart_extensions_methods/dart_extension_methods.dart';

//local, kuwo, kugou, bilibili }
enum MusicPlatform { netease, qq }

class MusicPlatforms {
  MusicPlatforms._();

  static const local = "local";

  static MusicPlatform? fromString(String plt) {
    return MusicPlatform.values
        .firstWhereOrNull((element) => element.name == plt);
  }
}

enum MusicObjectType { song, playlist, album, singer }

enum UserGender {
  unknown,
  male,
  female,
}

enum PlayMode {
  ///列表循环
  repeat,

  ///单曲循环
  repeatOne,

  ///随机播放
  random,
}
