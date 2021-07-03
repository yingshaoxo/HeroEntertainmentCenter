import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

class MyStore {
  static late SharedPreferences preferences;

  static Future<void> init_preferences() async {
    MyStore.preferences = await SharedPreferences.getInstance();
  }

  static String? getString(String key) {
    try {
      return MyStore.preferences.getString(key);
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  static Future<bool> setString(String key, String value) async {
    try {
      await MyStore.preferences.setString(key, value);
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }
}
