import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:second_music/entity/enum.dart';
import 'package:second_music/page/home/hot_playlist/page.dart';
import 'package:second_music/page/home/my_song_list/page.dart';
import 'package:second_music/page/mini_player/mini_player_page.dart';
import 'package:second_music/page/navigator.dart';
import 'package:second_music/page/ui_style.dart';
import 'package:second_music/res/res.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final navigatorPaddingBottom =
        MediaQuery.of(context).padding.bottom + MiniPlayer.BAR_HEIGHT;
    return Material(
      child: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              bottom: navigatorPaddingBottom,
            ),
            child: _NavigatorContainer(),
          ),
          MiniPlayer(),
        ],
      ),
    );
  }
}

class _NavigatorContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return !await (navigatorKey.currentState as NavigatorState).maybePop();
      },
      child: Navigator(
        key: navigatorKey,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          if (settings.name == '/') {
            return MaterialPageRoute(
                builder: (context) => AnnotatedRegion<SystemUiOverlayStyle>(
                      value: darkIconUiStyle,
                      child: _HomeContent(),
                    ),
                settings: settings);
          }
          return null;
        },
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _HomeTopBar(),
        Expanded(
          child: _HomeTabBarAndView(),
        ),
      ],
    );
  }
}

class _HomeTopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 2,
          )
        ],
      ),
      child: SafeArea(
        bottom: false,
        left: false,
        right: false,
        child: Container(
          height: 50,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                AppImages.appIcon,
                color: AppColors.textTitle,
              ),
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 32,
                  child: Material(
                    child: Ink(
                      decoration: BoxDecoration(
                          color: AppColors.searchBg,
                          borderRadius: BorderRadius.all(Radius.circular(16))),
                      child: InkWell(
                        customBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        onTap: () {
                          AppNavigator()
                              .navigateTo(context, AppNavigator.search);
                        },
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(left: 10, right: 6),
                              child: Icon(
                                Icons.search_rounded,
                                color: AppColors.tintRounded,
                                size: 20,
                              ),
                            ),
                            Text(
                              stringsOf(context).mainSearchHint,
                              style: TextStyle(
                                color: AppColors.textLight,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                width: 48,
                height: 48,
                child: TextButton(
                  onPressed: () => AppNavigator()
                      .navigateTo(context, AppNavigator.setting, overlay: true),
                  child: Icon(
                    Icons.settings_outlined,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeTabBarAndView extends StatelessWidget {
  static List<MusicPlatform> tabPlts = List.of(MusicPlatform.values);

  @override
  Widget build(BuildContext context) {
    var titles = tabPlts.map((e) => stringsOf(context).platform(e)).toList()
      ..insert(0, stringsOf(context).mine);
    return DefaultTabController(
      length: titles.length,
      child: Column(
        children: <Widget>[
          _HomeTabBar(titles),
          _HomeTabBarView(tabPlts),
        ],
      ),
    );
  }
}

class _HomeTabBar extends StatelessWidget {
  final List<String> titles;

  _HomeTabBar(this.titles);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: AppColors.mainBg,
        child: TabBar(
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: AppColors.textAccent,
            unselectedLabelColor: AppColors.textLight,
            labelPadding: EdgeInsets.zero,
            tabs: titles
                .map((e) => Tab(
                      key: Key(e),
                      text: e,
                    ))
                .toList()));
  }
}

class _HomeTabBarView extends StatelessWidget {
  final List<MusicPlatform> platforms;

  _HomeTabBarView(this.platforms);

  @override
  Widget build(BuildContext context) {
    var children = platforms
        .map<Widget>((e) => HomeHotPlaylistPlatform(e, key: Key(e.name)))
        .toList();
    children.insert(0, HomeMySongList());
    return Expanded(child: TabBarView(children: children));
  }
}
