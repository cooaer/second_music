import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences sharedPreferences;

Future initPreferences() async{
  sharedPreferences = await SharedPreferences.getInstance();
}