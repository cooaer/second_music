import 'package:second_music/repository/local/database/song/song.dart';

class SongListJoinSong {
  final int songListId;
  final int songId;
  final DateTime addedTime;

  SongListJoinSong.fromDb(this.songListId, this.songId, this.addedTime);

  SongListJoinSongTableCompanion toInsertable() {
    return SongListJoinSongTableCompanion.insert(
      songListId: songListId,
      songId: songId,
    );
  }
}

class PlayingSong {
  final int songId;
  final DateTime addedTime;

  PlayingSong(this.songId, this.addedTime);

  PlayingSong.fromDb(this.songId, this.addedTime);
}
