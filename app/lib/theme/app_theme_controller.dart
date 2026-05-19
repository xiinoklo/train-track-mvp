import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppThemeController {
  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  static Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('dark_mode') ?? false;

    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  static Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();

    final isCurrentlyDark = themeMode.value == ThemeMode.dark;
    final nextTheme = isCurrentlyDark ? ThemeMode.light : ThemeMode.dark;

    themeMode.value = nextTheme;
    await prefs.setBool('dark_mode', nextTheme == ThemeMode.dark);
  }
}