import 'dart:async';
import 'package:flutter/material.dart';

typedef StateBuilder = Widget Function(BuildContext context, StateXController controller, dynamic sendData);
typedef OverlayBuilder = Widget Function(BuildContext context);
typedef NotifierUpdate = void Function(dynamic sendData);
///===================================================================================================
class StateX extends StatefulWidget {
  final StateXController? controller;
  final String? id;
  final String? group;
  final bool isMain;
  final bool isSubMain;
  final bool chainToMain;
  final StateBuilder builder;

  StateX({
    Key? key,
    this.id,
    this.group,
    this.isMain = false,
    this.isSubMain = false,
    this.chainToMain = false,
    this.controller,
    required this.builder,
  }): assert(id != null || (isSubMain || isMain)), super(key : key);

  @override
  State<StatefulWidget> createState() {
    return _StateXState();
  }
}
///===================================================================================================
class _StateXState extends IStateX<StateX> {
  late StateXController _controller;
  dynamic _data;
  OverlayBuilder? _overlayBuilder;
  late ValueNotifier<int> overlayNotifier;

  dynamic get lastData => _data;

  @override
  void initState() {
    super.initState();

    overlayNotifier = ValueNotifier(0);
    _controller = widget.controller?? StateXController();
    _controller._add(this);
  }

