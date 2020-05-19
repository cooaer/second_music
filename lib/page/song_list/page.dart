import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:second_music/model/enum.dart';
import 'package:second_music/model/song.dart';
import 'package:second_music/model/song_list.dart';
import 'package:second_music/page/model.dart';
import 'package:second_music/page/navigator.dart';
import 'package:second_music/page/play_control/page.dart';
import 'package:second_music/page/song_list/model.dart';
import 'package:second_music/page/song_list/widget.dart';
import 'package:second_music/res/res.dart';
import 'package:second_music/widget/material_icon_round.dart';

class SongListPage extends StatefulWidget {
  final String plt;
  final String songListId;
  final SongListType songListType;

  SongListPage(this.plt, this.songListId, this.songListType, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SongListPageState();
}

class _SongListPageState extends State<SongListPage> {
  SongListModel _model;

  @override
  void initState() {
    super.initState();
    _model = SongListModel(widget.plt, widget.songListId, widget.songListType);
    _model.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return _SongListModelProvider(
      _model,
      child: Scaffold(
        backgroundColor: AppColors.main_bg,
        body: StreamBuilder(
          stream: _model.songListStream,
          builder: (context, AsyncSnapshot<SongList> snapshot) {
            return StreamBuilder(
              initialData: _model.barColor,
              stream: _model.barColorStream,
              builder: (context, AsyncSnapshot<Color> snapshot2) {
                return _buildBody(context, snapshot.data, snapshot2.data);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, SongList songList, Color barBgColor) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          backgroundColor: barBgColor,
          elevation: 0,
          title: Text(
            stringsOf(context).songListTitle(widget.songListType),
            style: TextStyle(
              fontSize: 18,
              color: AppColors.text_embed,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          expandedHeight: MediaQuery.of(context).padding.top + 220,
          forceElevated: true,
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.pin,
            background: _SongListHeader(songList),
          ),
          pinned: true,
          actions: <Widget>[
            ButtonTheme(
              minWidth: 0,
              height: 44,
              child: FlatButton(
                  onPressed: () {},
                  shape: CircleBorder(),
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: MdrIcon(
                    'playlist_add_check',
                    color: AppColors.text_embed,
                    size: 28,
                  )),
            )
          ],
        ),
        SliverPersistentHeader(
          delegate: _ControlBarDelegate(songList),
          pinned: true,
        ),
        if (songList?.songs != null && songList.songs.isNotEmpty)
          SliverPadding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + PlayController.BAR_HEIGHT),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  var song = songList.songs[index];
                  return _SongListItem(
                      index, song, songList, () => showSongMenu(context, song, songList, _model),
                      key: Key(song.id));
                },
                childCount: songList?.songs?.length,
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _model.dispose();
  }
}

class _SongListModelProvider extends InheritedWidget {
  final SongListModel model;

  _SongListModelProvider(this.model, {Key key, Widget child}) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static _SongListModelProvider of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(_SongListModelProvider);
  }
}

class _SongListHeader extends StatelessWidget {
  final SongList songList;

  _SongListHeader(this.songList, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: songList != null && songList.hasDisplayCover
            ? DecorationImage(
                image: CachedNetworkImageProvider(songList?.displayCover), fit: BoxFit.fill)
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          //高斯模糊
          SizedBox.expand(
            child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  color: Colors.white.withOpacity(0.1),
                )),
          ),
          Container(
            alignment: Alignment.center,
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).padding.top + 44, left: 15, right: 15),
            child: Row(
              children: <Widget>[
                //封面
                Stack(
                  alignment: Alignment.topRight,
                  children: <Widget>[
                    ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Container(
                          width: 140,
                          height: 140,
                          color: AppColors.cover_bg,
                          child: songList != null && songList.hasDisplayCover
                              ? CachedNetworkImage(
                                  width: 140,
                                  height: 140,
                                  imageUrl: songList?.displayCover,
                                  fit: BoxFit.cover,
                                )
                              : null,
                        )),
                    if (songList?.playCount != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          MdrIcon(
                            'play_arrow',
                            size: 18,
                            color: AppColors.text_embed,
                          ),
                          Text(
                            stringsOf(context).displayPlayCount(songList?.playCount),
                            style: TextStyle(
                              color: AppColors.text_embed,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          )
                        ],
                      )
                  ],
                ),

                SizedBox(
                  width: 20,
                ),
                //描述信息
                Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 140,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          //标题
                          Text(
                            songList?.title ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.text_embed,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          //创建者
                          if (songList != null && songList.isUserAvailable)
                            GestureDetector(
                              onTap: () => AppNavigator.instance.navigateTo(
                                  context, AppNavigator.web_view,
                                  params: {'url': songList.userSource}, overlay: true),
                              child: Row(
                                children: <Widget>[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: CachedNetworkImage(
                                      width: 32,
                                      height: 32,
                                      imageUrl: songList.userAvatar,
                                      placeholder: (context, url) => Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                            color: AppColors.main_bg,
                                            borderRadius: BorderRadius.circular(16)),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      songList?.userName ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  MdrIcon(
                                    'navigate_next',
                                    size: 24,
                                    color: Colors.white.withOpacity(0.8),
                                  )
                                ],
                              ),
                            ),
                          //歌单描述
                          if (songList?.description != null)
                            GestureDetector(
                              onTap: () =>
                                  showSongListDescriptionDialog(context, songList?.description),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      songList.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  MdrIcon(
                                    'navigate_next',
                                    size: 24,
                                    color: Colors.white.withOpacity(0.8),
                                  )
                                ],
                              ),
                            ),
                        ],
                      ),
                    ))
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlBarDelegate extends SliverPersistentHeaderDelegate {
  final SongList songList;

  _ControlBarDelegate(this.songList);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return _ControlBar(songList);
  }

  @override
  bool shouldRebuild(_ControlBarDelegate oldDelegate) => oldDelegate.songList != this.songList;

  @override
  double get maxExtent => 50;

  @override
  double get minExtent => 50;
}

