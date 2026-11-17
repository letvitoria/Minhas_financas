import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  void toggle(Brightness currentBrightness) {
    final isCurrentlyDark = _themeMode == ThemeMode.system
        ? currentBrightness == Brightness.dark
        : _themeMode == ThemeMode.dark;
    _themeMode = isCurrentlyDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}
