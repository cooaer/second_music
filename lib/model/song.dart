import 'package:second_music/model/album.dart';
import 'package:second_music/model/singer.dart';
import 'package:second_music/network/platform/music_provider.dart';
import 'package:second_music/storage/database/music/table.dart';

class Song extends Object {
  String plt; //netease,qq,xiami,kugou,kuwo
  String id; //歌曲ID
  String name;
  String cover;
  String streamUrl; //歌曲播放流地址
  String description; //描述

  //歌曲来源页面
  String get source => MusicProvider(plt).songSource(id);

  ///虾米音乐歌词地址
  String lyricUrl;

  ///歌手
  Singer _singer;
  Singer get singer => _singer ?? (singers != null && singers.isNotEmpty ? singers[0] : null);
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

  bool get isSingerAvailable => singer?.id != null && singer?.name != null;

  bool get isAlbumAvailable => album?.id != null && album?.name != null;

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
