

import 'package:PureBook/common/common.dart';
import 'package:PureBook/common/util.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flustars/flustars.dart';

class BookAction {
  static BookAction action = new BookAction();

 Future<VoidCallback> login() async {

    FormData formData = new FormData.fromMap({
      "password": SpUtil.getString('pwd'),
      "username": SpUtil.getString('username'),
      "usecookie": 525600,
      "action": "login",
      "submit": "提 交"
    });
    Util.dio.interceptors.add(CookieManager(new CookieJar()));

    await Util.dio.post(Common.login, data: formData);
  }
}
