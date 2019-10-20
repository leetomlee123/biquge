import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingDialog extends Dialog {
  @override
  Widget build(BuildContext context) {
    //创建透明层
    return Center(
        child: Container(
          width: 150,
          height: 150,
          child: SpinKitCircle(
            color: Colors.blue,
            size: 50,
          ),
        ));
  }
}
