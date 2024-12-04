import 'package:shared_preferences/shared_preferences.dart';

const String loginSessionKey = "Login-Session-Key";
class PreferencesUtils {
  /// Save a value (String)
  static Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
    print('String value saved for key: $key');
  }

  /// Retrieve a String value
  static Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(key);
    print('String value retrieved for key $key: $value');
    return value;
  }

  /// Save a value (Boolean)
  static Future<void> saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    print('Boolean value saved for key: $key');
  }

  /// Retrieve a Boolean value
  static Future<bool?> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getBool(key);
    print('Boolean value retrieved for key $key: $value');
    return value;
  }

  /// Save a value (Integer)
  static Future<void> saveInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
    print('Integer value saved for key: $key');
  }

  /// Retrieve an Integer value
  static Future<int?> getInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt(key);
    print('Integer value retrieved for key $key: $value');
    return value;
  }

  /// Delete a value
  static Future<void> deleteValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
    print('Value deleted for key: $key');
  }

  /// Clear all values
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('All preferences cleared.');
  }
}
