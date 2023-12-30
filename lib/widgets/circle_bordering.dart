import 'package:flutter/material.dart';

class CircleBordering extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final double borderWidth;
  final double radius;
  final EdgeInsets padding;

  const CircleBordering({
    required this.child,
    required this.borderColor,
    required this.borderWidth,
    required this.radius,
    this.padding = const EdgeInsets.all(3),
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: borderWidth),
        ),
      child: SizedBox(
        width: radius,
        height: radius,
        child: Center(
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
