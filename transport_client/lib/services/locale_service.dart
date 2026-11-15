import 'package:shared_preferences/shared_preferences.dart';

class LocaleService {
  static const _key = 'app_locale';

  static Future<void> saveLocale(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, code);
  }

  static Future<String?> getSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }
}