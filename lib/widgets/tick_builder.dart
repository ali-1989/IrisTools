import 'dart:async';
import 'package:flutter/material.dart';

typedef TickerBuilder = Widget Function(BuildContext context, TickBuilderState state, int index);

class TickBuilder extends StatefulWidget {
  final TickerBuilder builder;
  final Duration interval;
  final int topTickCount;
  final bool isActive;

 TickBuilder({Key? key,
    required this.builder,
    required this.interval,
    this.topTickCount = 100,
    this.isActive = true,
 }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TickBuilderState();
  }
}
///==============================================================================================================
class TickBuilderState extends State<TickBuilder> {
  int tickCount = 0;
  bool _canRun = true;
  Future? _timer;

  @override
  void initState() {
    super.initState();

    windTicker();
  }

  @override
  Widget build(BuildContext context) {
    _canRun = widget.isActive;

    if(_canRun) {
      if( _timer == null) {
        windTicker();
      }
    }

    return widget.builder(context, this, tickCount);
  }

  void windTicker() {
    if(_canRun) {
      _timer = Future.delayed(widget.interval, () {
        if (_canRun) {
          if (mounted) {
            tickCount++;

            if (tickCount > widget.topTickCount) {
              tickCount = 0;
            }

            setState(() {});

            windTicker();
          }
        }
        else{
          _timer = null;
        }
      });
    }
    else {
      _timer = null;
    }
  }
}
