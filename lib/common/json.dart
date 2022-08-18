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

extension MapJson on Map<String, dynamic> {
  T get<T>(String key, {required T defaultValue}) {
    return this[key] ?? defaultValue;
  }

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

  Map<String, dynamic> getMap(String key) {
    return Json.getMap(this, key);
  }

  List getList(String key) {
    return Json.getList(this, key);
  }

  T getObject<T>(String key) {
    return Json.getObject(this, key);
  }
}

extension ListJson on List<dynamic> {
  T get<T>(int index, {required T defaultValue}) {
    return index >= 0 && index < this.length ? this[index] : defaultValue;
  }

  Map<String, dynamic> getMap(int index,
      {Map<String, dynamic> defaultValue = const <String, dynamic>{}}) {
    return index >= 0 && index < this.length ? this[index] : defaultValue;
  }
}
