import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';

class ColorModel with ChangeNotifier {
   bool dark = SpUtil.getBool('dark');

  ThemeData themeData = SpUtil.getBool('dark') ? ThemeData.dark() : ThemeData.light();

  switchModel() {
    if (dark) {
      themeData = ThemeData.light();
    } else {
      themeData = ThemeData.dark();
    }
    dark = !dark;
    SpUtil.putBool("dark", dark);
    notifyListeners();
  }

}
