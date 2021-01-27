import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';
import 'package:second_music/res/res.dart';
import 'package:second_music/widget/infinite_page_view.dart';

class SettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var items = [0xffff0000, 0xff00ff00, 0xff0000ff];
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: AppColors.text_title,
        ),
        title: Text(
          stringsOf(context).setting,
          style: TextStyle(color: AppColors.text_title, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      body: InfinitePageView<int>(
        items,
        PageController(initialPage: 1),
        (BuildContext context, int index, int realIndex) {
          return Container(
            color: Color(items[realIndex]),
            alignment: Alignment.center,
            child: Text(
              "$index\n$realIndex",
              style: TextStyle(
                color: Colors.white,
                fontSize: 100
              )
            ),
          );
        },
      ),
    );
  }

  Widget _buildExample(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: AppColors.text_title,
        ),
        title: Text(
          stringsOf(context).setting,
          style: TextStyle(color: AppColors.text_title, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      body: PreferencePage([
        PreferenceTitle('General'),
        DropdownPreference(
          'Start Page',
          'start_page',
          defaultVal: 'Timeline',
          values: ['Posts', 'Timeline', 'Private Messages'],
        ),
        PreferenceTitle('Personalization'),
        RadioPreference(
          'Light Theme',
          'light',
          'ui_theme',
          isDefault: true,
        ),
        RadioPreference(
          'Dark Theme',
          'dark',
          'ui_theme',
        ),
      ]),
    );
  }
}
