import 'package:second_music/entity/song.dart';
import 'package:second_music/entity/song_list.dart';
import 'package:second_music/repository/local/database/song/song.dart';

class SongDatabaseProvider {
  static SongDatabaseProvider? _instance;

  static SongDatabaseProvider get instance {
    if (_instance == null) {
      _instance = SongDatabaseProvider._();
    }
    return _instance!;
  }

  SongDatabase _songDatabase;

  SongDatabase get db => _songDatabase;

  SongDatabaseProvider._() : this._songDatabase = SongDatabase();
}

extension SongWithDatabase on Song {}

extension SongListWithDataBase on SongList {
  static SongList? fromDb(Map<String, dynamic> map) {
    return null;
  }
}
