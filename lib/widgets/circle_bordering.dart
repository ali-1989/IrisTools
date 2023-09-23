import 'package:flutter/material.dart';

class CircleBordering extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final double width;
  final EdgeInsets padding;

  const CircleBordering({
    required this.child,
    required this.borderColor,
    required this.width,
    this.padding = const EdgeInsets.all(3),
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: width),
        ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
