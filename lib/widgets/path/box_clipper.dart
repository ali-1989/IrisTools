import 'package:flutter/material.dart';

class BoxClipper extends CustomClipper<Rect> {
  double? width;

  double? height;


  BoxClipper({this.width, this.height});

  @override
  Rect getClip(Size size) {
    //return Rect.fromLTWH(200, 0, width?? size.width, height?? size.height);
    return Rect.fromCenter(center: size.center(Offset.zero), width: width?? size.width, height: height?? size.height);
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) {
    return true;
  }

}