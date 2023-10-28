import 'dart:ui' show Path;

import 'package:iris_tools/widgets/path/path_parsing.dart';

Path parseSvgPathData(String svg) {
  if (svg == '') {
    return Path();
  }

  final SvgPathStringSource parser = SvgPathStringSource(svg);
  final FlutterPathProxy path = FlutterPathProxy();
  final SvgPathNormalizer normalizer = SvgPathNormalizer();

  for (PathSegmentData seg in parser.parseSegments()) {
    normalizer.emitSegment(seg, path);
  }

  return path.path;
}
///=============================================================================
class FlutterPathProxy extends PathProxy {
  FlutterPathProxy({Path? p}) : path = p ?? Path();

  final Path path;

  @override
  void close() {
    path.close();
  }

  @override
  void cubicTo(
      double x1, double y1, double x2, double y2, double x3, double y3) {
    path.cubicTo(x1, y1, x2, y2, x3, y3);
  }

  @override
  void lineTo(double x, double y) {
    path.lineTo(x, y);
  }

  @override
  void moveTo(double x, double y) {
    path.moveTo(x, y);
  }
}
