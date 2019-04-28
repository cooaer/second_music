class Json {
  static int getInt(Map<String, dynamic> json, String key, {int defaultValue = 0}) {
    if (json == null) return defaultValue;
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

  static double getDouble(Map<String, dynamic> json, String key, {double defaultValue = 0}) {
    if (json == null) return defaultValue;
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

  static String getString(Map<String, dynamic> json, String key, {String defaultValue = ''}) {
    if (json == null) return defaultValue;
    var value = json[key];
    if (value != null) {
      return value.toString();
    }
    return defaultValue;
  }

  static bool getBool(Map<String, dynamic> json, String key, {bool defaultValue = false}) {
    if (json == null) return defaultValue;
    var value = json[key];
    if (value is bool) {
      return value;
    }
    if (value is String) {
      return bool.fromEnvironment(value);
    }
    return defaultValue;
  }

  static Map getMap(Map<String, dynamic> json, String key) {
    if (json == null) return null;
    var value = json[key];
    return value is Map ? value : null;
  }

  static List getList(Map<String, dynamic> json, String key) {
    if (json == null) return null;
    var value = json[key];
    return value is List ? value : null;
  }

  static T getObject<T>(Map<String, dynamic> json, String key) {
    if (json == null) return null;
    var value = json[key];
    return value is T ? value : null;
  }
}
