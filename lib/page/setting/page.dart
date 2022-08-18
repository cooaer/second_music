import 'package:flutter/material.dart';
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
        ),
        body: _buildExample(context));
  }

  Widget _buildExample(BuildContext context) {
    return Container();
  }
}
