import 'dart:convert';

import 'package:PureBook/common/LoadDialog.dart';
import 'package:PureBook/common/util.dart';
import 'package:PureBook/common/common.dart';
import 'package:PureBook/event/event.dart';
import 'package:PureBook/view/Forgetpass.dart';
import 'package:PureBook/view/Register.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';

class PersonCenter extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _PersonCenter();
  }
}

class _PersonCenter extends State<PersonCenter>
    with AutomaticKeepAliveClientMixin {
  String username = '';
  static GlobalKey<ScaffoldState> _globalKey = new GlobalKey();
  bool isLogin = false;
  String pwd;

  @override
  void initState() {
//    requestPermission();
    // TODO: implement initState
    if (SpUtil.haveKey('login')) {
      isLogin = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 48.0,
        child: Image.asset('images/logo.png'),
      ),
    );

    final email = TextFormField(

      autofocus: false,
      initialValue: username,
      decoration: InputDecoration(
        hintText: '账号',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
      onChanged: (String value) {
        this.username = value;
      },
    );

    final password = TextFormField(
      autofocus: false,
      obscureText: true,
      decoration: InputDecoration(
        hintText: '密码',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
      onChanged: (String value) {
        print(value);
        this.pwd = value;
      },
    );

    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () {
          login();
//          Navigator.of(context).pushNamed(HomePage.tag);
        },
        padding: EdgeInsets.all(12),
        color: Colors.grey,
        child: Text('登陆', style: TextStyle(color: Colors.white)),
      ),
    );
    final alucard = Hero(
      tag: 'hero',
      child: Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: CircleAvatar(
          radius: 72.0,
          backgroundColor: Colors.transparent,
          backgroundImage: AssetImage('images/alucard.jpg'),
        ),
      ),
    );

    final welcome = Padding(
      padding: EdgeInsets.all(2.0),
      child: Text(
        '$username',
        style: TextStyle(fontSize: 28.0, color: Colors.black),
      ),
    );

    final lorem = Padding(
      padding: EdgeInsets.only(top: 2.0),
      child: Text(
        '世人为荣利缠缚，动曰尘世苦海，不知云白山青，川行石立，花迎鸟笑，谷笑樵讴，世亦不尘、海亦不苦、彼自尘苦其心尔。',
        style: TextStyle(fontSize: 16.0, color: Colors.black),
      ),
    );
    final unmount = Padding(
      padding: EdgeInsets.all(8.0),
      child: new FlatButton(
        highlightColor: Colors.grey,
          onPressed: () {
            SpUtil.remove('pwd');
            SpUtil.remove('username');
            SpUtil.remove('login');
            setState(() {
              isLogin = false;
            });
            eventBus.fire(new BooksEvent([]));

            SpUtil.remove(Common.listbookname);
          },
          child: new Text('注销账户',
              style: TextStyle(fontSize: 16.0, color: Colors.black))),
    );
    final forgotLabel = FlatButton(
      child: Text(
        '忘记密码?',
        style: TextStyle(color: Colors.black54),
      ),
      onPressed: () {  Navigator.of(context).push(new MaterialPageRoute(
          builder: (BuildContext context) => new ForgetPass()));},
    );
    final loginUpLabel = FlatButton(
      child: Text(
        '注册',
        style: TextStyle(color: Colors.black54),
      ),
      onPressed: () {
        Navigator.of(context).push(new MaterialPageRoute(
            builder: (BuildContext context) => new Register()));
      },
    );
    final loginBody = Center(
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.only(left: 24.0, right: 24.0),
        children: <Widget>[
          logo,
          SizedBox(height: 48.0),
          email,
          SizedBox(height: 8.0),
          password,
          loginButton,
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              forgotLabel,
              loginUpLabel,
            ],
          ),
        ],
      ),
    );
    final personbody = Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(left: 28.0, right: 28.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          Colors.white70,
          Colors.white70,

        ]),
      ),
      child: Column(
        children: <Widget>[ welcome,Divider(), lorem,unmount],
      ),
    );

    return Scaffold(
      key: _globalKey,
      backgroundColor: Colors.white,
      body: !isLogin ? loginBody : personbody,
    );
  }

  login() async {
    FormData formData = new FormData.fromMap({
      "password": pwd,
      "username": username,
      "usecookie": 525600,
      "action": "login",
      "submit": "提 交"
    });

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new LoadingDialog(
            text: "登陆中…",
          );
        });
    Response response;
    try {
      response = await Util.dio.post(Common.login, data: formData);
    } catch (e) {

      _globalKey.currentState.showSnackBar(new SnackBar(content: new Text('登陆异常,请重试...')));
    }
    Navigator.pop(context);
    Util.dio.interceptors.add(CookieManager(new CookieJar()));
    var data = jsonDecode(response.data)['data'];
    if (data['Status'] != 1) {
      _globalKey.currentState.showSnackBar(new SnackBar(content: new Text(data['Message'])));

    } else {
      SpUtil.putString('username', username);
      SpUtil.putString('pwd', pwd);
      SpUtil.putBool('login', true);
      //书架同步
      eventBus.fire(new SyncShelfEvent(''));
      setState(() {
        isLogin = true;
      });
    }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
