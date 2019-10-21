import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';

class AppThemeModel with ChangeNotifier {
  ThemeData _themeData = getBrighness();

  ThemeData getThemeData() => _themeData;

  static getBrighness() {
    if (SpUtil.haveKey('theme')) {
      if (SpUtil.getBool('theme')) {
        return ThemeData(
          brightness: Brightness.light,
        );
      } else {
        return ThemeData(
          brightness: Brightness.dark,
        );
      }
    } else {
      return ThemeData(
        brightness: Brightness.light,
      );
    }
  }

  set themeData(ThemeData value) {
    _themeData = value;
    notifyListeners();
  }

  setModel(bool f) {
    _themeData = ThemeData(
      brightness: !f ? Brightness.light : Brightness.dark,
      unselectedWidgetColor: !f ? Colors.white : Colors.black12,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    SpUtil.putBool('theme', _themeData.brightness==Brightness.light);
  }
}
