import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const _key = "theme_mode";

  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(
    ThemeMode.system,
  );

  static ThemeMode get theme => themeNotifier.value;

  static Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    final value = prefs.getString(_key);

    switch (value) {
      case "light":
        themeNotifier.value = ThemeMode.light;
        break;

      case "dark":
        themeNotifier.value = ThemeMode.dark;
        break;

      default:
        themeNotifier.value = ThemeMode.system;
    }
  }

  static Future<void> changeTheme(ThemeMode mode) async {
    themeNotifier.value = mode;

    final prefs = await SharedPreferences.getInstance();

    switch (mode) {
      case ThemeMode.light:
        await prefs.setString(_key, "light");
        break;

      case ThemeMode.dark:
        await prefs.setString(_key, "dark");
        break;

      case ThemeMode.system:
        await prefs.setString(_key, "system");
        break;
    }
  }
}
