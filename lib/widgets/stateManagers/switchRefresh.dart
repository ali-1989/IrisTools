import 'dart:async';
import 'package:flutter/material.dart';

typedef SwitchBuilder<T> = Widget Function(BuildContext context, dynamic item, SwitchController controller);
///===================================================================================================
class SwitchRefresh extends StatefulWidget {
  final SwitchBuilder builder;
  final SwitchController controller;

  SwitchRefresh({Key? key, required this.controller, required this.builder,}): super(key : key);

  @override
  State<StatefulWidget> createState() {
    return _SwitchRefreshState();
  }
}
///===================================================================================================
class _SwitchRefreshState extends SwitchViewStateApi<SwitchRefresh> {
  late SwitchController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _controller._state = this;
  }

  @override
  void didUpdateWidget(SwitchRefresh oldWidget) {
    //_controller = oldWidget.controller;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder.call(context, _controller.item, _controller);
  }

  @override
  void dispose() {
    _controller._disposeFromWidget();
    super.dispose();
  }

  @override
  void update() {
    setState(() {
    });
  }

  @override
  void disposeWidget() {
    dispose();
  }
}
///==============================================================================================
abstract class SwitchViewStateApi<w extends StatefulWidget> extends State<w> {
  void update();
  void disposeWidget();
}
///====================================================================================
class SwitchController {
  SwitchViewStateApi? _state;
  Map<String, dynamic> objects = {};
  dynamic item;
  bool errorOccurred = false;
  String? _primaryTag;
  String? _extraTag;

  SwitchController(dynamic initItem){
    item = initItem;
  }

  void update({Duration? delay}){
    if(_state != null && _state!.mounted) {
      if(delay == null) {
        _state!.update();
      } else {
        Timer(delay, (){_state!.update();});
      }
    }
  }

  Widget? get widget => _state?.widget;
  BuildContext? get context => _state?.context;

  bool isPrimaryTag(String tag) => _primaryTag != null && _primaryTag == tag;
  bool isExtraTag(String tag) => _extraTag != null && _extraTag == tag;

  void setPrimaryTag(String val){
    _primaryTag = val;
  }

  String? getPrimaryTag(){
    return _primaryTag;
  }

  void setExtraTag(String val){
    _extraTag = val;
  }

  String? getExtraTag(){
    return _extraTag;
  }

  void set(String key, dynamic val){
    objects[key] = val;
  }

  void addIfNotExist(String key, dynamic val){
    if(objects[key] == null) {
      objects[key] = val;
    }
  }

  T getItem<T>(){
    return item;
  }

  void setItem(dynamic val){
    item = val;
  }

  void setItemAndUpdate(dynamic val){
    item = val;
    update();
  }

  T get<T>(String key){
    return objects[key];
  }

  T getOrDefault<T>(String key, T defaultVal){
    return objects[key]?? defaultVal;
  }

  bool exist(String key){
    return objects[key] != null;
  }

  void _disposeFromWidget() {
  }

  void dispose([bool disposeWidget = false]) {
    objects.clear();

    if(disposeWidget && _state != null) {
      _state!.disposeWidget();
    }
  }
}