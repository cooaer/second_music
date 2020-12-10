class Json {
  static int getInt(Map<String, dynamic> json, String key,
      {int defaultValue = 0}) {
    dynamic value = json[key];
    if (value is int) {
      return value;
    }
    if (value is String) {
      try {
        return int.parse(value);
      } on TypeError catch (e) {
        print(e);
      }
    }
    return defaultValue;
  }

  static double getDouble(Map<String, dynamic> json, String key,
      {double defaultValue = 0}) {
    dynamic value = json[key];
    if (value is double) {
      return value;
    }
    if (value is String) {
      try {
        return double.parse(value);
      } on TypeError catch (e) {
        print(e);
      }
    }
    return defaultValue;
  }

  static String getString(Map<String, dynamic> json, String key,
      {String defaultValue = ''}) {
    var value = json[key];
    if (value != null) {
      return value.toString();
    }
    return defaultValue;
  }

  static bool getBool(Map<String, dynamic> json, String key,
      {bool defaultValue = false}) {
    var value = json[key];
    if (value is bool) {
      return value;
    }
    if (value is String) {
      return bool.fromEnvironment(value);
    }
    return defaultValue;
  }

  static Map<String, dynamic> getMap(Map<String, dynamic> json, String key) {
    var value = json[key];
    return value is Map<String, dynamic> ? value : {};
  }

  static List getList(Map<String, dynamic> json, String key) {
    var value = json[key];
    return value is List ? value : List.empty();
  }

  static T? getObject<T>(Map<String, dynamic> json, String key) {
    var value = json[key];
    return value is T ? value : null;
  }
}

extension JsonUtils on Map<String, dynamic> {
  int getInt(String key, {int defaultValue = 0}) {
    return Json.getInt(this, key, defaultValue: defaultValue);
  }

  double getDouble(String key, {double defaultValue = 0}) {
    return Json.getDouble(this, key, defaultValue: defaultValue);
  }

  String getString(String key, {String defaultValue = ""}) {
    return Json.getString(this, key, defaultValue: defaultValue);
  }

  bool getBool(String key, {bool defaultValue = false}) {
    return Json.getBool(this, key, defaultValue: defaultValue);
  }

  Map getMap(String key) {
    return Json.getMap(this, key);
  }

  List getList(String key) {
    return Json.getList(this, key);
  }

  T getObject<T>(String key) {
    return Json.getObject(this, key);
  }
}
