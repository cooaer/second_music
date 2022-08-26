import 'package:flutter/material.dart';
import 'package:second_music/entity/enum.dart';
import 'package:second_music/entity/song.dart';
import 'package:second_music/page/home/my_song_list/logic.dart' as mySongList;
import 'package:second_music/page/song_list/widget.dart';
import 'package:second_music/repository/local/database/song/dao.dart';
import 'package:second_music/res/res.dart';
import 'package:second_music/service/music_service.dart';

void showPlayingList(BuildContext context) {
  showModalBottomSheet(context: context, builder: (context) => _PlayingList());
}

class _PlayingList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 400,
        color: Colors.white,
        child: Column(
          children: <Widget>[
            _PlayingListTitle(),
            Divider(
              indent: 0,
              height: 0.5,
              color: AppColors.divider,
            ),
            Expanded(
              flex: 1,
              child: _buildSongList(context),
            ),
            Divider(
              indent: 0,
              height: 0.5,
              color: AppColors.divider,
            ),
            _PlayingListBottom(),
          ],
        ),
      ),
    );
  }

  Widget _buildSongList(BuildContext context) {
    return StreamBuilder(
      initialData: MusicService().showingSongList,
      stream: MusicService().showingSongListStream,
      builder: (context, AsyncSnapshot<List<Song>> snapshotShowingList) {
        return StreamBuilder(
            initialData: MusicService().currentIndex,
            stream: MusicService().currentIndexStream,
            builder: (context, AsyncSnapshot<int> snapshotCurrentSong) {
              return ListView.separated(
                  itemBuilder: (context, index) {
                    var song = snapshotShowingList.data![index];
                    var isPlaying = snapshotCurrentSong.data == index;
                    return _PlayingListSong(index, song, isPlaying,
                        key: Key(song.uniqueId));
                  },
                  separatorBuilder: (context, index) => _PlayingListDivider(),
                  itemCount: snapshotShowingList.data!.length);
            });
      },
    );
  }
}

class _PlayingListTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: Row(
        children: <Widget>[
          StreamBuilder(
            initialData: MusicService().playMode,
            stream: MusicService().playModeStream,
            builder: (context, AsyncSnapshot<PlayMode> snapshot) {
              return TextButton.icon(
                  onPressed: () {
                    MusicService().switchPlayMode();
                  },
                  icon: Icon(
                    AppImages.playModeIcon(snapshot.data!),
                    color: AppColors.tintRounded,
                  ),
                  label: Text(
                    stringsOf(context).playMode(snapshot.data!),
                    style: TextStyle(
                      color: AppColors.textTitle,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ));
            },
          ),
          Spacer(),
          TextButton.icon(
            onPressed: () {
              _addAllToSongList(context);
            },
            icon: Icon(
              Icons.create_new_folder_rounded,
              color: AppColors.tintRounded,
            ),
            label: Text(
              stringsOf(context).saveAll,
              style: TextStyle(
                color: AppColors.textTitle,
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(minimumSize: Size.square(40)),
            onPressed: MusicService().clearPlaylistWithoutCurrentSong,
            child: Icon(
              Icons.delete_outline_rounded,
              color: AppColors.tintRounded,
            ),
          ),
        ],
      ),
    );
  }

  void _addAllToSongList(BuildContext context) async {
    var songDao = SongDao();
    var songLists =
        await songDao.queryAllSongListWithoutSongs(plt: MusicPlatforms.local);
    var songList = await selectSongList(context, songLists);
    if (songList == null) {
      return;
    }
    var songs = MusicService().showingSongList;
    await songDao.addSongsToSongList(songList.id, songs);
    mySongList.notifyMySongListChanged();
  }
}

class _PlayingListSong extends StatelessWidget {
  final int index;
  final Song song;
  final bool isPlaying;

  _PlayingListSong(this.index, this.song, this.isPlaying, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Ink(
        height: 45,
        color: Colors.white,
        child: InkWell(
          onTap: () {
            Navigator.of(context).pop();
            MusicService().playSong(song);
          },
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 16,
              ),
              if (isPlaying)
                Padding(
                  padding: EdgeInsets.only(right: 5),
                  child: Icon(
                    Icons.volume_up_rounded,
                    color: AppColors.accent,
                  ),
                ),
              Expanded(
                flex: 1,
                child: Text.rich(
                  TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: song.name,
                        style: TextStyle(
                            color: isPlaying
                                ? AppColors.textAccent
                                : AppColors.textTitle,
                            fontSize: 16,
                            fontWeight: FontWeight.normal),
                      ),
                      TextSpan(
                        text: song.singer?.name != null &&
                                song.singer!.name.isNotEmpty
                            ? ' - ${song.singer!.name}'
                            : '',
                        style: TextStyle(
                            color: isPlaying
                                ? AppColors.textAccent
                                : AppColors.textLight,
                            fontSize: 12,
                            fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!isPlaying)
                TextButton(
                  onPressed: () => MusicService().deleteSongFromPlaylist(song),
                  child: Icon(
                    Icons.close_rounded,
                    color: AppColors.tintRounded,
                  ),
                ),
              SizedBox(
                width: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayingListDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.5,
      margin: EdgeInsets.only(left: 16),
      color: AppColors.divider,
    );
  }
}

class _PlayingListBottom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text(
          stringsOf(context).close,
          style: TextStyle(
            color: AppColors.textTitle,
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
