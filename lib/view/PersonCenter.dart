import 'dart:convert';

import 'package:PureBook/common/common.dart';
import 'package:PureBook/common/toast.dart';
import 'package:PureBook/common/util.dart';
import 'package:PureBook/entity/Book.dart';
import 'package:PureBook/event/event.dart';
import 'package:PureBook/model/ThemeModel.dart';
import 'package:PureBook/store/Store.dart';
import 'package:PureBook/view/Forgetpass.dart';
import 'package:PureBook/view/Register.dart';
import 'package:dio/dio.dart';
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
  @override
  Widget build(BuildContext context) {
    super.build(context);

    final personbody =
        ListView(padding: const EdgeInsets.only(), children: <Widget>[
      UserAccountsDrawerHeader(
//      margin: EdgeInsets.zero,
        accountName: Text(
          SpUtil.getString('username'),
        ),
        accountEmail: Text(
          SpUtil.haveKey('email') ? SpUtil.getString('email') : '点击头像登陆',
        ),
        currentAccountPicture: GestureDetector(
          child: CircleAvatar(
            backgroundImage: AssetImage("images/fu.png"),
          ),
          onTap: () {
            Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => Login()));
          },
        ),
      ),
      ClipRect(
        child: ListTile(
          leading: CircleAvatar(backgroundImage: AssetImage('images/${Store.value<AppThemeModel>(context).getThemeData().brightness == Brightness.light ? 'moon.png' : 'sun.png'}'),),

          title: Text(
              '${Store.value<AppThemeModel>(context).getThemeData().brightness == Brightness.light ? '夜间模式' : '日间模式'}'),
          onTap: () => {
            Store.value<AppThemeModel>(context).setModel(
                Store.value<AppThemeModel>(context).getThemeData().brightness ==
                    Brightness.light)
          },
        ),
      ),
      ListTile(
        leading: CircleAvatar(child: Text('Re'),),
        title: Text('免责声明'),
        onTap: () => {},
      ),
      AboutListTile(

        icon: CircleAvatar(child: Text('Ab'),),
        child: Text("关于"),
        applicationName: "清阅",
        aboutBoxChildren: <Widget>[
          Text('世人为荣利缠缚，动曰尘世苦海，不知云白山青，川行石立，花迎鸟笑，谷答樵讴，世亦不尘、海亦不苦、彼自尘苦其心尔')
        ],
      ),
      MaterialButton(
        child: Text('退出登录'),
        onPressed: () {
          SpUtil.remove('username');
          SpUtil.remove('login');
          SpUtil.remove('email');

          eventBus.fire(new BooksEvent([]));
          List books = jsonDecode(SpUtil.getString(Common.listbookname));
          Util(null).delLocalCache(
              books.map((f) => Book.fromJson(f).Id.toString()).toList());
          SpUtil.remove(Common.listbookname);
        },
      )
    ]);

    return Scaffold(
      body: personbody,
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class Login extends StatelessWidget {
  String username = '';
  bool isLogin = false;
  String pwd;

  @override
  Widget build(BuildContext context) {
    login() async {
      FormData formData = new FormData.fromMap({
        "password": pwd,
        "username": username,
        "usecookie": 43200,
        "action": "login",
      });

      Response response;
      try {
        response =
            await Util(context).http().post(Common.login, data: formData);
      } catch (e) {
        Toast.show('登陆异常,请重试...');
      }

      var data = jsonDecode(response.data)['data'];
      if (data['Status'] != 1) {
        Toast.show(data['Message']);
      } else {
        SpUtil.putString('email', data['UserInfo']['Email']);
        SpUtil.putString('username', username);
        SpUtil.putBool('login', true);
        //书架同步
        eventBus.fire(SyncShelfEvent(''));
        Navigator.pop(context);
      }
    }

    final logo = Hero(
      tag: 'God Group Ltcd',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 48.0,
        child: Image.asset('images/logo.png'),
      ),
    );

    final email = TextFormField(
      autofocus: false,
      decoration: InputDecoration(
        hintText: '账号',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
//        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
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
//        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
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

    final forgotLabel = FlatButton(
      child: Text(
        '忘记密码?',
        style: TextStyle(color: Colors.black54),
      ),
      onPressed: () {
        Navigator.of(context).push(new MaterialPageRoute(
            builder: (BuildContext context) => new ForgetPass()));
      },
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              forgotLabel,
              loginUpLabel,
            ],
          ),
        ],
      ),
    );
    // TODO: implement build

    return Material(
      child: loginBody,
    );
  }
}
