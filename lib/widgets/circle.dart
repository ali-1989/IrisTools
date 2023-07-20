import 'package:flutter/material.dart';

class Circle extends StatelessWidget {
  final double size;
  final Color color;

  const Circle({
    super.key,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TabPageSelectorIndicator(
      backgroundColor: color,
      borderColor: color,
      size: size,
    );
  }
}
