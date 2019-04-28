import 'package:second_music/model/album.dart';
import 'package:second_music/model/enum.dart';
import 'package:second_music/model/playlist.dart';
import 'package:second_music/model/song.dart';
import 'package:second_music/network/platform/music_provider.dart';
import 'package:second_music/storage/database/music/table.dart';

enum SongListType {
  playlist,
  album,
}

class SongList {
  String id;

  String plt;

  String title;

  String cover;

  String description;

  int playCount;

  int favorCount;

  String get source => MusicProvider(plt).songListSource(type, id);

  String userId;

  String userName;

  String userAvatar;

  String get userSource => MusicProvider(plt).songListUserSource(type, userId);

  SongListType type;

  int _songTotal;
  set songTotal(int total) => _songTotal = total;
  int get songTotal => _songTotal ?? songs?.length;

  List<Song> songs;

  bool get hasDisplayCover {
    var _cover = displayCover;
    return _cover != null && _cover.isNotEmpty;
  }

  String get displayCover {
    return cover != null && cover.isNotEmpty
        ? cover
        : (songs != null && songs.isNotEmpty ? songs.first.cover : null);
  }

  bool get isUserAvailable => userId != null && userName != null && userAvatar != null;

  bool get isFavor => plt == MusicPlatforms.LOCAL && id == SongListTable.FAVOR_ID;

  SongList();

  SongList.fromPlaylist(Playlist playlist) {
    id = playlist.id;
    plt = playlist.plt;
    title = playlist.title;
    cover = playlist.cover;
    description = playlist.description;
    playCount = playlist.playCount;
    favorCount = playlist.favorCount;
    userId = playlist.creator?.id;
    userName = playlist.creator?.name;
    userAvatar = playlist.creator?.avatar;
    type = SongListType.playlist;
    songTotal = playlist.songTotal;
    songs = playlist.songs?.toList();
  }

  SongList.fromAlbum(Album album) {
    id = album.id;
    plt = album.plt;
    title = album.name;
    cover = album.cover;
    description = album.description;
    playCount = album.playCount;
    favorCount = album.favorCount;
    userId = album.singer?.id;
    userName = album.singer?.name;
    userAvatar = album.singer?.avatar;
    type = SongListType.album;
    songTotal = album.songTotal;
    songs = album.songs?.toList();
  }

  Map<String, dynamic> toDb() {
    var values = <String, dynamic>{};
    values[SongListTable.PLT] = this.plt;
    values[SongListTable.PLT_ID] = this.id;
    values[SongListTable.TITLE] = this.title;
    values[SongListTable.COVER] = this.cover;
    values[SongListTable.DESCRIPTION] = this.description;
    values[SongListTable.TYPE] = this.type.index;
    values[SongListTable.CREATOR_ID] = this.userId;
    values[SongListTable.CREATOR_NAME] = this.userName;
    values[SongListTable.CREATOR_AVATAR] = this.userAvatar;
    return values;
  }
}

class DbSongList extends SongList {
  int rowId;
  String createdTime;

  DbSongList();

  DbSongList.fromDb(Map<String, dynamic> data) {
    id = data[SongListTable.PLT_ID];
    plt = data[SongListTable.PLT];
    title = data[SongListTable.TITLE];
    cover = data[SongListTable.COVER];
    description = data[SongListTable.DESCRIPTION];
    userId = data[SongListTable.CREATOR_ID];
    userName = data[SongListTable.CREATOR_NAME];
    userAvatar = data[SongListTable.CREATOR_AVATAR];
    type = SongListType.values[data[SongListTable.TYPE]];

    rowId = data[SongListTable.ROW_ID];
    createdTime = data[SongListTable.CREATED_TIME];

    songTotal = data[SongListTable.SONG_TOTAL];
  }

  Map<String, dynamic> toDb() {
    var values = super.toDb();
    values[SongListTable.CREATED_TIME] = this.createdTime;
    return values;
  }
}
