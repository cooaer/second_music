import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:second_music/common/path.dart';
import 'package:second_music/page/home/page.dart';
import 'package:second_music/page/ui_style.dart';
import 'package:second_music/repository/local/preference/basic.dart';
import 'package:second_music/res/res.dart';

void main() async {
  await initApp();
  runApp(MyApp());
}

Future initApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initPreferences();

  await AppPath.instance.init();

  if (Platform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(darkIconUiStyle);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final flatButtonStyle = TextButton.styleFrom(
      primary: Colors.grey,
      minimumSize: Size.square(40),
    );

    return MaterialApp(
      onGenerateTitle: (context) => stringsOf(context).appName,
      theme: ThemeData(
        // useMaterial3: true,
        primarySwatch: Colors.red,
        textButtonTheme: TextButtonThemeData(style: flatButtonStyle),
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
