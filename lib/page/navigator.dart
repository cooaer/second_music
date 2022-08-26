import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:second_music/entity/enum.dart';
import 'package:second_music/page/home/page.dart';
import 'package:second_music/page/play/play_page.dart';
import 'package:second_music/page/search/more/more.dart';
import 'package:second_music/page/search/search_view.dart';
import 'package:second_music/page/setting/page.dart';
import 'package:second_music/page/singer/singer_view.dart';
import 'package:second_music/page/song_list/page.dart';
import 'package:second_music/page/ui_style.dart';
import 'package:second_music/page/web_view/page.dart';

import '../entity/singer.dart';

var navigatorKey = GlobalKey();

class AppNavigator {
  static const home = '/';
  static const search = '/search';
  static const song_list = '/song_list';
  static const play = '/play';
  static const web_view = '/web_view';
  static const setting = '/setting';
  static const singer = '/singer';
  static const search_more = '/search_more';

  static AppNavigator? _instance;

  factory AppNavigator() => _instance ?? (_instance = AppNavigator._());

  AppNavigator._();

  Future navigateTo(BuildContext context, String name,
      {Map<String, dynamic>? params,
      bool clearTask = false,
      bool replace = false,
      bool overlay = false}) async {
    PageRoute route = buildRoute(context, name, params);
    NavigatorState state = await of(context, rootNavigator: overlay);

    Future future;
    if (clearTask) {
      future = state.pushAndRemoveUntil(route, (route) => false);
    } else if (replace) {
      future = state.pushReplacement(route);
    } else {
      future = state.push(route);
    }
    return future;
  }

  Future<NavigatorState> of(BuildContext context,
      {bool rootNavigator = false}) async {
    final rootNavigatorState =
        Navigator.of(context, rootNavigator: rootNavigator);
    if (rootNavigator) {
      return rootNavigatorState;
    }
    final miniPlayerNavigatorState =
        navigatorKey.currentState as NavigatorState;
    if (rootNavigatorState != miniPlayerNavigatorState) {
      rootNavigatorState.pop();
      await Future.delayed(Duration(milliseconds: 200));
    }
    return miniPlayerNavigatorState;
  }

  Future<void> pop(BuildContext context) async {
    (await of(context)).pop();
  }

  Widget matchPage(String name, {Map<String, dynamic>? params}) {
    switch (name) {
      case home:
        return buildHome(params: params);
      case search:
        return buildSearch(params: params);
      case song_list:
        return buildSongList(params: params);
      case play:
        return buildPlay(params: params);
      case web_view:
        return buildWebView(params: params);
      case setting:
        return buildSetting(params: params);
      case singer:
        return buildSinger(params: params);
      case search_more:
        return buildSearchMore(params: params);
      default:
        debugPrint("Error: invalid route name $name");
        return buildHome(params: params);
    }
  }

  PageRoute buildRoute(
      BuildContext context, String name, Map<String, dynamic>? params) {
    var page = matchPage(name, params: params);
    switch (name) {
      case search:
        return PageRouteBuilder(
            transitionDuration: Duration(milliseconds: 300),
            pageBuilder: (context, anim, secondAnim) {
              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: darkIconUiStyle,
                child: page,
              );
            },
            transitionsBuilder: (context, anim, anim2, child) {
              return FadeTransition(
                opacity: anim,
                child: child,
              );
            });
      default:
        return MaterialPageRoute(
            builder: (context) => AnnotatedRegion<SystemUiOverlayStyle>(
                  value: lightIconStatusBar(name)
                      ? lightIconUiStyle
                      : darkIconUiStyle,
                  child: page,
                ));
    }
  }

  bool lightIconStatusBar(String name) {
    switch (name) {
      case song_list:
      case play:
        return true;
    }
    return false;
  }

  Widget buildHome({Map<String, dynamic>? params}) {
    return HomePage();
  }

  Widget buildSearch({Map<String, dynamic>? params}) {
    return SearchPage();
  }

  Widget buildSongList({Map<String, dynamic>? params}) {
    return SongListPage(
        params?["plt"], params?['songListId'], params?['songListType']);
  }

  Widget buildPlay({Map<String, dynamic>? params}) {
    return PlayPage(params?['index'], params?['song']);
  }

  Widget buildWebView({Map<String, dynamic>? params}) {
    return WebViewPage(params?['url']);
  }

  Widget buildSetting({Map<String, dynamic>? params}) {
    return SettingPage();
  }

  Widget buildSinger({Map<String, dynamic>? params}) {
    MusicPlatform? plt = params?['plt'];
    String? singerId = params?['singerId'];
    Singer? singer = params?['singer'];
    return SingerPage(
      plt ?? (singer?.plt)!,
      singerId ?? (singer?.pltId)!,
      singer: singer,
    );
  }

  Widget buildSearchMore({Map<String, dynamic>? params}) {
    final plt = params?['plt'];
    final type = params?['type'];
    final keyword = params?['keyword'];
    return SearchMorePage(plt, type, keyword);
  }
}
