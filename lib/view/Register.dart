import 'dart:convert';

import 'package:PureBook/common/common.dart';
import 'package:PureBook/common/util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _RegisterState();
  }
}

class _RegisterState extends State<Register> {
  String name;
  String pwd;
  String email;
  String repassword;
  var _scaffoldkey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          '账号注册',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      key: _scaffoldkey,
      body: new Container(
        alignment: Alignment.center,
        child: new ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            TextFormField(
              keyboardType: TextInputType.phone,
              autofocus: false,
              decoration: InputDecoration(
                hintText: '账号',
                contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
//                border: OutlineInputBorder(
//                    borderRadius: BorderRadius.circular(32.0)),
              ),
              onChanged: (String value) {
                this.name = value;
              },
            ),
            SizedBox(height: 8.0),
            TextFormField(
              autofocus: false,
              obscureText: true,
              decoration: InputDecoration(
                hintText: '密码',
                contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
//                border: OutlineInputBorder(
//                    borderRadius: BorderRadius.circular(32.0)),
              ),
              onChanged: (String value) {
                pwd = value;
              },
            ),
            SizedBox(height: 8.0),
            TextFormField(
              autofocus: false,
              obscureText: true,
              decoration: InputDecoration(
                hintText: '重复密码',
                contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
//                border: OutlineInputBorder(
//                    borderRadius: BorderRadius.circular(32.0)),
              ),
              onChanged: (String value) {
                repassword = value;
              },
            ),
            SizedBox(height: 8.0),
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              autofocus: false,
              decoration: InputDecoration(
                hintText: '邮箱 找回密码的唯一凭证,请谨慎输入...',
                contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
//                border: OutlineInputBorder(
//                    borderRadius: BorderRadius.circular(32.0)),
              ),
              onChanged: (String value) {
                email = value;
              },
            ),
            SizedBox(height: 8.0),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                onPressed: () {
                  register();
                },
                padding: EdgeInsets.all(12),
                color: Colors.grey,
                child: Text('注册', style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  register() async {
    if (pwd.isNotEmpty &&
        repassword.isNotEmpty &&
        name.isNotEmpty &&
        email.isNotEmpty) {
      FormData formData = new FormData.fromMap({
        "password": pwd,
        'repassword': repassword,
        "username": name,
        'email': email,
        "action": "newuser",
      });

      Response response;
      try {
        response = await Util(context)
            .http()
            .post(Common.domain + '/register.aspx', data: formData);
      } catch (e) {
        _scaffoldkey.currentState
            .showSnackBar(new SnackBar(content: new Text('注册异常,请重试...')));
      }

      var data = jsonDecode(response.data)['data'];
      if (data['Status'] != 1) {
        _scaffoldkey.currentState
            .showSnackBar(new SnackBar(content: new Text(data['Message'])));
      } else {
        Navigator.pop(context);
      }
    } else {
      _scaffoldkey.currentState
          .showSnackBar(new SnackBar(content: new Text('检查输入项不可为空')));
    }
  }
}
