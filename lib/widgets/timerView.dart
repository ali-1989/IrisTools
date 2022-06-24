import 'dart:async';

import 'package:flutter/material.dart';

class TimerView extends StatefulWidget {
  final TimerViewController controller;
  final TextStyle? textStyle;

  const TimerView({
    Key? key,
    required this.controller,
    this.textStyle,
  }) : super(key: key);

  @override
  _TimerViewState createState() => _TimerViewState();
}
///=============================================================================================
class TimerViewController {
  late _TimerViewState _state;

  void start(){
    _state.start();
  }

  void pause(){
    _state.pause();
  }

  void reset(){
    _state.reset();
  }

  bool isStart(){
    return _state.isStart();
  }

  int currentSeconds(){
    return _state.current();
  }
}
///=============================================================================================
class _TimerViewState extends State<TimerView> {
  int seconds = 0;
  Timer? timer;
  int m1 = 0;
  int m2 = 0;
  int s1 = 0;
  int s2 = 0;

  @override
  void initState() {
    super.initState();
    widget.controller._state = this;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: widget.textStyle?? TextStyle(color: Colors.black),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$m1'),
          Text('$m2'),
          Text(':'),
          Text('$s1'),
          Text('$s2'),
        ],
      ),
    );
  }

  void start(){
    if(timer == null || !timer!.isActive) {
      timer = Timer.periodic(Duration(seconds: 1), onTick);
    }
  }

  void onTick(Timer timer){
    seconds++;

    final min = seconds ~/ 60;

    if(min < 1){
      m1 = 0;
      m2 = 0;
      s1 = seconds ~/ 10;
      s2 = seconds % 10;
    }
    else {
      m1 = min ~/ 10;
      m2 = min % 10;

      final sec = seconds - (min * 60);

      s1 = sec ~/ 10;
      s2 = sec % 10;
    }

    if(mounted) {
      setState(() {});
    }
  }

  void pause(){
    timer?.cancel();
  }

  void reset(){
    timer?.cancel();
    seconds = 0;
  }

  int current(){
    return seconds;
  }

  bool isStart(){
    return timer != null && timer!.isActive;
  }

  @override
  void dispose() {
    timer?.cancel();

    super.dispose();
  }
}
