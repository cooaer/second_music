import 'package:dart_extensions_methods/dart_extension_methods.dart';
import 'package:second_music/entity/album.dart';
import 'package:second_music/entity/enum.dart';
import 'package:second_music/entity/playlist.dart';
import 'package:second_music/entity/song.dart';
import 'package:second_music/repository/local/database/song/song.dart';
import 'package:second_music/repository/remote/platform/music_provider.dart';

enum SongListType {
  playlist,
  album,
}

class SongList {
  static const FAVOR_ID = 1;
  static const FAVOR_PLT_ID = "0709";

  //本地id, 自增主键
  int id = 0;

  String plt = "";

  //来源网站的歌单或者专辑的ID
  String pltId = "";

  String title = "";

  String cover = "";

  String description = "";

  int playCount = 0;

  int favorCount = 0;

  String userPlt = "";

  String userId = "";

  String userName = "";

  String userAvatar = "";

  SongListType type = SongListType.playlist;

  int _songTotal = 0;

  set songTotal(int total) => _songTotal = total;

  int get songTotal => _songTotal > 0 ? _songTotal : songs.length;

  List<Song> songs = [];

  ///创建时间，本地数据库中的字段
  DateTime? createdTime;

  SongList();

  SongList.fromPlaylist(Playlist playlist) {
    pltId = playlist.pltId;
    plt = playlist.plt.name;
    title = playlist.title;
    cover = playlist.cover;
    description = playlist.description;
    playCount = playlist.playCount;
    favorCount = playlist.favorCount;
    userPlt = playlist.creator?.plt.name ?? "";
    userId = playlist.creator?.pltId ?? "";
    userName = playlist.creator?.name ?? "";
    userAvatar = playlist.creator?.avatar ?? "";
    type = SongListType.playlist;
    songTotal = playlist.songTotal;
    songs = List.of(playlist.songs);
  }

  SongList.fromAlbum(Album album) {
    pltId = album.pltId;
    plt = album.plt.name;
    title = album.name;
    cover = album.cover;
    description = album.description;
    playCount = album.playCount;
    favorCount = album.favorCount;
    userPlt = album.singer?.pltId ?? "";
    userId = album.singer?.pltId ?? "";
    userName = album.singer?.name ?? "";
    userAvatar = album.singer?.avatar ?? "";
    type = SongListType.album;
    songTotal = album.songTotal;
    songs = List.of(album.songs);
  }

  SongList.fromDb({
    required this.id,
    required this.plt,
    required this.pltId,
    required this.title,
    required this.cover,
    required this.description,
    required this.playCount,
    required this.favorCount,
    required this.userPlt,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.type,
    required int songTotal,
    required this.createdTime,
  }) : this._songTotal = songTotal;

  SongListTableCompanion toInsertable() {
    return SongListTableCompanion.insert(
        plt: plt,
        pltId: pltId,
        title: title,
        cover: cover,
        description: description,
        playCount: playCount,
        favorCount: favorCount,
        userPlt: userPlt,
        userId: userId,
        userName: userName,
        userAvatar: userAvatar,
        type: type,
        songTotal: songTotal);
  }

//==========util start===========

  String get source {
    final musicPlatform = MusicPlatforms.fromString(plt);
    return musicPlatform == null
        ? "local"
        : MusicProvider(musicPlatform).songListSource(type, pltId);
  }

  String get userSource {
    final musicPlatform = MusicPlatforms.fromString(plt);
    return musicPlatform == null
        ? "local"
        : MusicProvider(musicPlatform).songListUserSource(type, userId);
  }

  bool get hasDisplayCover => displayCover.isNotEmpty;

  String get displayCover =>
      cover.isNotEmpty ? cover : (songs.firstOrNull?.cover ?? "");

  bool get isUserAvailable =>
      userId.isNotEmpty && userName.isNotEmpty && userAvatar.isNotEmpty;

  bool get isFavor => plt == MusicPlatforms.local && pltId == FAVOR_PLT_ID;

  @override
  String toString() {
    return 'SongList{id: $id, plt: $plt, pltId: $pltId, title: $title, cover: $cover, description: $description, playCount: $playCount, favorCount: $favorCount, userPlt: $userPlt, userId: $userId, userName: $userName, userAvatar: $userAvatar, type: $type, _songTotal: $_songTotal, songs: $songs, createdTime: $createdTime}';
  }

//==========util end===========

}
