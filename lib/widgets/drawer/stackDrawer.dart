import 'dart:math';
import 'package:flutter/material.dart';

class DrawerStacks {
  DrawerStacks._();

  static final Map<String, DrawerStackState> _linkList = {};

  static void _add(String name, DrawerStackState drawer){
    if(!_linkList.containsKey(name)){
      _linkList[name] = drawer;
    }
  }

  static void _remove(String name){
    _linkList.remove(name);
  }

  static DrawerStackState? _get(String name){
    DrawerStackState? find;

    try {
      find = _linkList.entries.firstWhere((element){
        return element.key == name;
      }).value;
    }
    catch (e){}

    return find;
  }

  static bool isOpen(String name){
    DrawerStackState? find = _get(name);

    if(find != null){
      return find.isOpen;
    }

    return false;
  }

  static bool isOpening(String name){
    DrawerStackState? find = _get(name);

    if(find != null){
      return find._isOpening;
    }

    return false;
  }

  static bool isClosing(String name){
    DrawerStackState? find = _get(name);

    if(find != null){
      return find._isClosing;
    }

    return false;
  }

  static void open(String name){
    DrawerStackState? find = _get(name);

    if(find != null && !find.isOpen){
      find.endValue = 1;
      find.update();
    }
  }

  static void close(String name){
    DrawerStackState? find = _get(name);

    if(find != null && find.isOpen){
      find.endValue = 0;
      find.update();
    }
  }

  static void toggle(String name){
    DrawerStackState? find = _get(name);

    if(find == null) {
      return;
    }

    if(find.isOpen) {
      find.endValue = 0;
    } else {
      find.endValue = 1;
    }

    find.update();
  }
}
///========================================================================================
class DrawerStack extends StatefulWidget {
  final String name;
  final Widget body;
  final Widget drawer;
  final Color? backgroundColor;
  final Duration? duration;
  final bool gestureSwipe;
  final bool rtlDirection;
  final bool tapToClose;
  final double gestureThreshold;
  final double factor;
  final Curve curve;
  final VoidCallback? onOpened;
  final VoidCallback? onStartOpen;
  final VoidCallback? onClosed;
  final VoidCallback? onStartClose;

  DrawerStack({
    Key? key,
    required this.name,
    required this.body,
    required this.drawer,
    this.backgroundColor,
    this.duration,
    this.gestureSwipe = true,
    this.rtlDirection = false,
    this.tapToClose = true,
    this.curve = Curves.easeIn,
    this.gestureThreshold = 20,
    this.factor = 200,
    this.onStartOpen,
    this.onOpened,
    this.onStartClose,
    this.onClosed,
  }): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DrawerStackState();
  }
}
///=====================================================================================================
class DrawerStackState extends State<DrawerStack> {
  double endValue = 0;
  double animationValue = 0;
  double _gestureThreshold = 0;
  double _factor = 200;
  bool isOpen = false;
  bool _isOpening = false;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();

    DrawerStacks._add(widget.name, this);
  }

  @override
  Widget build(BuildContext context) {
    if(widget.gestureThreshold > 30) {
      _gestureThreshold = 30;
    } else if(widget.gestureThreshold < 10) {
      _gestureThreshold = 10;
    } else {
      _gestureThreshold = widget.gestureThreshold;
    }

    if(widget.factor > 300) {
      _factor = 300;
    } else if(widget.factor < 100) {
      _factor = 100;
    } else {
      _factor = widget.factor;
    }

    return Stack(
      children: [

        Positioned.fill(
            child: ColoredBox(
              color: widget.backgroundColor?? Colors.lightBlue,
            ),
        ),


        SafeArea(
            child: widget.drawer
        ),

        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: endValue),
          duration: widget.duration?? Duration(milliseconds: 320),
          curve: widget.curve,
          onEnd: (){
            if(endValue == 1) {
              isOpen = true;

              try{
                widget.onOpened?.call();
              }
              catch (e){}

              update();
            }
            else {
              isOpen = false;

              try{
                widget.onClosed?.call();
              }
              catch (e){}
            }
          },
          builder: (BuildContext context, double? value, Widget? child) {

            if(value! > 0.0 && value > animationValue && !_isOpening){
              _isOpening = true;
              _isClosing = false;

              try{
                widget.onStartOpen?.call();
              }
              catch (e){}
            }

            if(value < 1.0 && value < animationValue && !_isClosing){
              _isClosing = true;
              _isOpening = false;

              try{
                widget.onStartClose?.call();
              }
              catch (e){}
            }

            animationValue = value;

            getTransform(){
              return Transform(
                child: widget.body,
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, widget.rtlDirection? -0.001 : 0.001)
                  ..setEntry(0, 3, _factor * value * (widget.rtlDirection? -1 : 1))
                  ..rotateY((pi/5) * value),
              );
            }
            ///------------------------------------------
            if(widget.tapToClose && isOpen) {
              return GestureDetector(
                child: getTransform(),
                  onTap: (){
                    if(isOpen){
                      endValue = 0;
                      update();
                    }
                  }
              );
            } else {
              return getTransform();
            }
          },
        ),

        GestureDetector(
          onHorizontalDragUpdate: (e){
            if((e.delta.dx * (widget.rtlDirection? -1:1)) > 0){
              if(widget.gestureSwipe) {
                if (e.globalPosition.dx < _gestureThreshold) {
                  endValue = 1;
                  update();
                }
              }
            }
            else {
              if(widget.tapToClose) {
                if (isOpen || e.delta.direction >= 0.0) {
                  endValue = 0;
                  update();
                }
              }
            }
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    DrawerStacks._remove(widget.name);

    super.dispose();
  }

  void update(){
    setState(() {});
  }
}
///=====================================================================================================