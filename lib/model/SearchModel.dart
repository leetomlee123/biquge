import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';

class SearchModel with ChangeNotifier {
  List<String> searchHistory = new List();




  setHistory(String value) {

    for (var ii = 0; ii < searchHistory.length; ii++) {
      if (searchHistory[ii] == value) {
        searchHistory.removeAt(ii);
      }
    }
    searchHistory.insert(0, value);

    SpUtil.putStringList('history', searchHistory);
  }

  getHistory() {
    if(SpUtil.haveKey('history')){
      searchHistory = SpUtil.getStringList('history');
    }
    return searchHistory;
  }

  clearHistory() {
    SpUtil.remove('history');
    searchHistory = [];
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();

    SpUtil.putStringList('history', searchHistory);
  }
}
