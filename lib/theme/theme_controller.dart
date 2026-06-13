import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/catppuccin.dart';

const _prefsKey = 'catppuccin_flavor';

/// Global theme controller. Listen to this with ListenableBuilder
/// or AnimatedBuilder anywhere you need the current theme.
class ThemeController extends ValueNotifier<CatppuccinFlavor> {
  ThemeController() : super(CatppuccinFlavor.mocha) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved != null) {
      value = CatppuccinFlavor.values.firstWhere(
        (f) => f.name == saved,
        orElse: () => CatppuccinFlavor.mocha,
      );
    }
  }

  Future<void> setFlavor(CatppuccinFlavor flavor) async {
    value = flavor;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, flavor.name);
  }

  ThemeData get themeData => buildCatppuccinTheme(value);
}

/// Single global instance - import this wherever needed
final themeController = ThemeController();