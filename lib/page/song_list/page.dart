import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dart_extensions_methods/dart_extension_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:second_music/entity/enum.dart';
import 'package:second_music/entity/song.dart';
import 'package:second_music/entity/song_list.dart';
import 'package:second_music/page/mini_player/mini_player_page.dart';
import 'package:second_music/page/navigator.dart';
import 'package:second_music/page/song_list/model.dart';
import 'package:second_music/page/song_list/widget.dart';
import 'package:second_music/res/res.dart';
import 'package:toast/toast.dart';

class SongListPage extends StatefulWidget {
  final String plt;
  final String songListId;
  final SongListType songListType;

  SongListPage(this.plt, this.songListId, this.songListType, {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _SongListPageState();
}

class _SongListPageState extends State<SongListPage> {
  late SongListModel _model;

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
        backgroundColor: AppColors.mainBg,
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

  Widget _buildBody(
      BuildContext context, SongList? songList, Color? barBgColor) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          backgroundColor: barBgColor,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          title: Text(
            stringsOf(context).songListTitle(widget.songListType),
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textEmbed,
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
            IconButton(
              onPressed: () {
                Toast.show(stringsOf(context).developing);
              },
              padding: EdgeInsets.symmetric(horizontal: 10),
              icon: Icon(Icons.download_rounded),
            ),
            IconButton(
              onPressed: () {
                final songListSource = _model.songList?.source;
                if (songListSource.isNotNullOrEmpty()) {
                  AppNavigator.instance.navigateTo(
                      context, AppNavigator.web_view,
                      params: {"url": songListSource});
                }
              },
              padding: EdgeInsets.symmetric(horizontal: 10),
              icon: Icon(Icons.link),
            ),
          ],
        ),
        SliverPersistentHeader(
          delegate: _ControlBarDelegate(songList),
          pinned: true,
        ),
        if (songList != null && songList.songs.isNotEmpty)
          SliverPadding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom +
                    MiniPlayer.BAR_HEIGHT),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  var song = songList.songs[index];
                  return _SongListItem(index, song,
                      () => showSongMenu(context, song, songList, _model),
                      key: Key(song.pltId));
                },
                childCount: songList.songs.length,
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

  _SongListModelProvider(this.model, {Key? key, required Widget child})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static _SongListModelProvider of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_SongListModelProvider>()!;
  }
}

class _SongListHeader extends StatelessWidget {
  final SongList? songList;

  _SongListHeader(this.songList, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: songList?.hasDisplayCover == true
            ? DecorationImage(
                image: CachedNetworkImageProvider(songList!.displayCover),
                fit: BoxFit.fill)
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
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 44,
                left: 15,
                right: 15),
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
                          color: AppColors.coverBg,
                          child: (songList != null && songList!.hasDisplayCover)
                              ? CachedNetworkImage(
                                  width: 140,
                                  height: 140,
                                  imageUrl: songList!.displayCover,
                                  fit: BoxFit.cover,
                                )
                              : null,
                        )),
                    if (songList?.playCount != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Icon(
                            Icons.play_arrow_rounded,
                            size: 18,
                            color: AppColors.textEmbed,
                          ),
                          Text(
                            stringsOf(context)
                                .displayPlayCount(songList!.playCount),
                            style: TextStyle(
                              color: AppColors.textEmbed,
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
                              color: AppColors.textEmbed,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          //创建者
                          if (songList != null && songList!.isUserAvailable)
                            GestureDetector(
                              onTap: () {
                                final userSource = songList!.userSource;
                                if (userSource.isNotEmpty) {
                                  AppNavigator.instance.navigateTo(
                                      context, AppNavigator.web_view,
                                      params: {'url': songList!.userSource},
                                      overlay: true);
                                }
                              },
                              child: Row(
                                children: <Widget>[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: CachedNetworkImage(
                                      width: 32,
                                      height: 32,
                                      imageUrl: songList!.userAvatar,
                                      placeholder: (context, url) => Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                            color: AppColors.mainBg,
                                            borderRadius:
                                                BorderRadius.circular(16)),
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
                                  Visibility(
                                    visible:
                                        songList!.userSource.isNotNullOrEmpty(),
                                    child: Icon(
                                      Icons.navigate_next_rounded,
                                      size: 24,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          //歌单描述
                          if (songList?.description != null)
                            GestureDetector(
                              onTap: () => showSongListDescriptionDialog(
                                  context, songList!.description),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      songList!.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.navigate_next_rounded,
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
  final SongList? songList;

  _ControlBarDelegate(this.songList);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return _ControlBar(songList);
  }

  @override
  bool shouldRebuild(_ControlBarDelegate oldDelegate) =>
      oldDelegate.songList != this.songList;

  @override
  double get maxExtent => 50;

  @override
  double get minExtent => 50;
}

class _ControlBar extends StatelessWidget {
  final SongList? songList;

  _ControlBar(this.songList, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Ink(
      color: AppColors.mainBg,
      height: 50,
      child: InkWell(
        onTap: () {
          final model = _SongListModelProvider.of(context).model;
          model.playAll();
        },
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 10,
            ),
            Icon(
              Icons.play_circle_outline_rounded,
              size: 24,
              color: AppColors.textTitle,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              stringsOf(context).playAll,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textTitle,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              stringsOf(context).playAllCount(songList?.songs.length ?? 0),
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textLight,
                fontWeight: FontWeight.normal,
              ),
            ),
            Spacer(),
            if (songList?.plt != MusicPlatforms.local)
              StreamBuilder(
                initialData: null,
                stream:
                    _SongListModelProvider.of(context).model.isCollectedStream,
                builder: (context, AsyncSnapshot<bool?> snapshot) {
                  var _isCollectedEnable = snapshot.data != null;
                  var _isCollected = snapshot.data == true;
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () {
                      if (_isCollectedEnable && songList != null) {
                        _SongListModelProvider.of(context)
                            .model
                            .togglePlaylistCollection(songList!);
                      }
                    },
                    child: Text(
                      stringsOf(context)
                          .collectAll(_isCollected, songList?.favorCount ?? 0),
                      style: TextStyle(
                        color: AppColors.textEmbed,
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            SizedBox(
              width: 10,
            ),
          ],
        ),
      ),
    );
  }
}

class _SongListItem extends StatelessWidget {
  final int index;
  final Song song;
  final VoidCallback onTapMenu;

  _SongListItem(this.index, this.song, this.onTapMenu, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isPlayable = song.isPlayable;
    return Ink(
      height: 60,
      child: InkWell(
        onTap: () {
          if (isPlayable) {
            AppNavigator.instance.navigateTo(context, AppNavigator.play,
                params: {'song': song}, overlay: true);
          } else {
            Toast.show(stringsOf(context).playFailBecauseOfCopyright);
          }
        },
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
                  color: AppColors.textLight,
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    song.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      color: isPlayable
                          ? AppColors.textTitle
                          : AppColors.textDisabled,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Text(
                    stringsOf(context)
                        .singerAndAlbum(song.singer?.name, song.album?.name),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: isPlayable
                          ? AppColors.textLight
                          : AppColors.textDisabled,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onTapMenu,
              icon: Icon(
                Icons.more_vert_rounded,
                size: 24,
                color: AppColors.tintRounded,
              ),
            )
          ],
        ),
      ),
    );
  }
}
