import 'package:flutter/material.dart';

typedef ChildBuilder = Function(BuildContext context, SizeListenerController ctr);
//-------------------------------------------------------------------
class SizeListener extends StatefulWidget {
  final SizeListenerController controller;
  final ChildBuilder builder;
  final Widget? beforeLayout;
  final bool isListener;

  const SizeListener({
    required this.controller,
    required this.builder,
    this.beforeLayout,
    this.isListener = false,
    Key? key,
  }) : super(key: key);

  @override
  State<SizeListener> createState() => _SizeListenerState();
}
//-------------------------------------------------------------------------------------
class _SizeListenerState extends State<SizeListener> {

  @override
  void initState() {
    super.initState();

    if(!widget.isListener){
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if(!mounted){
          return;
        }

        widget.controller.size = context.size;
        widget.controller.renderBox = context.findRenderObject() as RenderBox;

        for(final k in widget.controller._list){
          k.update();
        }
      });
    }
    else {
      widget.controller._list.add(this);
    }
  }

  @override
  Widget build(BuildContext context) {
    if(widget.isListener && widget.controller.size == null) {
      return widget.beforeLayout?? SizedBox();
    }

    return widget.builder(context, widget.controller);
  }


  @override
  void dispose() {
    widget.controller._list.remove(this);

    super.dispose();
  }

  void update(){
    setState(() {});
  }
}
///=====================================================================================
class SizeListenerController {
  Size? size;
  RenderBox? renderBox;
  final List<_SizeListenerState> _list = [];
}