import 'dart:async';
import 'package:flutter/material.dart';

typedef RefreshBuilder<T> = Widget Function(BuildContext context, UpdateController controller);

class SelfRefresh extends StatefulWidget {
  final RefreshBuilder builder;

  SelfRefresh({Key? key, required this.builder}): super(key : key);

  @override
  State<StatefulWidget> createState() {
    return _SelfRefreshState();
  }
}
///============================================================================================
class _SelfRefreshState extends SelfUpdaterStateApi<SelfRefresh> {
  late UpdateController controller;
  int c = 0;

  @override
  void initState() {
    super.initState();
    controller = UpdateController(this);
  }

  @override
  void didUpdateWidget(SelfRefresh oldWidget) {
    //_childBuilder = oldWidget.childBuilder;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder.call(context, controller);
  }

  @override
  void dispose() {
    controller._disposeFromWidget();
    super.dispose();
  }

  @override
  void update() {
    setState(() {});
  }

  @override
  void disposeWidget() {
    dispose();
  }
}
///==================================================================================================
abstract class SelfUpdaterStateApi<w extends StatefulWidget> extends State<w> {
  void update();
  void disposeWidget();
}
///===================================================================================================
class UpdateController {
  final SelfUpdaterStateApi? _state;
  Map<String, dynamic> objects = {};
  dynamic _attach;
  bool errorOccurred = false;
  String? _primaryTag;
  String? _extraTag;

  UpdateController(this._state);

  void update({Duration? delay}){
    if(_state != null && _state!.mounted){
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

  T get<T>(String key){
    return objects[key];
  }

  T getOrDefault<T>(String key, T defaultVal){
    return objects[key]?? defaultVal;
  }

  bool exist(String key){
    return objects[key] != null;
  }

  T attachment<T>(){
    return _attach;
  }

  void attach(dynamic val){
    _attach = val;
  }

  void _disposeFromWidget() {
    dispose(false);
  }

  void dispose([bool disposeWidget = false]) {
    objects.clear();

    if(disposeWidget && _state != null && _state!.mounted) {
      _state!.disposeWidget();
    }
  }
}