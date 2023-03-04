import 'package:flutter/widgets.dart';

class MaxWidth extends StatelessWidget{
  final Widget child;
  final double minWidth;
  final double? widthFactor;
  final double? heightFactor;
  final bool apply;
  final AlignmentGeometry alignment;

  MaxWidth({
    Key? key,
    required this.minWidth,
    required this.child,
    this.apply = true,
    this.alignment = Alignment.topCenter,
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
        constraints: BoxConstraints(minWidth: minWidth),
        child: child,
      ),
    );
  }
}
