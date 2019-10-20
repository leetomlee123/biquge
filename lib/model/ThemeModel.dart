import 'package:flutter/material.dart';

class AppThemeModel with ChangeNotifier {
  ThemeData _themeData = ThemeData(
    brightness: Brightness.light,

  );

  ThemeData getThemeData() => _themeData;

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
}
