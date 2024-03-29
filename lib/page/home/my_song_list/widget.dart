import 'package:dart_extensions_methods/dart_extension_methods.dart';
import 'package:flutter/material.dart';
import 'package:second_music/entity/song_list.dart';
import 'package:second_music/page/basic_types.dart';
import 'package:second_music/page/home/my_song_list/logic.dart';
import 'package:second_music/repository/local/database/song/dao.dart';
import 'package:second_music/res/res.dart';

void showCreatePlaylistDialog(BuildContext context) {
  showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        var logic = CreatePlaylistLogic();
        return AlertDialog(
          title: Text(
            stringsOf(context).createPlaylist,
            style: TextStyle(
              fontSize: 20,
              color: AppColors.textTitle,
              fontWeight: FontWeight.w500,
            ),
          ),
          titlePadding: EdgeInsets.fromLTRB(20, 20, 20, 0),
          content: TextField(
            controller: logic.titleEditingController,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (text) {
              _createPlaylist(context, text.trim());
            },
            decoration: InputDecoration(
              hintText: stringsOf(context).pleaseInputPlaylistTitle,
              hintStyle: TextStyle(
                color: AppColors.textLight,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          contentPadding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(stringsOf(context).cancel)),
            StreamBuilder(
                stream: logic.titleStream,
                builder: (context, AsyncSnapshot<String> snapshot) {
                  final title = snapshot.data;
                  return TextButton(
                      onPressed: title.isNullOrEmpty()
                          ? null
                          : () => _createPlaylist(context,
                              logic.titleEditingController.text.trim()),
                      child: Text(stringsOf(context).ok));
                }),
          ],
        );
      });
}

void _createPlaylist(BuildContext context, String text) async {
  if (text.isEmpty) {
    return;
  }
  Navigator.of(context).pop();
  var songDao = SongDao();
  await songDao.createSongList(text);
  notifyMySongListChanged();
}

void showSongListMenu(BuildContext context, SongList songList) {
  showModalBottomSheet(
      context: context, builder: (context) => _SongMenu(songList));
}

//删除
class _SongMenu extends StatelessWidget {
  final SongList songList;

  _SongMenu(this.songList);

  @override
  Widget build(BuildContext context) {
    var listWidgets = <Widget>[];
    listWidgets.add(Container(
      height: 50,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 18),
      child: Text(
        stringsOf(context).playlistWithTitle(songList.title),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ));
    listWidgets.add(Divider(
      color: AppColors.divider,
      height: 1,
    ));

    final items = [
      [
        'deleteSongList',
        Icons.delete_outline_rounded,
        stringsOf(context).delete,
        !songList.isFavor
      ]
    ];

    listWidgets.addAll(_buildMenuItems(context, items));

    return SingleChildScrollView(
      child: Column(children: listWidgets),
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
        item[3],
        (type) => _onTapMenuItem(context, type),
        key: Key(item[0]),
      ));
    }
    return widgets;
  }

  void _onTapMenuItem(BuildContext context, String type) {
    Navigator.of(context).pop();
    switch (type) {
      case 'deleteSongList':
        _deleteSongList();
        break;
    }
  }

  void _deleteSongList() async {
    var _songDao = SongDao();
    await _songDao.deleteSongList(songList.id);
    notifyMySongListChanged();
  }
}

class _SongMenuItem extends StatelessWidget {
  final String type;
  final IconData logo;
  final String title;
  final bool enable;
  final ValueCallback<String> callback;

  _SongMenuItem(this.type, this.logo, this.title, this.enable, this.callback,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => enable ? callback(type) : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18),
        alignment: Alignment.center,
        height: 50,
        child: Row(
          children: <Widget>[
            Icon(
              logo,
              size: 28,
              color: enable ? AppColors.tintOutlined : AppColors.disabled,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: enable ? AppColors.textTitle : AppColors.disabled,
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
