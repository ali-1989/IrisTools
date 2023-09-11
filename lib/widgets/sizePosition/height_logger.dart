import 'package:flutter/material.dart';
import 'package:iris_tools/api/logger/logger.dart';

class HeightLogger extends StatelessWidget {
  late final Widget child;

  HeightLogger(this.child, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: child,
      onTap: () {
        Logger.L.logToScreen('Height is ${context.size!.height}');
      },
    );
  }
}