
import 'dart:ui';

import 'package:flutter/material.dart';

enum DashOffsetType {absolute, percentage}
typedef PathBuilder = Path Function(Size size);
///=============================================================================
class Paths {
  Paths._();

  static Path buildSquareFatLegs(Size size, double radius){
    final p = Path();

    final pa = radius;
    final start = size.topLeft(Offset(pa, pa));

    p.moveTo(start.dx, start.dy);

    final leftOff1 = Offset(0, size.height/2);
    final leftOff2 = Offset(start.dx, size.height - pa);

    p.quadraticBezierTo(leftOff1.dx, leftOff1.dy, leftOff2.dx, leftOff2.dy);

    final bottomOff1 = Offset(size.width/2, size.height);
    final bottomOff2 = Offset(size.width - pa, leftOff2.dy);

    p.quadraticBezierTo(bottomOff1.dx, bottomOff1.dy, bottomOff2.dx, bottomOff2.dy);

    final rightOff1 = Offset(size.width, leftOff1.dy);
    final rightOff2 = Offset(bottomOff2.dx, pa);

    p.quadraticBezierTo(rightOff1.dx, rightOff1.dy, rightOff2.dx, rightOff2.dy);

    final topOff1 = Offset(bottomOff1.dx, 0);
    //final topOff2 = Offset(start.dx, size.height);

    p.quadraticBezierTo(topOff1.dx, topOff1.dy, start.dx, start.dy);

    return p;
  }

  static Path buildSquareFatSide(Size size, double radius){
    final path = Path();

    final pa = radius;
    path.moveTo(size.width, size.height / 2);

    path.cubicTo(size.width, size.height,
        size.width - pa, size.height,
        size.width /2, size.height);

    path.cubicTo( pa, size.height,
        0, size.height,
        0, size.height / 2);

    path.cubicTo(0, 0,
        pa , 0,
        size.width /2, 0);

    path.cubicTo(size.width - pa, 0,
        size.width , 0,
        size.width, size.height / 2);

    return path;
  }

  static Path buildSquareFatSideCorner(Size size, double radius, double corner){
    final path = Path();
    final pa = radius;

    path.moveTo(size.width, size.height / 2);

    path.cubicTo(size.width, size.height -corner,
        size.width - pa, size.height,
        size.width /2, size.height);

    path.cubicTo( pa, size.height,
        0, size.height -corner,
        0, size.height / 2);

    path.cubicTo(0, corner,
        pa , 0,
        size.width /2, 0);

    path.cubicTo(size.width - corner, 0,
        size.width , pa,
        size.width, size.height / 2);

    return path;
  }

  static Path buildDashPath(Path source, {required CircularIntervalList<double> dashArray, DashOffset? dashOffset}) {
    dashOffset = dashOffset ?? const DashOffset.absolute(0.0);

    final Path dest = Path();

    for (final PathMetric metric in source.computeMetrics()) {
      double distance = dashOffset._calculate(metric.length);
      bool draw = true;

      while (distance < metric.length) {
        final double len = dashArray.next;

        if (draw) {
          dest.addPath(metric.extractPath(distance, distance + len), Offset.zero);
        }

        distance += len;
        draw = !draw;
      }
    }

    return dest;
  }
}
///=============================================================================
class PathClipper extends CustomClipper<Path> {
  final PathBuilder builder;
  bool reBuild = true;

  PathClipper({required this.builder, this.reBuild = true});

  @override
  Path getClip(Size size) {
    return builder.call(size);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return reBuild;
  }

}
///=============================================================================
class DashOffset {
  DashOffset.percentage(double percentage): _rawVal = percentage.clamp(0.0, 1.0),
        _dashOffsetType = DashOffsetType.percentage;

  const DashOffset.absolute(double start) : _rawVal = start,
        _dashOffsetType = DashOffsetType.absolute;

  final double _rawVal;
  final DashOffsetType _dashOffsetType;

  double _calculate(double length) {
    return _dashOffsetType == DashOffsetType.absolute
        ? _rawVal
        : length * _rawVal;
  }
}
///=============================================================================
class CircularIntervalList<T> {
  final List<T> _valueList;
  int _idx = 0;

  CircularIntervalList(this._valueList);

  T get next {
    if (_idx >= _valueList.length) {
      _idx = 0;
    }

    return _valueList[_idx++];
  }
}