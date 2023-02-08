import 'package:flutter/material.dart';


typedef ChildBuilder = Function(BuildContext context, double? top, double? realHeight, double? height);
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
  double? realHeight;
  double? height;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _onFinishRender();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, top, realHeight, height);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onFinishRender(){
    final x = context.findRenderObject() as RenderBox;
    realHeight = x.size.height;

    final g = x.localToGlobal(Offset.zero);
    final mediaQuery = MediaQuery.of(context);

    double h = mediaQuery.size.height;

    top = g.dy; // - kToolbarHeight - mediaQuery.padding.top
    height = h - top!;

    setState(() {});
  }
}