import 'dart:math';

import 'package:flutter/material.dart';

class KeepShadowBound extends StatefulWidget {
  final Widget child;
  const KeepShadowBound({super.key, required this.child});

  @override
  State createState() => _KeepShadowBoundState();
}
///=============================================================================
class _KeepShadowBoundState extends State<KeepShadowBound> {
  double? height;
  double? width;
  Element? childElement;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Element myElement = (context as Element);

      bool cheek(Element? elm){
        if(elm == null){
          return true;
        }

        if(elm.widget is MultiChildRenderObjectWidget){
          return true;
        }

        final isDecor = isDecoratedBox(elm);

        if(isDecor){
          childElement = elm;
        }

        return isDecor;
      }

      while(!cheek(myElement)){
        myElement.visitChildren((element) {
          myElement = element;
        });
      }

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    calcSize();

    return SizedBox(
      width: width,
        height: height,
        child: Center(child: widget.child)
    );
  }

  void calcSize() {
    if(childElement == null){
      return;
    }

    final decoratedBox = childElement!.widget as DecoratedBox;
    final boxDecor = decoratedBox.decoration as BoxDecoration;
    final shadows = boxDecor.boxShadow;

    double maxH = 0;
    double maxW = 0;

    if(shadows == null){
      return;
    }

    for(final s in shadows){
      maxH = max(s.spreadRadius, maxH);
      maxH = max(s.blurRadius, maxH);

      maxW = maxH;
      maxH = max(s.offset.dy, maxH);
      maxW = max(s.offset.dx, maxW);
    }

    final render = childElement!.findRenderObject() as RenderBox;
    height = render.size.height + (maxH*2);
    width = render.size.width + (maxW*2);
  }

  bool isDecoratedBox(Element element){
    return element is SingleChildRenderObjectElement && element.toString().contains('DecoratedBox');
  }
}
