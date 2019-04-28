import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_tabs/extended_tabs.dart';
import 'package:flutter/material.dart';
import 'package:second_music/model/enum.dart';
import 'package:second_music/model/playlist.dart';
import 'package:second_music/model/playlist_set.dart';
import 'package:second_music/model/song_list.dart';
import 'package:second_music/page/home/hot_playlist/model.dart';
import 'package:second_music/page/navigator.dart';
import 'package:second_music/res/res.dart';
import 'package:second_music/storage/preference/config.dart';
import 'package:second_music/widget/loading_more.dart';
import 'package:second_music/widget/material_icon_round.dart';

class HomeHotPlaylist extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeHotPlaylistState();
  }
}

class HomeHotPlaylistState extends State with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    int length = MusicPlatforms.platforms.length;
    return DefaultTabController(
      length: length,
      child: Column(
        children: <Widget>[
          HomeHotPlaylistTabBar(),
          Expanded(
            flex: 1,
            child: HomeHotPlaylistTabBarView(),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class HomeHotPlaylistTabBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: StreamBuilder(
          initialData: AppConfig.instance.platformRank,
          stream: AppConfig.instance.platformRankStream,
          builder: (context, AsyncSnapshot<List<String>> snapshot) {
            return TabBar(
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: AppColors.text_accent,
                unselectedLabelColor: AppColors.text_light,
                labelPadding: EdgeInsets.zero,
                tabs: snapshot.data.map((item) {
                  var name =
                      stringsOf(context).platformNames[MusicPlatforms.platforms.indexOf(item)];
                  return Tab(
                    key: Key(name),
                    text: name,
                  );
                }).toList());
          },
        ));
  }
}

class HomeHotPlaylistTabBarView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: AppConfig.instance.platformRank,
      stream: AppConfig.instance.platformRankStream,
      builder: (context, AsyncSnapshot<List<String>> snapshot) {
        return ExtendedTabBarView(
            linkWithAncestor: true,
            children: snapshot.data
                .map((item) => HomeHotPlaylistPlatform(item, key: Key(item)))
                .toList());
      },
    );
  }
}

class HotPlaylistModelProvider extends InheritedWidget {
  final HotPlaylistModel model;

  HotPlaylistModelProvider(this.model, {Key key, Widget child}) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static HotPlaylistModelProvider of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(HotPlaylistModelProvider);
  }
}

class HomeHotPlaylistPlatform extends StatefulWidget {
  final String platform;

  HomeHotPlaylistPlatform(this.platform, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HomeHotPlaylistPlatformState(platform);
  }
}

class HomeHotPlaylistPlatformState extends State with AutomaticKeepAliveClientMixin {
  static final int crossAxisCount = 3;
  var _100dp = 50.0;

  HotPlaylistModel _hotPlaylistModel;

  final String platform;

  ScrollController _scrollController = ScrollController();

  HomeHotPlaylistPlatformState(this.platform) : _hotPlaylistModel = HotPlaylistModel(platform);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _hotPlaylistModel.refresh();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    _100dp = MediaQuery.of(context).devicePixelRatio * 50;

    return HotPlaylistModelProvider(_hotPlaylistModel,
        child: StreamBuilder(
            stream: _hotPlaylistModel.playlistSetStream,
            builder: (context, AsyncSnapshot<PlaylistSet> snapshot) {
              return RefreshIndicator(
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: <Widget>[
                      _buildGrid(context, snapshot.data),
                      if (snapshot.data == null || snapshot.data.hasNext)
                        SliverToBoxAdapter(
                          child: _buildLoadMore(context),
                        ),
                    ],
                  ),
                  onRefresh: () => _onRefresh(_hotPlaylistModel));
            }));
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _hotPlaylistModel.dispose();
  }

  Widget _buildGrid(BuildContext context, PlaylistSet set) {
    double itemWidth =
        (MediaQuery.of(context).size.width - (crossAxisCount - 1) * 10 - 16 * 2) / crossAxisCount;
    double itemHeight = itemWidth + 8 * 2 + 14 * 2 + 6;

    return SliverPadding(
        padding: EdgeInsets.all(16),
        sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate((context, index) {
              var item = set.playlists[index];
              return FlatButton(
                onPressed: () {
                  AppNavigator.instance.navigateTo(context, AppNavigator.song_list, params: {
                    'plt': item.plt,
                    'songListId': item.id,
                    'songListType': SongListType.playlist
                  });
                },
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                child: HomeHotPlaylistItem(item, key: Key(item.id)),
              );
            }, childCount: set == null ? 0 : set.playlists.length),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 10,
              mainAxisSpacing: 12,
              childAspectRatio: itemWidth / itemHeight,
            )));
  }

  Widget _buildLoadMore(BuildContext context) {
    return StreamBuilder(
        initialData: _hotPlaylistModel.loading,
        stream: _hotPlaylistModel.loadingStream,
        builder: (context, AsyncSnapshot<bool> snapshot) {
          var loading = snapshot.data;
          return StreamBuilder(
              initialData: _hotPlaylistModel.lastError,
              stream: _hotPlaylistModel.lastErrorStream,
              builder: (context, AsyncSnapshot<bool> snapshot) {
                var lastError = snapshot.data;
                return LoadingMore(loading, lastError, () =>
                    HotPlaylistModelProvider.of(context).model.requestMore(true));
              });
        });
  }

  @override
  bool get wantKeepAlive => true;

  Future _onRefresh(HotPlaylistModel model) async {
    await model.refresh();
  }

  Future _onScroll() async {
    if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent - _100dp) {
      _hotPlaylistModel.requestMore(false);
    }
  }
}

class HomeHotPlaylistItem extends StatelessWidget {
  final Playlist playlist;

  HomeHotPlaylistItem(this.playlist, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              //封面
              AspectRatio(
                aspectRatio: 1,
                child: CachedNetworkImage(
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
                      MdrIcon(
                        'play_arrow',
                        size: 18,
                        color: AppColors.text_embed,
                      ),
                      Text(
                        stringsOf(context).displayPlayCount(playlist.playCount),
                        style: TextStyle(
                          color: AppColors.text_embed,
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
                color: AppColors.text_title,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        )
      ],
    );
  }
}


