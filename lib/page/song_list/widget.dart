import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:second_music/model/enum.dart';
import 'package:second_music/model/song.dart';
import 'package:second_music/model/song_list.dart';
import 'package:second_music/page/basic_types.dart';
import 'package:second_music/page/home/my_song_list/model.dart';
import 'package:second_music/page/model.dart';
import 'package:second_music/page/navigator.dart';
import 'package:second_music/page/play_control/page.dart';
import 'package:second_music/page/song_list/model.dart';
import 'package:second_music/res/res.dart';
import 'package:second_music/storage/database/music/dao.dart';
import 'package:second_music/widget/material_icon_round.dart';

void showSongMenu(BuildContext context, Song song, SongList songList, SongListModel songListModel) {
  showModalBottomSheet(
      context: context, builder: (context) => _SongMenu(song, songList, songListModel));
}

//下一首播放
//收藏到歌单
//歌手：
//专辑:
//删除（从歌单中删除）
class _SongMenu extends StatelessWidget {
  final Song song;
  final SongList songList;
  final SongListModel songListModel;

  _SongMenu(this.song, this.songList, this.songListModel);

  @override
  Widget build(BuildContext context) {
    final items = [
      ['playNext', 'play_circle_outline', stringsOf(context).playNext],
      ['addToSongList', 'library_add', stringsOf(context).collectToPlaylist]
    ];

    if (song.isSingerAvailable) {
      items.add(['singer', 'portrait', stringsOf(context).singerTitle(song.singer)]);
    }

    if (song.isAlbumAvailable) {
      items.add(['album', 'album', stringsOf(context).albumTitle(song.album)]);
    }

    if (songList?.plt == MusicPlatforms.LOCAL) {
      items.add(['deleteFromSongList', 'delete_outline', stringsOf(context).delete]);
    }

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + PlayController.BAR_HEIGHT),
        child: Column(children: _buildMenuItems(context, items)),
      ),
    );
  }

  List<Widget> _buildMenuItems(BuildContext context, List<List<String>> items) {
    var widgets = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      var item = items[i];
      if (i != 0) {
        widgets.add(_SongMenuDivider());
      }
      widgets.add(_SongMenuItem(
        item[0],
        item[1],
        item[2],
        (type) => _onTapMenuItem(context, type),
        key: Key(item[0]),
      ));
    }
    return widgets;
  }

  void _onTapMenuItem(BuildContext context, String type) {
    Navigator.of(context).pop();
    switch (type) {
      case 'playNext':
        _playNext();
        break;
      case 'addToSongList':
        _addToSongList(context);
        break;
      case 'singer':
        break;
      case 'album':
        _openAlbum(context);
        break;
      case 'deleteFromSongList':
        _deleteFromSongList();
        break;
    }
  }

  void _playNext() {
    PlayControlModel.instance.addToNext(song);
  }

  void _addToSongList(BuildContext context) async {
    var _songList = await selectSongList(context);
    var _mySongListDao = MySongListDao();
    await _mySongListDao.addSongToSongList(_songList.plt, _songList.id, _songList.type, song);
    _mySongListDao.close();
    notifyMySongListChanged();
  }

  void _deleteFromSongList() async {
    var _mySongListDao = MySongListDao();
    await _mySongListDao.deleteSongFromSongList(
        songList.plt, songList.id, songList.type, song.plt, song.id);
    _mySongListDao.close();
    songListModel.refresh();
    notifyMySongListChanged();
  }

  void _openAlbum(BuildContext context) {
    AppNavigator.instance.navigateTo(context, AppNavigator.song_list,
        params: {"plt": song.plt, "songListId": song.album.id, "songListType": SongListType.album});
  }
}

class _SongMenuItem extends StatelessWidget {
  final String type;
  final String logo;
  final String title;
  final ValueCallback<String> callback;

  _SongMenuItem(this.type, this.logo, this.title, this.callback, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () => callback(type),
      padding: EdgeInsets.zero,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18),
        alignment: Alignment.center,
        height: 50,
        child: Row(
          children: <Widget>[
            MdrIcon(
              logo,
              size: 28,
              color: AppColors.tint_outlined,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.text_title,
                fontWeight: FontWeight.normal,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _SongMenuDivider extends StatelessWidget {
  _SongMenuDivider({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 52),
      height: 1,
      color: AppColors.divider,
    );
  }
}

// 选择歌单
Future<SongList> selectSongList(BuildContext context) async {
  var mySongListDao = MySongListDao();
  var songLists = await mySongListDao.queryAllWithoutSongs(plt: MusicPlatforms.LOCAL);
  mySongListDao.close();
  return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Container(
              height: 50,
              padding: EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.centerLeft,
              child: Text(
                stringsOf(context).collectToPlaylist,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text_title,
                ),
              ),
            ),
            titlePadding: EdgeInsets.zero,
            content: SingleChildScrollView(
              child: ListBody(
                  children: List.generate(songLists.length, (index) {
                var songList = songLists[index];
                return _SelectSongListContentItem(songList, key: ValueKey(songList.id));
              })),
            ),
            contentPadding: EdgeInsets.zero,
          ));
}

class _SelectSongListContentItem extends StatelessWidget {
  final SongList songList;

  _SelectSongListContentItem(this.songList, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
        onPressed: () {
          Navigator.of(context).pop(songList);
        },
        padding: EdgeInsets.zero,
        child: Container(
          padding: EdgeInsets.fromLTRB(16, 5, 16, 5),
          height: 60,
          child: Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                child: songList?.cover == null || songList.cover.isEmpty
                    ? Container(
                        width: 50,
                        height: 50,
                        color: AppColors.cover_bg,
                      )
                    : CachedNetworkImage(
                        imageUrl: songList.cover,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        placeholder: (context, url) {
                          return Container(
                            width: 50,
                            height: 50,
                            color: AppColors.cover_bg,
                          );
                        },
                      ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      songList.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: AppColors.text_title, fontSize: 16, fontWeight: FontWeight.normal),
                    ),
                    Text(
                      stringsOf(context)
                          .songListCountAndCreator(this.songList.songTotal, this.songList.userName),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.text_light,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}


void showSongListDescriptionDialog(BuildContext context, String desc){
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.main_bg,
          title: Text(
            stringsOf(context).description,
            style: TextStyle(
              fontSize: 18,
              color: AppColors.text_title,
            ),
          ),
          titlePadding: EdgeInsets.fromLTRB(20, 10, 20, 0),
          content: SingleChildScrollView(
            child: Text(
              desc ?? stringsOf(context).nullText,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.text_title,
                fontWeight: FontWeight.normal,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 20),
        );
      });
}