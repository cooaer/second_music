import 'package:dart_extensions_methods/dart_extension_methods.dart';
import 'package:second_music/common/json.dart';
import 'package:second_music/entity/album.dart';
import 'package:second_music/entity/enum.dart';
import 'package:second_music/entity/singer.dart';
import 'package:second_music/repository/local/database/song/song.dart';
import 'package:second_music/repository/remote/platform/music_provider.dart';

class Song {
  int id = 0; //本地id，自增主键
  MusicPlatform plt = MusicPlatform.netease;
  String pltId = ""; //来源网站的歌曲ID
  String name = "";
  String subtitle = ""; //子标题
  String cover = "";
  String soundUrl = ""; //歌曲播放流地址
  String description = ""; //描述
  bool isPlayable = true; //该歌曲在当前平台上非登录状态下是否可播放，不可播放的原因有：1：没有版权，2：需要付费
  String lyricUrl = "";

  ///歌手
  Singer? _singer;

  Singer? get singer => _singer ?? singers.firstOrNull;

  set singer(Singer? singer) => _singer = singer;

  List<Singer> singers = [];

  ///专辑
  Album? album;

  ///最近一次播放时间, 本地数据库字段
  DateTime? playedTime;

  //migu平台获取soundUrl时使用
  String quality = "";
  //migu平台获取songSource时使用
  String copyrightId = "";

  Song();

  Song.fromDb({
    required this.id,
    required String plt,
    required this.pltId,
    required this.name,
    required this.subtitle,
    required this.cover,
    required this.soundUrl,
    required this.description,
    required this.isPlayable,
    required String singerId,
    required String singerName,
    required String singerAvatar,
    required String albumId,
    required String albumName,
    required String albumCover,
    required this.playedTime,
  }) {
    final musicPlatform = MusicPlatforms.fromString(plt);
    if (musicPlatform == null) {
      throw ArgumentError("plt");
    }
    this.plt = musicPlatform;
    this._singer = Singer()
      ..plt = this.plt
      ..pltId = singerId
      ..name = singerName
      ..avatar = singerAvatar;
    this.album = Album()
      ..plt = this.plt
      ..pltId = albumId
      ..name = albumName
      ..cover = albumCover;
  }

  SongTableCompanion toInsertable() {
    return SongTableCompanion.insert(
        plt: plt.name,
        pltId: pltId,
        name: name,
        subtitle: subtitle,
        cover: cover,
        soundUrl: soundUrl,
        description: description,
        isPlayable: isPlayable,
        singerId: singer?.pltId ?? "",
        singerName: singer?.name ?? "",
        singerAvatar: singer?.avatar ?? "",
        albumId: album?.pltId ?? "",
        albumName: album?.name ?? "",
        albumCover: album?.cover ?? "");
  }

  Song.fromMap(Map<String, dynamic> map) {
    this.plt = map['plt'];
    this.pltId = map['id'];
    this.name = map['name'];
    this.subtitle = map['subtitle'];
    this.cover = map["cover"];
    this.soundUrl = map["soundUrl"];
    this.description = map["description"];

    this.album = new Album()
      ..plt = this.plt
      ..pltId = map.getString("albumId")
      ..name = map.getString("albumName")
      ..cover = map.getString("albumCover");

    this.singer = new Singer()
      ..plt = this.plt
      ..pltId = map.getString("singerId")
      ..name = map.getString("singerName")
      ..avatar = map.getString("singerAvatar");
  }

  Map<String, dynamic> toMap() {
    var map = {
      "plt": this.plt,
      "id": this.pltId,
      "name": this.name,
      "subtitle": this.subtitle,
      "cover": this.cover,
      "soundUrl": this.soundUrl,
      "description": this.description,
      "albumId": this.album?.pltId ?? "",
      "albumName": this.album?.name ?? "",
      "albumCover": this.album?.cover ?? "",
      "singerId": this.singer?.pltId ?? "",
      "singerName": this.singer?.name ?? "",
      "singerAvatar": this.singer?.avatar ?? "",
    };
    return map;
  }

  //======== utils start ========

  //歌曲来源页面
  String get source => MusicProvider(plt).songSource(pltId);

  bool get isSingerAvailable =>
      singer != null &&
      singer!.pltId.isNotNullOrEmpty() &&
      singer!.name.isNotNullOrEmpty();

  bool get isAlbumAvailable =>
      album != null && album!.pltId.isNotEmpty && album!.name.isNotEmpty;

  String get uniqueId => "${plt.name}#$pltId";

  //======== utils end ========

  @override
  bool operator ==(other) {
    return other is Song && plt == other.plt && pltId == other.pltId;
  }

  @override
  int get hashCode => plt.hashCode ^ pltId.hashCode;

  @override
  String toString() {
    return 'Song{id: $id, plt: $plt, pltId: $pltId, name: $name, subtitle: $subtitle, cover: $cover, soundUrl: $soundUrl, description: $description, singers: $singers, album: $album, playedTime: $playedTime}';
  }
}
