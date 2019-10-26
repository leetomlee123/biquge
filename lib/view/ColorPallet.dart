import 'package:flutter/material.dart';

class ColorPallet extends StatelessWidget {
   Color color;
   Function changeColor;

   bool isSelect;


  ColorPallet(this.color,this.isSelect,this.changeColor);

  void onPressed() {
    changeColor(color);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return RawMaterialButton(
      onPressed: onPressed,
      constraints: BoxConstraints(minWidth: 60.0, minHeight: 50.0),
      child: Container(
        margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
        width: 40.0,
        height: 40.0,
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
            border:
                Border.all(color: Colors.white, width: isSelect ? 3.0 : 0.0)),
      ),
    );
  }
}
