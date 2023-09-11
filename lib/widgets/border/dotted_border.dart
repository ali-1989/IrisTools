import 'package:flutter/material.dart';
import 'package:iris_tools/widgets/path/dash_path.dart';

part 'dashPainter.dart';


enum BorderType {
  circle,
  rRect,
  rect,
  oval
}
///=====================================================================================================
class DottedBorder extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double strokeWidth;
  final Color color;
  final List<double> dashPattern;
  final BorderType borderType;
  final Radius radius;
  final StrokeCap strokeCap;
  final PathBuilder? customPath;

  DottedBorder({Key? key,
    required this.child,
    this.color = Colors.black,
    this.strokeWidth = 1,
    this.borderType = BorderType.rect,
    this.dashPattern = const <double>[3, 1],
    this.padding = const EdgeInsets.all(2),
    this.radius = const Radius.circular(0),
    this.strokeCap = StrokeCap.butt,
    this.customPath,
  }) : super(key: key) {
    assert(_isValidDashPattern(dashPattern), 'Invalid dash pattern');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: CustomPaint(
            painter: _DashPainter(
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
  }

  bool _isValidDashPattern(List<double>? dashPattern) {
    Set<double>? _dashSet = dashPattern?.toSet();

    if (_dashSet == null) {
      return false;
    }
    if (_dashSet.length == 1 && _dashSet.elementAt(0) == 0.0) {
      return false;
    }
    if (_dashSet.isEmpty) {
      return false;
    }

    return true;
  }
}