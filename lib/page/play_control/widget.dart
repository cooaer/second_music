import 'package:flutter/material.dart';
import 'package:second_music/model/enum.dart';
import 'package:second_music/model/song.dart';
import 'package:second_music/page/model.dart';
import 'package:second_music/res/res.dart';
import 'package:second_music/storage/database/music/dao.dart';
import 'package:second_music/widget/material_icon_round.dart';
import 'package:second_music/page/song_list/widget.dart';
import 'package:second_music/page/home/my_song_list/model.dart' as mySongList;

void showPlayingList(BuildContext context) {
  showModalBottomSheet(context: context, builder: (context) => _PlayingList());
}

class _PlayingList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }

  Widget _buildSongList(BuildContext context) {
    return StreamBuilder(
      initialData: PlayControlModel.instance.showingList,
      stream: PlayControlModel.instance.showingListStream,
      builder: (context, AsyncSnapshot<List<Song>> snapshotShowingList) {
        return StreamBuilder(
            initialData: PlayControlModel.instance.currentSong,
            stream: PlayControlModel.instance.currentSongStream,
            builder: (context, AsyncSnapshot<Song> snapshotCurrentSong) {
              return ListView.separated(
                  itemBuilder: (context, index) {
                    var song = snapshotShowingList.data[index];
                    var isPlaying = snapshotCurrentSong.data == snapshotShowingList.data[index];
                    return _PlayingListSong(song, isPlaying, key: Key(song.plt + song.id));
                  },
                  separatorBuilder: (context, index) => _PlayingListDivider(),
                  itemCount: snapshotShowingList.data.length);
            });
      },
    );
  }
}

class _PlayingListTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
        height: 50,
        minWidth: 0,
        child: Container(
          height: 50,
          child: Row(
            children: <Widget>[
              StreamBuilder(
                initialData: PlayControlModel.instance.playMode,
                stream: PlayControlModel.instance.playModeStream,
                builder: (context, AsyncSnapshot<PlayMode> snapshot) {
                  return FlatButton.icon(
                      onPressed: () {
                        PlayControlModel.instance.switchPlayMode();
                      },
                      icon: MdrIcon(
                        AppImages.playModeIcon(snapshot.data),
                        color: AppColors.tint_rounded,
                      ),
                      label: Text(
                        stringsOf(context).playMode(snapshot.data),
                        style: TextStyle(
                          color: AppColors.text_title,
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ));
                },
              ),
              Spacer(),
              FlatButton.icon(
                  onPressed: () {
                    _addAllToSongList(context);
                  },
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  icon: MdrIcon(
                    'create_new_folder',
                    color: AppColors.tint_rounded,
                  ),
                  label: Text(
                    stringsOf(context).saveAll,
                    style: TextStyle(
                      color: AppColors.text_title,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  )),
              FlatButton(
                onPressed: PlayControlModel.instance.clear,
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: MdrIcon(
                  "delete_outline",
                  color: AppColors.tint_rounded,
                ),
              )
            ],
          ),
        ));
  }

  void _addAllToSongList(BuildContext context) async {
    var songList = await selectSongList(context);
    var mySongListDao = MySongListDao();
    var songs = PlayControlModel.instance.showingList;
    await mySongListDao.addSongsToSongList(songList.plt, songList.id, songList.type, songs);
    mySongListDao.close();
    mySongList.notifyMySongListChanged();
  }
}

class _PlayingListSong extends StatelessWidget {
  final Song song;
  final bool isPlaying;

  _PlayingListSong(this.song, this.isPlaying, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 45,
        child: ButtonTheme(
          minWidth: 0,
          height: 45,
          child: FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
                var index = PlayControlModel.instance.playingList.indexOf(song);
                PlayControlModel.instance.playIndexWithoutAnimation(index);
              },
              padding: EdgeInsets.zero,
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 16,
                  ),
                  if (isPlaying)
                    Padding(
                      padding: EdgeInsets.only(right: 5),
                      child: MdrIcon(
                        'volume_up',
                        color: AppColors.accent,
                      ),
                    ),
                  Expanded(
                    flex: 1,
                    child: Text.rich(
                      TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: song.name ?? '',
                            style: TextStyle(
                                color: isPlaying ? AppColors.text_accent : AppColors.text_title,
                                fontSize: 16,
                                fontWeight: FontWeight.normal),
                          ),
                          TextSpan(
                            text: song.singer?.name != null && song.singer.name.isNotEmpty
                                ? ' - ${song.singer.name}'
                                : '',
                            style: TextStyle(
                                color: isPlaying ? AppColors.text_accent : AppColors.text_light,
                                fontSize: 12,
                                fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  FlatButton(
                    onPressed: () => PlayControlModel.instance.deleteSongFromList(song),
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: MdrIcon(
                      "close",
                      color: AppColors.tint_rounded,
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                ],
              )),
        ));
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
      width: double.infinity,
      child: ButtonTheme(
          layoutBehavior: ButtonBarLayoutBehavior.padded,
          minWidth: 0,
          height: 50,
          child: FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              padding: EdgeInsets.zero,
              child: Text(
                stringsOf(context).close,
                style: TextStyle(
                  color: AppColors.text_title,
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ))),
    );
  }
}
