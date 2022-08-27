import 'package:cached_network_image/cached_network_image.dart';
import 'package:dart_extensions_methods/dart_extension_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:second_music/entity/album.dart';
import 'package:second_music/entity/enum.dart';
import 'package:second_music/entity/singer.dart';
import 'package:second_music/entity/song_list.dart';
import 'package:second_music/page/navigator.dart';
import 'package:second_music/page/singer/singer_state.dart';
import 'package:second_music/page/song_list/page.dart';
import 'package:second_music/page/song_list/widget.dart';
import 'package:second_music/res/res.dart';
import 'package:second_music/widget/loading_more.dart';

import 'singer_logic.dart';

class SingerPage extends StatefulWidget {
  static const TAB_LENGTH = 2;

  final MusicPlatform plt;
  final String singerId;
  final Singer? singer;

  String get uniqueId => '$plt#$singerId';

  SingerPage(this.plt, this.singerId, {this.singer, Key? key})
      : super(key: key) {
    Get.put(SingerLogic(plt, singerId, singer), tag: uniqueId);
  }

  @override
  _SingerPageState createState() => _SingerPageState();
}

class _SingerPageState extends State<SingerPage> {
  late SingerLogic logic;
  late SingerState state;

  @override
  void initState() {
    super.initState();
    logic = Get.find<SingerLogic>(tag: widget.uniqueId);
    state = logic.state;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: SingerPage.TAB_LENGTH,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) =>
              [_buildSingerHeader(context)],
          body: TabBarView(
            children: [
              _buildSingerHotSongs(context),
              _buildSingerHotAlbums(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSingerHeader(BuildContext context) {
    return GetBuilder<SingerLogic>(
      init: logic,
      builder: (controller) => _SingerHeader(this.logic, this.state),
    );
  }

  Widget _buildSingerHotSongs(BuildContext context) {
    return GetBuilder<SingerLogic>(
      init: logic,
      builder: (controller) => _SingerHotSongs(this.logic, this.state),
    );
  }

  Widget _buildSingerHotAlbums(BuildContext context) {
    return GetBuilder<SingerLogic>(
      init: logic,
      builder: (controller) => _SingerHotAlbums(this.logic, this.state),
    );
  }

  @override
  void dispose() {
    Get.delete<SingerLogic>(tag: widget.uniqueId);
    super.dispose();
  }
}

class _SingerHeader extends StatelessWidget {
  final SingerLogic logic;
  final SingerState state;

  _SingerHeader(this.logic, this.state, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tabNames = stringsOf(context).singerTabNames;
    final headerExpandedHeight = MediaQuery.of(context).size.width * 0.618 +
        MediaQuery.of(context).padding.top;
    return SliverAppBar(
      backgroundColor: state.topBarColor,
      title: Text(state.singer?.name ?? ""),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(kTextTabBarHeight),
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [state.topBarColor, state.transparentTopBarColor])),
          child: TabBar(
            tabs: tabNames.map(_makeTab).toList(),
            indicatorSize: TabBarIndicatorSize.label,
          ),
        ),
      ),
      expandedHeight: headerExpandedHeight,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: _buildAppBarBackgroundImage(context),
      ),
      actions: [
        IconButton(
            onPressed: () {
              AppNavigator().navigateTo(context, AppNavigator.web_view,
                  params: {"url": state.singer?.source});
            },
            icon: Icon(Icons.link_rounded))
      ],
    );
  }

  Tab _makeTab(String name) {
    return Tab(
      key: Key(name),
      text: name,
    );
  }

  Widget _buildAppBarBackgroundImage(BuildContext context) {
    final avatarUrl = state.singer?.avatar;
    return avatarUrl.isNullOrEmpty()
        ? Container()
        : CachedNetworkImage(
            imageUrl: avatarUrl!,
            fit: BoxFit.cover,
          );
  }
}

class _SingerHotSongs extends StatefulWidget {
  final SingerLogic logic;
  final SingerState state;

