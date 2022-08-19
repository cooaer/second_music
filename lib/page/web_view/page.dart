import 'package:flutter/material.dart';
import 'package:second_music/res/res.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatelessWidget {
  final String url;

  WebViewPage(this.url);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: BackButton(
          color: AppColors.textTitle,
        ),
        title: Text(
          Uri.parse(url).host,
          style: TextStyle(
            fontSize: 18,
            color: AppColors.textTitle,
          ),
        ),
        backgroundColor: AppColors.mainBg,
        bottom: PreferredSize(
            child: Divider(
              height: 1,
            ),
            preferredSize: Size.fromHeight(1)),
      ),
      body: WebView(
        initialUrl: url,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
