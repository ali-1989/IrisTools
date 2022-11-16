import 'package:flutter/widgets.dart';

class MaxWidth extends StatelessWidget{
  final Widget child;
  final double maxWidth;
  final double? widthFactor;
  final double? heightFactor;
  final AlignmentGeometry alignment;

  MaxWidth({
    Key? key,
    required this.maxWidth,
    required this.child,
    this.alignment = Alignment.topCenter,
    this.widthFactor,
    this.heightFactor,
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      widthFactor: widthFactor,
      heightFactor: heightFactor,
      child: ConstrainedBox(
        constraints: BoxConstraints.loose(Size(maxWidth, double.infinity)),
        child: child,
      ),
    );
  }
}