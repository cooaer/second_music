import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:second_music/entity/album.dart';
import 'package:second_music/entity/enum.dart';
import 'package:second_music/entity/singer.dart';
import 'package:second_music/entity/song_list.dart';

AppLocalizations stringsOf(BuildContext context) {
  return AppLocalizations.of(context);
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations());
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}

class AppLocalizations {
  static AppLocalizations of(BuildContext context) {
    return Localizations.of(context, AppLocalizations);
  }

  String get appName => '第二音乐';

  String get appNameForShort => '氘';

  //音乐平台

  List<String> get platformNames => [netease, qq, kugou, kuwo, bilibili];

  String get neteaseMusic => '网易云音乐';

  String get qqMusic => 'QQ音乐';

  String get kugouMusic => '酷狗音乐';

  String get kuwoMusic => '酷我音乐';

  String get bilibiliMusic => '哔哩哔哩音乐';

  String get netease => '网易';

  String get qq => 'QQ';

  String get kugou => '酷狗';

  String get kuwo => '酷我';

  String get bilibili => '哔哩';

  String get local => "本地";

  String platform(MusicPlatform plt) {
    switch (plt) {
      case MusicPlatform.netease:
        return netease;
      case MusicPlatform.qq:
        return qq;
      // case MusicPlatform.kugou:
      //   return kugou;
      // case MusicPlatform.kuwo:
      //   return kuwo;
      // case MusicPlatform.bilibili:
      //   return bilibili;
      // case MusicPlatform.local:
      //   return local;
    }
  }

  String platformFullName(MusicPlatform plt) {
    switch (plt) {
      case MusicPlatform.netease:
        return neteaseMusic;
      case MusicPlatform.qq:
        return qqMusic;
      // case MusicPlatform.kugou:
      //   return kugou;
      // case MusicPlatform.kuwo:
      //   return kuwo;
      // case MusicPlatform.bilibili:
      //   return bilibili;
      // case MusicPlatform.local:
      //   return local;
    }
  }

  //common

  String get ok => '确定';

  String get cancel => '取消';

  String get loading => '加载中...';

  String get loadErrorAndRetry => '加载失败，请重试...';

  String get more => '更多';

  //tabs

  List<String> get mainTabTitles => [mine, hot];

  String get mine => '我的';

  String get hot => '推荐';

  String get playlist => '歌单';

  String get chart => '榜单';

  String get mainSearchHint => '全平台搜索';

  String get searchHint => '单曲、歌单、歌手、专辑';

  String get localMusic => '本地音乐';

  String get recentlyPlayed => '最近播放';

  String get createdPlaylist => '创建的歌单';

  String get collectedPlaylist => '收藏的歌单';

  String get collectedAlbum => '收藏的专辑';

  String playlistCount(int count) => '$count首';

  String songListCountAndCreator(int count, String creator) {
    if (creator.isNotEmpty) {
      return '$count首 by $creator';
    } else {
      return '$count首';
    }
  }

  //推荐
  String displayPlayCount(int playCount) {
    return _displayCount(playCount);
  }

  String _displayCount(int playCount) {
    if (playCount < 10000) {
      return playCount.toString();
    } else {
      return '${(playCount / 10000).floor()}万';
    }
  }

  // search tabs

  String get singer => '歌手';

  String get album => '专辑';

  String get singleMusic => '单曲';

  List<String> get searchTabTitles => [singleMusic, playlist, singer, album];

  // playlist menu

  String get nextPlay => '下一首播放';

  String get saveToPlaylist => '收藏到歌单';

  String aSinger(String name) => '歌手：$name';

  String anAlbum(String name) => '专辑：$name';

  String get delete => '删除';

  String get source => '来源';

  String sourceWithPlatform(MusicPlatform plt) =>
      source + "：" + platformFullName(plt);

  // search
  String get searchHistory => '搜索历史';

  //play control
  String get playModeRepeatOne => '单曲循环';

  String get playModeRepeat => '列表循环';

  String get playModeRandom => '随机播放';

  String playMode(PlayMode mode) {
    switch (mode) {
      case PlayMode.repeatOne:
        return playModeRepeatOne;
      case PlayMode.random:
        return playModeRandom;
      case PlayMode.repeat:
      default:
        return playModeRepeat;
    }
  }

  String get saveAll => '收藏全部';

  String get close => '关闭';

  String get defaultPlayControlTitle => '聆听全平台免费音乐';

  String get defaultPlayControlDescription => '第二音乐';

  //song list
  String songListTitle(SongListType songListType) {
    switch (songListType) {
      case SongListType.playlist:
        return playlist;
      case SongListType.album:
        return album;
    }
  }

  String playCount(int count) => 'play_arrow${displayPlayCount(count)}';

  String get playAll => '播放全部';

  String singerAndAlbum(String? singerName, String? albumName) {
    if (singerName != null &&
        singerName.isNotEmpty &&
        albumName != null &&
        albumName.isNotEmpty) {
      return '$singerName - $albumName';
    } else if (albumName != null && albumName.isNotEmpty) {
      return albumName;
    } else if (singerName != null && singerName.isNotEmpty) {
      return singerName;
    }
    return '';
  }

  String playAllCount(int count) => '(共$count首)';

  String collectAll(bool collected, int count) {
    if (collected) {
      return '已收藏(${_displayCount(count)})';
    } else {
      return '+收藏(${_displayCount(count)})';
    }
  }

  String get description => '简介';

  String get nullText => '无';

  // 歌曲菜单
  String get playNext => '下一首播放';

  String get collectToPlaylist => '收藏到歌单';

  String singerTitle(Singer? singer) {
    if (singer?.name != null && singer!.name.isNotEmpty) {
      return '歌手：${singer.name}';
    }
    return '歌手';
  }

  String albumTitle(Album? album) {
    if (album?.name != null && album!.name.isNotEmpty) {
      return '专辑：${album.name}';
    }
    return '专辑';
  }

  String get deleteFromPlaylist => '删除';

  // 播放

  String playPosition(int millSeconds) {
    var seconds = (millSeconds / 1000).round();
    var minute = (seconds / 60).floor();
    var second = seconds % 60;
    return minute.toString().padLeft(2, '0') +
        ':' +
        second.toString().padLeft(2, '0');
  }

  // 创建歌单
  String get createPlaylist => '新建歌单';

  String get pleaseInputPlaylistTitle => '请输入歌单标题';

  String playlistWithTitle(String title) => '歌单：$title';

  // 设置
  String get setting => '设置';

  String get backupPlaylist => '备份歌单';

  String get recoverPlaylist => '恢复恢复歌单';

  // 通知渠道名称
  String get notificationChannelAudio => "播放控制";

  //错误提示

  String get playFailBecauseOfCopyright => "版权原因无法播放，请尝试其他平台";
  String get developing => "开发中...";
}
