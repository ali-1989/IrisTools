import 'package:flutter/material.dart';

typedef RefreshBuilder<T> = Widget Function(BuildContext context, dynamic newValue);
typedef ListenerAction<T> = void Function(dynamic newValue);

/// same of: ValueListenableBuilder

class NotifyRefresh extends StatefulWidget {
  final NotifyBroadcast notifier;
  final RefreshBuilder builder;

  NotifyRefresh({Key? key,
    required this.notifier,
    required this.builder,
  }): super(key : key);

  @override
  State<StatefulWidget> createState() {
    return _NotifyRefreshState();
  }
}
///============================================================================================
class _NotifyRefreshState extends State<NotifyRefresh> {

  @override
  void initState() {
    super.initState();

    widget.notifier.addListener(_listener);
  }

  @override
  void didUpdateWidget(NotifyRefresh oldWidget) {
    if (oldWidget.notifier != widget.notifier) {
      oldWidget.notifier.removeListener(_listener);
      widget.notifier.addListener(_listener);
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder.call(context, widget.notifier.currentValue());
  }

  @override
  void dispose() {
    widget.notifier.removeListener(_listener);
    super.dispose();
  }

  void update() {
    if(mounted) {
      setState(() {});
    }
  }

  void _listener(dynamic val){
    update();
  }
}
///===================================================================================================
class NotifyBroadcast {
  final List<ListenerAction> _list = [];
  dynamic _currentValue;

  NotifyBroadcast();

  void addListener(ListenerAction listener){
    if(!_list.contains(listener)) {
      _list.add(listener);
    }
  }

  void removeListener(ListenerAction listener){
    _list.remove(listener);
  }

  void clearListener(){
    _list.clear();
  }

  int listenerCount(){
    return _list.length;
  }

  dynamic currentValue(){
    return _currentValue;
  }

  void notifyAll(dynamic value){
    _currentValue = value;

    for(var x in _list){
      try{
        x.call(_currentValue);
      }
      catch (e){}
    }
  }
}
///==================================================================================================