import 'package:second_music/entity/album.dart';
import 'package:second_music/entity/singer.dart';
import 'package:second_music/player/music_messages.dart';
import 'package:second_music/repository/remote/platform/music_provider.dart';
import 'package:second_music/repository/local/database/music/table.dart';

class Song extends Object {
  String plt; //netease,qq,xiami,kugou,kuwo
  String id; //歌曲ID
  String name;
  String subtitle; //子标题
  String cover;
  String streamUrl; //歌曲播放流地址
  String description; //描述

  //歌曲来源页面
  String get source => MusicProvider(plt).songSource(id);

  ///虾米音乐歌词地址
  String lyricUrl;

  ///歌手
  Singer _singer;

  Singer get singer =>
      _singer ?? (singers != null && singers.isNotEmpty ? singers[0] : null);

  set singer(Singer singer) => _singer = singer;

  List<Singer> singers;

  ///专辑
  Album album;

  Song();

  Song.fromDb(Map<String, dynamic> map) {
    this.plt = map[SongTable.PLT];
    this.id = map[SongTable.PLT_ID];
    this.name = map[SongTable.NAME];
    this.cover = map[SongTable.COVER];
    this.streamUrl = map[SongTable.STREAM_URL];
    this.description = map[SongTable.DESCRIPTION];
    this.lyricUrl = map[SongTable.LYRIC_URL];

    Singer singer = Singer();
    singer.plt = this.plt;
    singer.id = map[SongTable.SINGER_ID];
    singer.name = map[SongTable.SINGER_NAME];
    this.singer = singer;

    Album album = Album();
    album.plt = this.plt;
    album.id = map[SongTable.ALBUM_ID];
    album.name = map[SongTable.ALBUM_NAME];
    this.album = album;
  }

  Map<String, dynamic> toDb() {
    var values = <String, dynamic>{};
    values[SongTable.PLT] = this.plt;
    values[SongTable.PLT_ID] = this.id;
    values[SongTable.NAME] = this.name;
    values[SongTable.COVER] = this.cover;
    values[SongTable.STREAM_URL] = this.streamUrl;
    values[SongTable.DESCRIPTION] = this.description;
    values[SongTable.LYRIC_URL] = this.lyricUrl;

    values[SongTable.SINGER_ID] = this.singer?.id;
    values[SongTable.SINGER_NAME] = this.singer?.name;

    values[SongTable.ALBUM_ID] = this.album?.id;
    values[SongTable.ALBUM_NAME] = this.album?.name;

    return values;
  }

  Song.fromPreference(Map<String, dynamic> map) : this.fromDb(map);

  Map<String, dynamic> toPreference() {
    return toDb();
  }

  Song.fromMessage(SongMessage message) : this.fromMap(message.song);

  SongMessage toMessage() => new SongMessage()..song = toMap();

  Song.fromMap(Map map) {
    if (map == null) {
      return;
    }
    this.plt = map['plt'];
    this.id = map['id'];
    this.name = map['name'];
    this.cover = map["cover"];
    this.streamUrl = map["streamUrl"];

    this.album = new Album();
    this.album.name = map["albumName"];

    this.singer = new Singer();
    this.singer.name = map["singerName"];
  }

  Map<String, dynamic> toMap() {
    var map = {
      "plt": this.plt,
      "id": this.id,
      "name": this.name,
      "cover": this.cover,
      "streamUrl": this.streamUrl ?? "",
      "albumName": this.album?.name ?? "",
      "singerName": this.singer?.name ?? "",
    };
    return map;
  }

  bool get isSingerAvailable => singer?.id != null && singer?.name != null;

  bool get isAlbumAvailable => album?.id != null && album?.name != null;

  String get uniqueId => this.plt + this.id;

  @override
  bool operator ==(other) {
    return other != null && other is Song && plt == other.plt && id == other.id;
  }

  @override
  int get hashCode => plt.hashCode ^ id.hashCode;
}

class DbSong extends Song {
  int rowId;

  String playedTime;

  DbSong.fromDb(Map<String, dynamic> map) : super.fromDb(map) {
    this.rowId = map[SongTable.ROW_ID];
    this.playedTime = map[SongTable.PLAYED_TIME];
  }
}
