import 'package:flutter/material.dart';
import 'package:iris_tools/api/helpers/colorHelper.dart';

class ColoredSpace extends StatelessWidget {
  final Color? color;
  final double? width;
  final double? height;

  const ColoredSpace({
    Key? key,
    this.color,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: width?? 100,
        height: height?? 100,
        child: ColoredBox(color: color?? ColorHelper.getRandomRGB())
    );
  }
}
