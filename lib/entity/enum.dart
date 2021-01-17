class MusicPlatforms {
  static const LOCAL = 'local';
  static const NETEASE = 'netease';
  static const QQ = 'qq';
  static const XIAMI = 'xiami';
  static const KUWO = 'kuwo';
  static const KUGOU = 'kugou';
  static const BILIBILI = 'bilibili';

  static const platforms = [NETEASE, QQ, XIAMI];
}

enum MusicObjectType { song, playlist, album, singer}

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
