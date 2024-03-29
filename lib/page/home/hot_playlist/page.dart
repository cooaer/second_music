import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:second_music/entity/enum.dart';
import 'package:second_music/entity/playlist.dart';
import 'package:second_music/entity/playlist_set.dart';
import 'package:second_music/entity/song_list.dart';
import 'package:second_music/page/basic_types.dart';
import 'package:second_music/page/home/hot_playlist/logic.dart';
import 'package:second_music/page/navigator.dart';
import 'package:second_music/res/res.dart';
import 'package:second_music/widget/loading_more.dart';

class HotPlaylistLogicProvider extends InheritedWidget {
  final HotPlaylistLogic logic;

  HotPlaylistLogicProvider(this.logic, {Key? key, required Widget child})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static HotPlaylistLogicProvider? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<HotPlaylistLogicProvider>();
  }
}

class HomeHotPlaylistPlatform extends StatefulWidget {
  final MusicPlatform platform;

  HomeHotPlaylistPlatform(this.platform, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HomeHotPlaylistPlatformState(platform);
  }
}

class HomeHotPlaylistPlatformState extends State
    with AutomaticKeepAliveClientMixin {
  static final int crossAxisCount = 3;
  var _loadMorePixels = 50.0;

  HotPlaylistLogic _hotPlaylistLogic;

  final MusicPlatform platform;

  ScrollController _scrollController = ScrollController();

  HomeHotPlaylistPlatformState(this.platform)
      : _hotPlaylistLogic = HotPlaylistLogic(platform);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _hotPlaylistLogic.refresh();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    _loadMorePixels = MediaQuery.of(context).devicePixelRatio * 50;

    return HotPlaylistLogicProvider(_hotPlaylistLogic,
        child: StreamBuilder(
            stream: _hotPlaylistLogic.playlistSetStream,
            builder: (context, AsyncSnapshot<PlaylistSet> snapshot) {
              return RefreshIndicator(
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: <Widget>[
                      _buildGrid(context, snapshot.data?.playlists ?? []),
                      if (snapshot.data == null || snapshot.data!.hasNext)
                        SliverToBoxAdapter(
                          child: _buildLoadMore(context),
                        ),
                    ],
                  ),
                  onRefresh: () => _onRefresh(_hotPlaylistLogic));
            }));
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _hotPlaylistLogic.dispose();
  }

  Widget _buildGrid(BuildContext context, List<Playlist> playlists) {
    double itemWidth = (MediaQuery.of(context).size.width -
            (crossAxisCount - 1) * 10 -
            16 * 2) /
        crossAxisCount;
    double itemHeight = itemWidth + 8 * 2 + 14 * 2 + 6;

    return SliverPadding(
        padding: EdgeInsets.all(16),
        sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate((context, index) {
              var item = playlists[index];

              final onPressed = () {
                AppNavigator()
                    .navigateTo(context, AppNavigator.song_list, params: {
                  'plt': item.plt.name,
                  'songListId': item.pltId,
                  'songListType': SongListType.playlist
                });
              };
              return HotPlaylistItem(item,
                  onPressed: onPressed, key: Key(item.pltId));
            }, childCount: playlists.length),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 10,
              mainAxisSpacing: 12,
              childAspectRatio: itemWidth / itemHeight,
            )));
  }

  Widget _buildLoadMore(BuildContext context) {
    return StreamBuilder(
        initialData: _hotPlaylistLogic.loading,
        stream: _hotPlaylistLogic.loadingStream,
        builder: (context, AsyncSnapshot<bool> snapshot) {
          var loading = snapshot.data!;
          return StreamBuilder(
              initialData: _hotPlaylistLogic.lastError,
              stream: _hotPlaylistLogic.lastErrorStream,
              builder: (context, AsyncSnapshot<bool> snapshot) {
                var lastError = snapshot.data!;
                return LoadingMore(
                    loading,
                    lastError,
                    () => HotPlaylistLogicProvider.of(context)
                        ?.logic
                        .requestMore(true));
              });
        });
  }

  @override
  bool get wantKeepAlive => true;

  Future _onRefresh(HotPlaylistLogic logic) async {
    await logic.refresh();
  }

  Future _onScroll() async {
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - _loadMorePixels) {
      _hotPlaylistLogic.requestMore(false);
    }
  }
}

class HotPlaylistItem extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback? onPressed;

  HotPlaylistItem(this.playlist, {this.onPressed, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  child: playlist.cover.isEmpty
                      ? Container(
                          color: AppColors.coverBg,
                        )
                      : CachedNetworkImage(
                          imageUrl: playlist.cover,
                          fit: BoxFit.cover,
                        ),
                ),

                //播放量
                Container(
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
                          stringsOf(context)
                              .displayPlayCount(playlist.playCount),
                          style: TextStyle(
                            color: AppColors.textEmbed,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ))
              ],
            ),
          ),
          //标题
          Expanded(
            flex: 1,
            child: Container(
              margin: EdgeInsets.only(top: 8),
              child: Text(
                playlist.title,
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
