import 'package:flutter/material.dart';

class ShadowBox extends StatelessWidget {
  final Widget child;
  //final EdgeInsetsGeometry margin;
  //final EdgeInsetsGeometry padding;
  final double circular;
  final Color shadowColor;
  final double spreadRadius;
  final double blurRadius;
  final Offset offset;
  final Color backgroundColor;

  ShadowBox({
    Key? key,
    //this.margin = const EdgeInsets.all(0),
    //this.padding = const EdgeInsets.all(0),
    this.shadowColor = const Color.fromARGB(220, 100, 100, 100),
    this.backgroundColor = Colors.transparent,
    this.circular = 0,
    this.spreadRadius = 0,
    this.blurRadius = 0,
    this.offset = const Offset(0, 0),
    required this.child,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      //margin: margin,
      //padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(circular),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            spreadRadius: spreadRadius,
            blurRadius: blurRadius,
            offset: offset,
          ),
        ],
      ),
      child: child,
    );
  }
}