  @override
  void didUpdateWidget(StateX oldWidget) {
    super.didUpdateWidget(oldWidget);

    if(widget.controller != null && widget.controller != oldWidget.controller){
      _controller = widget.controller!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.builder.call(context, _controller, _data),

        ValueListenableBuilder(
          valueListenable: overlayNotifier,
          builder: (ctx, val, child){
            if(_overlayBuilder == null) {
              return SizedBox();
            }

            return _overlayBuilder!.call(ctx);
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    overlayNotifier.dispose();
    _controller._widgetIsDisposed(this);
    super.dispose();
  }

  @override
  void update({dynamic data}) {
    _data = data;

    if(mounted) {
      setState(() {});
    }
  }

  @override
  void disposeWidget() {
    dispose();
  }
}
///===================================================================================================
abstract class IStateX<w extends StatefulWidget> extends State<w> {
  void update({dynamic data});
  void disposeWidget();
}
///===================================================================================================
class StateXController {
  static const state$normal = 'Normal';
  static const state$error = 'Error';
  static const state$emptyData = 'EmptyData';
  static const state$loading = 'Loading';
  static const state$serverNotResponse = 'ServerNotResponse';
  static const state$netDisconnect = 'NetDisconnect';
  static final List<StateXController> _allControllers = [];

  final List<StateXGroup> _groupHolderList = [];
  final List<_StateXState> _xStateList = [];
  final Set<NotifierUpdate> _notifyMainStateUpdate = {};
  final Set<NotifierUpdate> _notifySubMainStateUpdate = {};
  final StateDataManager _stateDataManager = StateDataManager();
  _StateXState? _main;
  _StateXState? _subMain;
  final _objects = <String, dynamic>{};
  String mainState = state$normal;
  String subMainState = state$normal;

  StateXController(){
    _allControllers.add(this);
  }

  void mainStateAndUpdate(String state, {dynamic data}){
    mainState = state;
    updateMain(stateData: data);
  }

  void subMainStateAndUpdate(String state, {dynamic data}){
    subMainState = state;
    updateSubMain(stateData: data);
  }

  void addMainStateListener(NotifierUpdate fn){
    _notifyMainStateUpdate.add(fn);
  }

  void addSubMainStateListener(NotifierUpdate fn){
    _notifySubMainStateUpdate.add(fn);
  }

  void _add(_StateXState state){
    if(!_xStateList.contains(state)){
      _xStateList.add(state);
    }

    if(state.widget.isMain){
      if(_main != null && _main != state){
        throw Exception("one 'isMain' can use");
      }

      _main = state;
    }
    else if(state.widget.isSubMain){
      if(_subMain != null && _subMain != state){
        throw Exception("one 'isSubMain' can use");
      }

      _subMain = state;
    }
    else if(state.widget.chainToMain){
      onUpdate(sensData){
        state.update(data: sensData);
      }

      addMainStateListener(onUpdate);
    }

    var addToGroup = false;

    if(state.widget.group != null) {
      for (var g in _groupHolderList) {
        if (g.groupId == state.widget.group) {
          g.stateList.add(state);
          addToGroup = true;
          break;
        }
      }

      if(!addToGroup){
        _groupHolderList.add(StateXGroup.fill(state.widget.group!, state));
      }
    }
  }

  void updateMain({dynamic stateData, Duration? delay}) {
    void fn(){
      _main?.update(data: stateData);//?? _main!._data

      for(var fn in _notifyMainStateUpdate){
        try {
          fn.call(stateData);
        }
        catch (e){}
      }
    }

    if(delay == null) {
      fn();
    } else {
      Timer(delay, (){fn();});
    }
  }

  void updateSubMain({dynamic stateData, Duration? delay}) {
    void fn(){
      _subMain?.update(data: stateData);

      for(var fn in _notifySubMainStateUpdate){
        try {
          fn.call(stateData);
        }
        catch (e){}
      }
    }

    if(delay == null) {
      fn();
    } else {
      Timer(delay, (){fn();});
    }
  }

  void update(String id, {dynamic stateData, Duration? delay}){
    void fn(){
      for(var s in _xStateList){
        if(s.widget.id == id){
          s.update(data: stateData);
        }
      }
    }

    if(delay == null) {
      fn();
    } else {
      Timer(delay, (){fn();});
    }
  }

  void updateAll({dynamic stateData, Duration? delay}){
    void fn(){
      for(var s in _xStateList){
        s.update(data: stateData);//?? s._data
      }
    }

    if(delay == null) {
      fn();
    } else {
      Timer(delay, (){fn();});
    }
  }

  void updateGroup(String groupId, {dynamic stateData, Duration? delay}){
    void fn(){
      final list = getGroup(groupId);

      for(var s in list){
        final nS = s as _StateXState;
        nS.update(data: stateData);//?? nS._data
      }
    }

    if(delay == null) {
      fn();
    } else {
      Timer(delay, (){fn();});
    }
  }

  Set<State> getGroup(String groupId){
    for(var m in _groupHolderList){
      if(m.groupId == groupId){
        return m.stateList;
      }
    }

    return {};
  }

  void setOverlay(OverlayBuilder? overlay){
    if(_main == null){
      return;
    }

    _main!._overlayBuilder = overlay;
    _main!.overlayNotifier.value++;
  }
  //..............................................................................
  void setObject(String key, dynamic val){
    _objects[key] = val;
  }

  void setObjectIfNotExist(String key, dynamic val){
    if(_objects[key] == null) {
      _objects[key] = val;
    }
  }

  T object<T>(String key){
    return _objects[key];
  }

  T objectOrDefault<T>(String key, T defaultVal){
    return _objects[key]?? defaultVal;
  }

  bool existObject(String key){
    return _objects[key] != null;
  }

  void clearObjects(){
    return _objects.clear();
  }
  //..............................................................................
  void setStateData(String key, dynamic value){
    _stateDataManager.set(key, value);
  }

  T stateData<T>(String key){
    return _stateDataManager.state(key);
  }

  T stateDataOrDefault<T>(String key, T defaultVal){
    return _stateDataManager.state(key)?? defaultVal;
  }

  bool existStateData(String key){
    return _stateDataManager.existKey(key);
  }
  //..............................................................................
  void dispose() {
    _allControllers.remove(this);

    /*no need: for(var s in _stateList){
      if(s.mounted) {
        s.disposeWidget();
      }
    }*/

    _xStateList.clear();
    _objects.clear();
    _groupHolderList.clear();
    _stateDataManager.clear();
    _notifyMainStateUpdate.clear();
    _notifySubMainStateUpdate.clear();
    _main = null;
    _subMain = null;
  }

  void _widgetIsDisposed(IStateX state){
    final temp = [];

    for(var s in _xStateList){
      if(s == state){
        temp.add(s);
      }
    }

    for(var x in temp){
      _xStateList.remove(x);
    }

    if(state == _main){
      _main = null;
    }
    else  if(state == _subMain){
      _subMain = null;
    }

    temp.clear();

    /// means this controller is empty and no control any.
    if(_xStateList.isEmpty){
      _allControllers.remove(this);
      _groupHolderList.clear();
      _objects.clear();
      _stateDataManager.clear();
      _notifyMainStateUpdate.clear();
      _notifySubMainStateUpdate.clear();
      _main = null;
      _subMain = null;
      return;
    }

    final gTemp = [];
    for(var g in _groupHolderList){
      for(var s in g.stateList){
        if(s == state) {
          temp.add(s);
          break;
        }
      }

      for(var x in temp){
        g.stateList.remove(x);
      }

      temp.clear();

      if(g.stateList.isEmpty){
        gTemp.add(g);
      }
    }

    for(var x in gTemp){
      _groupHolderList.remove(x);
    }
  }

  static void globalUpdateMains({dynamic stateData, Duration? delay}){
    for(var c in _allControllers){
      c.updateMain(stateData: stateData, delay: delay);
    }
  }

  static void globalUpdate(String id, {dynamic stateData, Duration? delay}){
    for(var c in _allControllers){
      c.update(id, stateData: stateData, delay: delay);
    }
  }

  static void globalUpdateAll({dynamic stateData, Duration? delay}){
    for(var c in _allControllers){
      c.updateAll(stateData: stateData, delay: delay);
    }
  }

  static void globalUpdateGroup(String groupId, {dynamic stateData, Duration? delay}){
    for(var c in _allControllers){
      c.updateGroup(groupId, stateData: stateData, delay: delay);
    }
  }
}
///===================================================================================================
class StateXGroup {
  late String groupId;
  Set<IStateX> stateList = {};

  StateXGroup();

  StateXGroup.fill(String id, IStateX state){
    groupId = id;
    stateList.add(state);
  }
}
///===================================================================================================
class StateDataManager {
  final Set<MapEntry> _stateList = {};

  StateDataManager();

  StateDataManager.add(String key, dynamic value){
    _stateList.add(MapEntry(key, value));
  }

  void set(String key, dynamic value){
    remove(key);
    _stateList.add(MapEntry(key, value));
  }

  bool setIfAbsent(String key, dynamic value){
    if(!existKey(key)) {
      _stateList.add(MapEntry(key, value));
      return true;
    }

    return false;
  }

  bool existKey(String key){
    for(var e in _stateList){
      if(e.key == key){
        return true;
      }
    }

    return false;
  }

  bool remove(String key){
    MapEntry? find;

    for(var e in _stateList){
      if(e.key == key){
        find = e;
        break;
      }
    }

    if(find != null){
      return _stateList.remove(find);
    }

    return false;
  }

  dynamic state(String key){
    for(var e in _stateList){
      if(e.key == key){
        return e.value;
      }
    }

    return null;
  }

  void clear(){
    _stateList.clear();
  }
}