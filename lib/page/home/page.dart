import 'package:extended_tabs/extended_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    return DefaultTabController(
      length: 2,
      child: Material(
        child: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: <Widget>[
            _NavigatorContainer(),
            PlayController(),
          ],
        ),
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
      body: Column(
        children: <Widget>[
          _HomeTopBar(),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.only(bottom: 48 + MediaQuery.of(context).padding.bottom),
              child: _HomeTabs(),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeTopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
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
                      width: 140,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: TabBar(
                        labelPadding: EdgeInsets.zero,
                        labelColor: AppColors.text_accent,
                        unselectedLabelColor: AppColors.text_title,
                        labelStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        indicatorSize: TabBarIndicatorSize.label,
                        indicatorWeight: 3,
                        tabs: stringsOf(context).mainTabTitles.map((e) => Tab(text: e)).toList(),
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
                          onPressed: () => AppNavigator.instance.navigateTo(context, AppNavigator.setting, overlay: true),
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
    return ExtendedTabBarView(linkWithAncestor: true, children: [
      HomeMySongList(),
      HomeHotPlaylist(),
    ]);
  }
}