  _SingerHotSongs(this.logic, this.state, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SingerHotSongsState();
  }
}

class _SingerHotSongsState extends State<_SingerHotSongs>
    with AutomaticKeepAliveClientMixin<_SingerHotSongs> {
  late SingerLogic logic;
  late SingerState state;

  @override
  void initState() {
    super.initState();
    logic = widget.logic;
    state = widget.state;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var itemCount = state.songs.length;
    if (state.isLoadingSongs) {
      itemCount++;
    }
    return ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (state.isLoadingSongs && index == itemCount - 1) {
            return LoadingMore(true, false, () {});
          }
          final song = state.songs[index];
          return SongListItem(
            index,
            song,
            () => showSongMenu(context, song, null, null),
            key: Key(song.uniqueId),
          );
        });
  }

  @override
  bool get wantKeepAlive => true;
}

class _SingerHotAlbums extends StatefulWidget {
  final SingerLogic logic;
  final SingerState state;

  _SingerHotAlbums(this.logic, this.state, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SingerHotAlbumsState();
}

class _SingerHotAlbumsState extends State<_SingerHotAlbums>
    with AutomaticKeepAliveClientMixin<_SingerHotAlbums> {
  static final int crossAxisCount = 3;
  late SingerLogic logic;
  late SingerState state;

  @override
  void initState() {
    super.initState();
    logic = widget.logic;
    state = widget.state;
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      logic.requestHotAlbums();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double itemWidth = (MediaQuery.of(context).size.width -
            (crossAxisCount - 1) * 10 -
            16 * 2) /
        crossAxisCount;
    double itemHeight = itemWidth + 8 * 2 + 14 * 2 + 6;

    if (state.isLoadingAlbums) {
      return Container(
          alignment: Alignment.topCenter,
          child: LoadingMore(true, false, () {}));
    }

    if (state.albums.isEmpty) {
      return Container(
        alignment: Alignment.center,
        child: Text(stringsOf(context).nullData),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(16),
      itemCount: state.albums.length,
      itemBuilder: (context, index) {
        final album = state.albums[index];
        return HotAlbumItem(
          album,
          onPressed: () {
            final songList = SongList.fromAlbum(album);
            AppNavigator().navigateTo(context, AppNavigator.song_list, params: {
              'plt': songList.plt,
              'songListId': songList.pltId,
              'songListType': songList.type,
            });
          },
        );
      },
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 12,
        childAspectRatio: itemWidth / itemHeight,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class HotAlbumItem extends StatelessWidget {
  final Album album;
  final VoidCallback? onPressed;

  HotAlbumItem(this.album, {this.onPressed, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultCoverWidget = Container(
      color: AppColors.pageBackground,
    );
    return InkWell(
      onTap: this.onPressed,
      borderRadius: BorderRadius.circular(5),
      child: Column(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                //封面
                AspectRatio(
                  aspectRatio: 1,
                  child: album.cover.isEmpty
                      ? defaultCoverWidget
                      : CachedNetworkImage(
                          imageUrl: album.cover,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) =>
                              defaultCoverWidget,
                          placeholder: (context, url) => defaultCoverWidget,
                        ),
                ),
                //播放量

                Visibility(
                  visible: album.playCount > 0,
                  child: Container(
                    height: 30,
                    alignment: Alignment.topRight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black26, Colors.transparent],
                        begin: AlignmentDirectional.topCenter,
                        end: AlignmentDirectional.bottomCenter,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Icon(
                          Icons.play_arrow_rounded,
                          size: 18,
                          color: AppColors.textEmbed,
                        ),
                        Text(
                          stringsOf(context).displayPlayCount(album.playCount),
                          style: TextStyle(
                            color: AppColors.textEmbed,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          //标题
          Expanded(
            flex: 1,
            child: Container(
              margin: EdgeInsets.only(top: 8),
              child: Text(
                album.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textTitle,
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
