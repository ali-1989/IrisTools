import 'package:flutter/widgets.dart';

class MaxWidth extends StatelessWidget{
  final Widget child;
  final double maxWidth;
  final double? widthFactor;
  final double? heightFactor;
  final bool apply;
  final AlignmentGeometry alignment;

  MaxWidth({
    Key? key,
    required this.maxWidth,
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
        constraints: BoxConstraints.loose(Size(maxWidth, double.infinity)),
        child: child,
      ),
    );
  }
}


/*
import 'package:flutter/sticky.dart';

class MaxWidth extends StatefulWidget{
  final Widget child;
  final double maxWidth;
  final double? widthFactor;
  final double? heightFactor;
  final bool apply;
  final AlignmentGeometry alignment;

  MaxWidth({
    Key? key,
    required this.maxWidth,
    required this.child,
    this.apply = true,
    this.alignment = Alignment.topCenter,
    this.widthFactor,
    this.heightFactor,
  }): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MaxWidthState();
  }
}
///==================================================================================================================
class MaxWidthState extends State<MaxWidth>{

  @override
  Widget build(BuildContext context) {
    if(widget.apply){
      return widget.child;
    }

    return Align(
      alignment: widget.alignment,
      widthFactor: widget.widthFactor,
      heightFactor: widget.heightFactor,
      child: ConstrainedBox(
        constraints: BoxConstraints.loose(Size(widget.maxWidth, double.infinity)),
        child: widget.child,
      ),
    );
  }
}
 */