class SongListTable {
  static const TABLE_NAME = 'songlist';

  static const FAVOR_ID = '0709';

  static const ROW_ID = 'rowid';

  static const PLT = 'plt';
  static const PLT_ID = 'plt_id';
  static const TITLE = 'title';
  static const COVER = 'cover';
  static const DESCRIPTION = 'description';

  static const CREATOR_ID = 'creator_id';
  static const CREATOR_NAME = 'creator_name';
  static const CREATOR_AVATAR = 'creator_avatar';

  static const TYPE = 'type';

  static const CREATED_TIME = 'created_time';

  static const SONG_TOTAL = 'song_total';
}

///歌曲表
class SongTable {
  static const TABLE_NAME = 'song';

  static const ROW_ID = 'rowid';

  static const PLT = 'plt';
  static const PLT_ID = 'plt_id';
  static const NAME = 'name';
  static const COVER = 'cover';
  static const STREAM_URL = 'stream_url';
  static const DESCRIPTION = 'description';
  static const LYRIC_URL = 'lyric_url';

  ///用到的歌手相关的数据太少，不单独建一张表了，歌单同理
  static const SINGER_ID = 'singer_id';
  static const SINGER_NAME = 'singer_name';

  static const ALBUM_ID = 'album_id';
  static const ALBUM_NAME = 'album_name';

  static const PLAYED_TIME = 'played_time';

  static const TABLE_COLUMNS = [
    '$TABLE_NAME.$ROW_ID',
    '$TABLE_NAME.$PLT',
    '$TABLE_NAME.$PLT_ID',
    '$TABLE_NAME.$NAME',
    '$TABLE_NAME.$COVER',
    '$TABLE_NAME.$STREAM_URL',
    '$TABLE_NAME.$DESCRIPTION',
    '$TABLE_NAME.$LYRIC_URL',
    '$TABLE_NAME.$SINGER_ID',
    '$TABLE_NAME.$SINGER_NAME',
    '$TABLE_NAME.$ALBUM_ID',
    '$TABLE_NAME.$ALBUM_NAME',
    '$TABLE_NAME.$PLAYED_TIME',
  ];

  static get tableColumns => TABLE_COLUMNS.join(',');
}

///歌单歌曲关联表
class SongListJoinSongTable {
  static const TABLE_NAME = 'songlist_song';

  ///Playlist表的RowID
  static const SONG_LIST_ID = 'songlist_id';

  ///Song表的RowID
  static const SONG_ID = 'song_id';

  ///添加时间
  static const ADDED_TIME = 'added_time';
}

