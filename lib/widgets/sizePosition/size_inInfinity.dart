import 'package:flutter/material.dart';


typedef ChildBuilder = Widget Function(BuildContext context, double? top, double? height, double? screenHeight);
///=======================================================================================
class SizeInInfinity extends StatefulWidget {
  final ChildBuilder builder;

  SizeInInfinity({
    Key? key,
    required this.builder,
      }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SizeInInfinityState();
  }
}
///=======================================================================================
class SizeInInfinityState extends State<SizeInInfinity> {
  double? top;
  double? height;
  double? screenHeight;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _onFinishRender();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, top, height, screenHeight);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onFinishRender(){
    final x = context.findRenderObject() as RenderBox;
    height = x.size.height;

    final g = x.localToGlobal(Offset.zero);
    final mediaQuery = MediaQuery.of(context);

    double screenHeight = mediaQuery.size.height;

    top = g.dy; // - kToolbarHeight - mediaQuery.padding.top
    screenHeight = screenHeight - top!;

    setState(() {});
  }
}