class _ControlBar extends StatelessWidget {
  final SongList songList;

  _ControlBar(this.songList, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: AppColors.main_bg,
        child: ButtonTheme(
          minWidth: 0,
          height: 50,
          child: FlatButton(
              onPressed: () {
                PlayControlModel.instance.playAndReplaceSongList(songList.songs);
              },
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: <Widget>[
                  MdrIcon(
                    'play_circle_outline',
                    size: 24,
                    color: AppColors.text_title,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    stringsOf(context).playAll,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.text_title,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    stringsOf(context).playAllCount(songList?.songs?.length),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.text_light,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Spacer(),
                  if (songList?.plt != MusicPlatforms.LOCAL)
                    StreamBuilder(
                      initialData: null,
                      stream: _SongListModelProvider.of(context).model.isCollectedStream,
                      builder: (context, AsyncSnapshot<bool> snapshot) {
                        var _isCollectedEnable = snapshot.data != null;
                        var _isCollected = snapshot.data == true;
                        return ButtonTheme(
                          height: 40,
                          child: RaisedButton(
                            onPressed: _isCollectedEnable
                                ? _SongListModelProvider.of(context).model.togglePlaylistCollection
                                : null,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            color: _isCollected ? AppColors.disabled : AppColors.accent,
                            child: Text(
                              stringsOf(context).collectAll(_isCollected, songList?.favorCount),
                              style: TextStyle(
                                color: AppColors.text_embed,
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              )),
        ));
  }
}

class _SongListItem extends StatelessWidget {
  final int index;
  final Song song;
  final SongList songList;
  final VoidCallback onTapMenu;

  _SongListItem(this.index, this.song, this.songList, this.onTapMenu, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      height: 60,
      minWidth: 0,
      child: FlatButton(
        onPressed: () {
          AppNavigator.instance
              .navigateTo(context, AppNavigator.play, params: {'song': song}, overlay: true);
        },
        padding: EdgeInsets.zero,
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 10,
            ),
            Container(
              width: 25,
              alignment: Alignment.center,
              child: Text(
                '${index + 1}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.text_light,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    song?.name ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.text_title,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Text(
                    stringsOf(context).singerAndAlbum(song?.singer?.name, song?.album?.name),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.text_light,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            FlatButton(
              onPressed: onTapMenu,
              shape: CircleBorder(),
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: MdrIcon(
                'more_vert',
                size: 24,
                color: AppColors.tint_rounded,
              ),
            )
          ],
        ),
      ),
    );
  }
}
