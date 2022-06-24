import 'package:flutter/widgets.dart';

class MaxWidth extends StatefulWidget{
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
  State<StatefulWidget> createState() {
    return MaxWidthState();
  }
}
///===================================================================================================
class MaxWidthState extends State<MaxWidth>{

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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

  @override
  void dispose() {
    super.dispose();
  }
}
///===================================================================================================