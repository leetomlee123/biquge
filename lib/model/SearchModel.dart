import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';

class SearchModel with ChangeNotifier {
  List<String> _history = [];

String _query='';

  String get query => _query;

  setQuery(String value) {
    _query = value;
  }

  List<String> get history => _history;

   setHistory(List<String> value) {
    _history = value;
  }

  show() {
    _history = SpUtil.getStringList('history');
    notifyListeners();
  }

  clearHistory() {
    SpUtil.remove('history');
    _history = [];
    notifyListeners();
  }



  @override
  void dispose() {
    super.dispose();
    SpUtil.putStringList('history', _history);
  }
}
