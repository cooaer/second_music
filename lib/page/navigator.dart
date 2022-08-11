import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:second_music/page/home/page.dart';
import 'package:second_music/page/play/play_page.dart';
import 'package:second_music/page/search/page.dart';
import 'package:second_music/page/setting/page.dart';
import 'package:second_music/page/song_list/page.dart';
import 'package:second_music/page/ui_style.dart';
import 'package:second_music/page/web_view/page.dart';

var navigatorKey = GlobalKey();

class AppNavigator {
  static const home = '/';
  static const search = '/search';
  static const song_list = '/song_list';
  static const play = '/play';
  static const web_view = '/web_view';
  static const setting = '/setting';

  static AppNavigator? _instance;

  static AppNavigator get instance {
    if (_instance == null) {
      _instance = AppNavigator._();
    }
    return _instance!;
  }

  AppNavigator._();

  Future navigateTo(BuildContext context, String name,
      {Map<String, dynamic>? params,
      bool clearTask = false,
      bool replace = false,
      bool overlay = false}) {
    PageRoute route = buildRoute(context, name, params);
    NavigatorState state = of(context, rootNavigator: overlay);
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

  NavigatorState of(BuildContext context, {bool rootNavigator = false}) {
    if (rootNavigator) {
      return Navigator.of(context, rootNavigator: true);
    }
    return navigatorKey.currentState as NavigatorState;
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
}
