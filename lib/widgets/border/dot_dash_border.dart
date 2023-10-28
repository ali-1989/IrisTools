import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:iris_tools/widgets/path/paths.dart';

part 'dash_painter.dart';


enum BorderType {
  circle,
  rRect,
  rect,
  oval
}
///=============================================================================
class DotDashBorder extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double strokeWidth;
  final Color color;
  final List<double> dashPattern;
  final BorderType borderType;
  final Radius radius;
  final StrokeCap strokeCap;
  final PathBuilder? customPath;

  DotDashBorder({
    super.key,
    required this.child,
    this.color = Colors.black,
    this.strokeWidth = 1,
    this.borderType = BorderType.rect,
    this.dashPattern = const <double>[3, 1],
    this.padding = const EdgeInsets.all(2),
    this.radius = const Radius.circular(0),
    this.strokeCap = StrokeCap.butt,
    this.customPath,
  }) : super() {
    assert(_isValidDashPattern(dashPattern), 'Invalid dash pattern');
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DotDashPainter(
        strokeWidth: strokeWidth,
        radius: radius,
        color: color,
        borderType: borderType,
        dashPattern: dashPattern,
        customPath: customPath,
        strokeCap: strokeCap,
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }

  /*
    old build:
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: CustomPaint(
            painter: DotDashPainter(
              strokeWidth: strokeWidth,
              radius: radius,
              color: color,
              borderType: borderType,
              dashPattern: dashPattern,
              customPath: customPath,
              strokeCap: strokeCap,
            ),
          ),
        ),

        Padding(
          padding: padding,
          child: child,
        ),
      ],
    );
   */
  bool _isValidDashPattern(List<double>? dashPattern) {
    Set<double>? dashSet = dashPattern?.toSet();

    if (dashSet == null) {
      return false;
    }
    if (dashSet.length == 1 && dashSet.elementAt(0) == 0.0) {
      return false;
    }
    if (dashSet.isEmpty) {
      return false;
    }

    return true;
  }
}