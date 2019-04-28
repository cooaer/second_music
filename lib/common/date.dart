import 'package:intl/intl.dart';

DateFormat dateTimeFormat = DateFormat('yyyy-MM-dd HH:MM:ss');

DateFormat dateFormat = DateFormat('yyyy-MM-dd');

DateTime dateTimeFromString(String str){
  return dateTimeFormat.parse(str);
}

String dateTimeToString(DateTime dateTime){
  return dateTimeFormat.format(dateTime);
}