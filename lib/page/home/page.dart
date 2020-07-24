import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:second_music/model/enum.dart';
import 'package:second_music/page/home/hot_playlist/page.dart';
import 'package:second_music/page/home/my_song_list/page.dart';
import 'package:second_music/page/navigator.dart';
import 'package:second_music/page/play_control/page.dart';
import 'package:second_music/page/ui_style.dart';
import 'package:second_music/res/res.dart';
import 'package:second_music/widget/material_icon_round.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: <Widget>[
          _NavigatorContainer(),
          PlayController(),
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
    return Scaffold(
      body: Stack(
        children: <Widget>[
          SafeArea(
            child: Container(
              padding: EdgeInsets.only(top: 50, bottom: 48 + MediaQuery.of(context).padding.bottom),
              child: _HomeTabs(),
            ),
          ),
          _HomeTopBar(),
        ],
      ),
    );
  }
}

class _HomeTopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 2,
          )
        ]),
        child: SafeArea(
            bottom: false,
            left: false,
            right: false,
            child: Container(
                height: 50,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Dier',
                        style: TextStyle(
                          fontSize: 28,
                          color: AppColors.text_title,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                          height: 32,
                          child: FlatButton(
                              color: AppColors.search_bg,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              onPressed: () {
                                AppNavigator.instance.navigateTo(context, AppNavigator.search);
                              },
                              child: Row(
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(left: 10, right: 6),
                                    child: MdrIcon(
                                      'search',
                                      color: AppColors.tint_rounded,
                                      size: 20,
                                    ),
                                  ),
                                  Text(
                                    stringsOf(context).mainSearchHint,
                                    style: TextStyle(
                                      color: AppColors.text_light,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ))),
                    ),
                    Container(
                        alignment: Alignment.center,
                        width: 48,
                        height: 48,
                        child: FlatButton(
                          padding: EdgeInsets.all(0),
                          shape: CircleBorder(side: BorderSide.none),
                          onPressed: () => AppNavigator.instance
                              .navigateTo(context, AppNavigator.setting, overlay: true),
                          child: Icon(
                            MdiIcons.cogOutline,
                            color: Colors.grey.shade600,
                          ),
                        )),
                  ],
                ))));
  }
}

class _HomeTabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var titles = MusicPlatforms.platforms.map((e) => stringsOf(context).platform(e)).toList()
      ..insert(0, stringsOf(context).mine);
    return DefaultTabController(
      length: titles.length,
      child: Column(
        children: <Widget>[
          _HomeTabBar(titles),
          _HomeTabBarView(MusicPlatforms.platforms),
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
        color: AppColors.main_bg,
        child: TabBar(
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: AppColors.text_accent,
            unselectedLabelColor: AppColors.text_light,
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
  final List<String> platforms;

  _HomeTabBarView(this.platforms);

  @override
  Widget build(BuildContext context) {
    var children = platforms.map<Widget>((e) => HomeHotPlaylistPlatform(e, key: Key(e))).toList();
    children.insert(0, HomeMySongList());
    return Expanded(child: TabBarView(children: children));
  }
}
