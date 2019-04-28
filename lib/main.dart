import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:second_music/common/path.dart';
import 'package:second_music/page/home/page.dart';
import 'package:second_music/page/ui_style.dart';
import 'package:second_music/res/res.dart';
import 'package:second_music/storage/preference/basic.dart';

void main() async {
  await initApp();
  runApp(MyApp());
}

Future initApp() async {
  await initPreferences();

  await AppPath.instance.init();

  if(Platform.isAndroid){
    SystemChrome.setSystemUIOverlayStyle(darkIconUiStyle);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => stringsOf(context).appName,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: HomePage(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        AppLocalizationsDelegate()
      ],
      supportedLocales: [
        Locale('zh', 'CN'),
      ],
      locale: Locale('zh', 'CN'),
    );
  }
}
