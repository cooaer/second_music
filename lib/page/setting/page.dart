import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';
import 'package:second_music/res/res.dart';

class SettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
