import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:second_music/network/cookie.dart';
import 'package:second_music/res/res.dart';

class WebViewPage extends StatelessWidget {
  final String url;

  WebViewPage(this.url);

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      url: url,
      appBar: AppBar(
        centerTitle: true,
        leading: BackButton(
          color: AppColors.text_title,
        ),
        title: Text(
          Uri.parse(url).host,
          style: TextStyle(
            fontSize: 18,
            color: AppColors.text_title,
          ),
        ),
        backgroundColor: AppColors.main_bg,
        brightness: Brightness.light,
        bottom: PreferredSize(
            child: Divider(
              height: 1,
            ),
            preferredSize: Size.fromHeight(1)),
      ),
      withZoom: true,
      withJavascript: true,
      withLocalStorage: true,
      hidden: true,
      initialChild: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
      headers: {'cookie': cookieJar.loadForRequest(Uri.parse(url)).join(';')},
    );
  }
}
