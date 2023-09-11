import 'package:flutter/material.dart';

class CircularIcon extends StatelessWidget {
  final Color? color;
  final Color? bgColor;
  final IconData? icon;
  final double size;
  final double padding;

  const CircularIcon({
    Key? key,
    Color? itemColor,
    Color? backColor,
    this.icon,
    this.size = 24.0, //flutter standard
    this.padding = 5,
  }) :
        bgColor = backColor?? Colors.orange,
        color = itemColor?? Colors.white,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.all(Radius.circular(size)),
      ),
      child: Center(
        child: icon == null
            ? EmptyIcon()
            : Icon(icon,
                size: size - padding,
                color: color,
            ),
      ),
    );
  }
}
///-----------------------------------------------------------------------------------------------------
class EmptyIcon extends Icon {
  const EmptyIcon({Key? key}) : super(Icons.hourglass_empty, key: key,);

  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}