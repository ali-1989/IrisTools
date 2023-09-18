import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? color;
  final double? radius;
  final BoxBorder? border;
  final BorderRadiusGeometry? borderRadius;

  const CustomCard({
    required this.child,
    this.padding,
    this.radius,
    this.color,
    this.border,
    this.borderRadius,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(radius?? 8),
        child: DecoratedBox(
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              border: border,
              borderRadius: borderRadius?? BorderRadius.circular(radius?? 8),
              color: color?? Colors.white
          ),
          child: Padding(
            padding: padding?? EdgeInsets.zero,
            child: child,
          ),
        )
    );
  }
}