import 'package:flutter/widgets.dart';

class MinHeight extends StatelessWidget {
  final Widget child;
  final double minHeight;
  final double? widthFactor;
  final double? heightFactor;
  final bool apply;
  final AlignmentGeometry alignment;

  MinHeight({
    Key? key,
    required this.minHeight,
    required this.child,
    this.apply = true,
    this.alignment = Alignment.center,
    this.widthFactor,
    this.heightFactor,
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    if(!apply){
      return child;
    }

    return Align(
      alignment: alignment,
      widthFactor: widthFactor,
      heightFactor: heightFactor,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: child,
      ),
    );
  }
}
