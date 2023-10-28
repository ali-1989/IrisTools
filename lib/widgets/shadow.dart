import 'dart:math';

import 'package:flutter/material.dart';

class ShadowBox extends StatelessWidget {
  final Widget child;
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
///=============================================================================
class ShadowPath extends StatelessWidget {
  final Widget child;
  final CustomClipper<Path> clipper;
  final Color shadowColor;
  final double elevation;


  ShadowPath({
    super.key,
    this.shadowColor = const Color.fromARGB(220, 100, 100, 100),
    //this.offset = const Offset(0, 0),
    required this.child,
    required this.clipper,
    this.elevation = 5,
  }) : super();


  @override
  Widget build(BuildContext context) {
    return PhysicalShape(
      color: Colors.transparent,
      shadowColor: shadowColor,
      elevation: elevation,
      clipper: clipper,
      child: child,
    );
  }
}
///=============================================================================
typedef PathBuilder = Path Function(Size size);
typedef Painter = void Function(Canvas canvas, Size size);

class ShadowPainter extends CustomPainter {
  final PathBuilder pathBuilder;
  final Painter? painter;
  final Color shapeColor;
  final List<Shadow> shadows;

  ShadowPainter({required this.pathBuilder, this.painter, required this.shapeColor, required this.shadows});

  @override
  void paint(Canvas canvas, Size size) {
    final shape = pathBuilder.call(size);

    //canvas.clipRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height));

    for (final sh in shadows) {
      canvas.save();
      canvas.translate(sh.offset.dx, sh.offset.dy);
      canvas.drawShadow(shape, sh.color, sqrt(sh.blurRadius), false);
      canvas.restore();
    }

    //canvas.drawPath(shape, _paint);
    painter?.call(canvas, size);
  }

  @override
  bool shouldRepaint(covariant ShadowPainter oldDelegate) {
   return oldDelegate.shadows != shadows ||
    oldDelegate.shadows.length != shadows.length ||
    oldDelegate.shapeColor != shapeColor;
  }
}


/*

PhysicalShape(
    color: Colors.transparent,
    shadowColor: Colors.red,
    elevation: 5,
    clipper: PathClipper(
        builder: (siz){
          return Paths.buildSquareFatSide(siz,  20);
        }
    ),
    child: ClipPath(
      clipper: PathClipper(
          builder: (siz){
            return Paths.buildSquareFatSide(siz,  20);
          }
      ),
      child: const ColoredSpace(width: 63, height: 63),
    ),
  )
 */