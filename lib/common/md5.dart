import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart' as crypto;

//Generate MD5 hash
String md5(String data) {
  var content = Utf8Encoder().convert(data);
  var digest = crypto.md5.convert(content);
  return hex.encode(digest.bytes);
}