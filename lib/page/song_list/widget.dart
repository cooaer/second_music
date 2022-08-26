import 'package:flutter/material.dart';
import 'package:second_music/entity/enum.dart';
import 'package:second_music/entity/song.dart';
import 'package:second_music/entity/song_list.dart';
import 'package:second_music/page/basic_types.dart';
import 'package:second_music/page/home/my_song_list/logic.dart';
import 'package:second_music/page/home/my_song_list/page.dart';
import 'package:second_music/page/navigator.dart';
import 'package:second_music/page/song_list/logic.dart';
import 'package:second_music/repository/local/database/song/dao.dart';
import 'package:second_music/res/res.dart';

void showSongMenu(BuildContext context, Song song, SongList? songList,
    SongListLogic? songListLogic) {
  showModalBottomSheet(
    context: context,
    builder: (context) =>
        SafeArea(child: _SongMenu(song, songList, songListLogic)),
  );
}

//下一首播放
//收藏到歌单
//歌手：
//专辑:
//删除（从歌单中删除）
//来源
class _SongMenu extends StatelessWidget {
  final Song song;
  final SongList? songList;
  final SongListLogic? songListLogic;

  _SongMenu(this.song, this.songList, this.songListLogic);

  @override
  Widget build(BuildContext context) {
    final items = [
      // ['playNext', 'play_circle_outline', stringsOf(context).playNext],
      [
        'addToSongList',
        Icons.library_add_rounded,
        stringsOf(context).collectToPlaylist
      ]
    ];

    if (song.isSingerAvailable) {
      items.add([
        'singer',
        Icons.portrait_rounded,
        stringsOf(context).singerTitle(song.singer)
      ]);
    }

    if (song.isAlbumAvailable) {
      items.add([
        'album',
        Icons.album_rounded,
        stringsOf(context).albumTitle(song.album)
      ]);
    }

    if (songList?.plt == MusicPlatforms.local) {
      items.add([
        'deleteFromSongList',
        Icons.delete_outline_rounded,
        stringsOf(context).delete
      ]);
    }

    items.add([
      "source",
      Icons.link_rounded,
      stringsOf(context).sourceWithPlatform(song.plt)
    ]);

    return SingleChildScrollView(
      child: Column(children: _buildMenuItems(context, items)),
    );
  }

  List<Widget> _buildMenuItems(BuildContext context, List<List> items) {
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
        _navigateToSinger(context);
        break;
      case 'album':
        _openAlbum(context);
        break;
      case 'deleteFromSongList':
        _deleteFromSongList();
        break;
      case 'source':
        _openSource(context);
        break;
    }
  }

  void _playNext() {}

  void _addToSongList(BuildContext context) async {
    var songDao = SongDao();
    var songLists =
        await songDao.queryAllSongListWithoutSongs(plt: MusicPlatforms.local);
    var songList = await selectSongList(context, songLists);
    if (songList == null) {
      return;
    }
    final result = (await songDao.addSongsToSongList(songList.id, [song])) > 0;
    debugPrint("songMenu.addToSongList, result = $result");
    notifyMySongListChanged();
  }

  void _navigateToSinger(BuildContext context) {
    final singer = song.singer;
    if (singer == null) {
      return;
    }
    AppNavigator().navigateTo(context, AppNavigator.singer, params: {
      'plt': singer.plt,
      'singerId': singer.pltId,
      'singer': singer,
    });
  }

  void _deleteFromSongList() async {
    if (songList == null || songListLogic == null) {
      return;
    }
    var _songDao = SongDao();
    await _songDao.deleteSongFromSongList(songList!.id, song.id);
    songListLogic!.refresh();
    notifyMySongListChanged();
  }

  void _openAlbum(BuildContext context) {
    AppNavigator().navigateTo(context, AppNavigator.song_list, params: {
      "plt": song.plt.name,
      "songListId": song.album?.pltId,
      "songListType": SongListType.album
    });
  }

  void _openSource(BuildContext context) {
    final songSource = song.source;
    if (songSource.isNotEmpty) {
      AppNavigator().navigateTo(context, AppNavigator.web_view,
          params: {"url": song.source});
    }
  }
}

class _SongMenuItem extends StatelessWidget {
  final String type;
  final IconData logo;
  final String title;
  final ValueCallback<String> callback;

  _SongMenuItem(this.type, this.logo, this.title, this.callback, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => callback(type),
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 18),
        height: 50,
        child: Row(
          children: <Widget>[
            Icon(
              logo,
              size: 28,
              color: AppColors.tintOutlined,
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              flex: 1,
              child: Text(
                title,
                maxLines: 2,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textTitle,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SongMenuDivider extends StatelessWidget {
  _SongMenuDivider({Key? key}) : super(key: key);

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
Future<SongList?> selectSongList(
    BuildContext context, List<SongList> songLists) async {
  return await showDialog<SongList>(
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
                  color: AppColors.textTitle,
                ),
              ),
            ),
            titlePadding: EdgeInsets.zero,
            content: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: ListBody(
                  children: List.generate(
                    songLists.length,
                    (index) {
                      var songList = songLists[index];
                      return _SelectSongListContentItem(songList,
                          key: ValueKey(songList.pltId));
                    },
                  ),
                ),
              ),
            ),
            contentPadding: EdgeInsets.zero,
          ));
}

class _SelectSongListContentItem extends StatelessWidget {
  final SongList songList;

  _SelectSongListContentItem(this.songList, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          Navigator.of(context).pop(songList);
        },
        child: Container(
          padding: EdgeInsets.fromLTRB(16, 5, 16, 5),
          height: 60,
          child: Row(
            children: <Widget>[
              songList.buildCoverWidget(context),
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
                          color: AppColors.textTitle,
                          fontSize: 16,
                          fontWeight: FontWeight.normal),
                    ),
                    Text(
                      stringsOf(context).songListCountAndCreator(
                          this.songList.songTotal, this.songList.userName),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textLight,
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

void showSongListDescriptionDialog(BuildContext context, String desc) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.mainBg,
          title: Text(
            stringsOf(context).description,
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textTitle,
            ),
          ),
          titlePadding: EdgeInsets.fromLTRB(20, 10, 20, 0),
          content: SingleChildScrollView(
            child: Text(
              desc.isEmpty ? stringsOf(context).nullText : desc,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textTitle,
                fontWeight: FontWeight.normal,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 20),
        );
      });
}
