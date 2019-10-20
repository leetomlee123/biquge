import 'dart:convert';

import 'package:PureBook/common/toast.dart';
import 'package:PureBook/entity/BookTag.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';

import 'LoadDialog.dart';

class Util {
  static Dio _dio;
  BuildContext _buildContext;

  Util(this._buildContext);

  Dio http() {
    _dio = new Dio();
    var dic = DirectoryUtil.getAppDocPath();

    var cookieJar = PersistCookieJar(dir: dic + "/.cookies/");
    _dio.interceptors.add(CookieManager(cookieJar));

    _dio.interceptors
        .add(InterceptorsWrapper(onRequest: (RequestOptions options) async {
      // Do something before request is sent
      if (_buildContext != null) {
//        showDialog(
//            context: _buildContext,
//            barrierDismissible: false,
//            builder: (BuildContext context) {
//              return LoadingDialog();
//            });
        showGeneralDialog(
          context: _buildContext,
          barrierLabel: "",
          barrierDismissible: true,
          transitionDuration: Duration(milliseconds: 300),
          pageBuilder: (BuildContext context, Animation animation,
              Animation secondaryAnimation) {
            return LoadingDialog();
          },
        );
      }
      return options; //continue
      // If you want to resolve the request with some custom data，
      // you can return a `Response` object or return `dio.resolve(data)`.
      // If you want to reject the request with a error message,
      // you can return a `DioError` object or return `dio.reject(errMsg)`
    }, onResponse: (Response response) async {
      // Do something with response data
      if (_buildContext != null) {
        Navigator.pop(_buildContext);
      }
      return response; // continue
    }, onError: (DioError e) async {
      // Do something with response error
      if (e.type == DioErrorType.CONNECT_TIMEOUT) {
        Navigator.pop(_buildContext);
        Toast.show('服务器响应超时,请重试');
      } else {
        if (_buildContext != null) {
          Navigator.pop(_buildContext);
          Toast.show('发生了一些错误,请重试');
        }
      }
      return e; //continue
    }));
    return _dio;
  }
  //删除本地记录
void delLocalCache(List<String> ids){

    ids.forEach((f){
      BookTag _bookTag=BookTag.fromJson(jsonDecode(SpUtil.getString(f)));
      for(var value in _bookTag.chapters){
        SpUtil.remove(value.id.toString());
        SpUtil.remove('pages${value.id.toString()}');
      }
      SpUtil.remove(f);
    });
    Toast.show('退出登陆');
}
}
