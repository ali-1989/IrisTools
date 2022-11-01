import 'dart:async';
import 'package:flutter/material.dart';

typedef AssistBuilder = Widget Function(BuildContext context, AssistController controller, dynamic sendData);
typedef OverlayBuilder = Widget Function(BuildContext context);
typedef NotifierUpdate = void Function(dynamic sendData);
///===================================================================================================
class Assist extends StatefulWidget {
  final AssistController? controller;
  final String? id;
  final String? groupId;
  final AssistObserver? observable;
  final AssistBuilder builder;

  Assist({
    Key? key,
    this.id,
    this.groupId,
    this.controller,
    this.observable,
    required this.builder,
  }) : assert(!(observable != null && controller != null), 'can not set observable and controller together'), super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AssistState();
  }
}
///===================================================================================================
abstract class IAssist<w extends StatefulWidget> extends State<w> {
  void update({dynamic data});
  void disposeWidget();
}
///===================================================================================================
class _AssistState extends IAssist<Assist> {
  late AssistController _controller;
  OverlayBuilder? _overlayBuilder;
  late ValueNotifier<int> overlayNotifier;
  dynamic _lastData;

  dynamic get lastData => _lastData;

  @override
  void initState() {
    super.initState();

    overlayNotifier = ValueNotifier(0);
    _controller = widget.controller?? AssistController();
    _controller._add(this);
  }

  @override
  void didUpdateWidget(Assist oldWidget) {
    super.didUpdateWidget(oldWidget);

    if(widget.controller != oldWidget.controller){
      oldWidget.controller?.dispose();

      if(widget.controller != null) {
        _controller = widget.controller!;
        _controller._add(this);
      }
      else {
        _controller = AssistController();
        _controller._add(this);
      }
    }
  }

  @override
  void dispose() {
    overlayNotifier.dispose();
    _controller._widgetIsDisposed(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.builder.call(context, _controller, _lastData),

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
  void update({dynamic data}) {
    _lastData = data;

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
class AssistController {
  static const state$normal = 'NormalState';
  static const state$error = 'ErrorState';
  static const state$emptyData = 'EmptyDataState';
  static const state$loading = 'LoadingState';
  static const state$serverNotResponse = 'ServerNotResponseState';
  static const state$netDisconnect = 'NetDisconnectState';

  static final List<AssistController> _allControllers = [];

  final List<GroupOfAssist> _groupList = [];
  final List<_AssistState> _assistStateList = [];
  final List<String> _shareStateList = [];
  final List<AssistObserver> _observerList = [];
  final Set<NotifierUpdate> _notifyMainStateUpdate = {};
  final KeyValueManager _stateDataManager = KeyValueManager();
  _AssistState? _mainStateRef;
  String mainState = state$normal;

  AssistController(){
    _allControllers.add(this);
  }

  void _add(_AssistState state){
    if(!_assistStateList.contains(state)){
      if(state.widget.id == null){
        _assistStateList.add(state);
      }
      else {
        final sameId = _getState(state.widget.id!);

        if(sameId != null){
          throw Exception('this id [${state.widget.id}] exist in Assist controller');
        }

        _assistStateList.add(state);
      }
    }

    _mainStateRef ??= state;

    if(state.widget.groupId != null) {
      var isAddToGroup = false;

      for (final g in _groupList) {
        if (g.groupId == state.widget.groupId) {
          g.stateList.add(state);
          isAddToGroup = true;
          break;
        }
      }

      if(!isAddToGroup){
        _groupList.add(GroupOfAssist.fill(state.widget.groupId!, state));
      }
    }

    if(state.widget.observable != null){
      addObservable(state.widget.observable!);
    }
  }

  void addMainStateListener(NotifierUpdate fn){
    if(!_notifyMainStateUpdate.contains(fn)) {
      _notifyMainStateUpdate.add(fn);
    }
  }

  void removeMainStateListener(NotifierUpdate fn){
    _notifyMainStateUpdate.remove(fn);
  }

  void addObservable(AssistObserver observer){
    observer._add(this);

    if(!_observerList.contains(observer)){
      _observerList.add(observer);
    }
  }

  void removeObservable(AssistObserver observer){
    observer._remove(this);
    _observerList.remove(observer);
  }

  void mainStateAndUpdate(String state, {dynamic data}){
    mainState = state;
    updateMain(stateData: data);
  }

  void updateMain({dynamic stateData, Duration? delay}) {
    void fn(){
      _mainStateRef?.update(data: stateData);

      for(final fn in _notifyMainStateUpdate){
        try {
          fn.call(stateData);
        }
        catch (e){}
      }
    }

    if(delay == null) {
      fn();
    }
    else {
      Timer(delay, (){fn();});
    }
  }

  void update(String stateId, {dynamic stateData, Duration? delay}){
    void fn(){
      _getState(stateId)?.update(data: stateData);
    }

    if(delay == null) {
      fn();
    }
    else {
      Timer(delay, (){fn();});
    }
  }

  bool hasState(String state){
    return _shareStateList.contains(state);
  }

  bool hasStates(List<String> states){
    for(final s in states){
      if(!_shareStateList.contains(s)){
        return false;
      }
    }

    return true;
  }

  void addState(String state){
    if(!_shareStateList.contains(state)) {
      _shareStateList.add(state);
    }
  }

  void removeState(String state){
    _shareStateList.remove(state);
  }

  void addStateAndUpdate(String state, {dynamic stateData, Duration? delay}){
    addState(state);

    updateAll(stateData: stateData, delay: delay);
  }

  void removeStateAndUpdate(String state, {dynamic stateData, Duration? delay}){
    removeState(state);

    updateAll(stateData: stateData, delay: delay);
  }

  void clearStates(){
    _shareStateList.clear();
  }

  void updateAll({dynamic stateData, Duration? delay}){
    void fn(){
      for(final s in _assistStateList){
        s.update(data: stateData);
      }
    }

    if(delay == null) {
      fn();
    }
    else {
      Timer(delay, (){fn();});
    }
  }

  void updateGroup(String groupId, {dynamic stateData, Duration? delay}){
    void fn(){
      final list = getGroups(groupId);

      for(final s in list){
        final nS = s as _AssistState;
        nS.update(data: stateData);
      }
    }

    if(delay == null) {
      fn();
    }
    else {
      Timer(delay, (){fn();});
    }
  }

  _AssistState? _getState(String stateId){
    for(final s in _assistStateList){
      if(s.widget.id == stateId){
        return s;
      }
    }

    return null;
  }

  Set<State> getGroups(String groupId){
    for(final m in _groupList){
      if(m.groupId == groupId){
        return m.stateList;
      }
    }

    return {};
  }

  void setOverlay(OverlayBuilder? overlay, {String? stateId}){
    if(_mainStateRef == null){
      return;
    }

    if(stateId == null) {
      _mainStateRef!._overlayBuilder = overlay;
      _mainStateRef!.overlayNotifier.value++;
    }
    else {
      _getState(stateId)?._overlayBuilder = overlay;
      _getState(stateId)?.overlayNotifier.value++;
    }
  }
  //..............................................................................
  void setKeyValue(String key, dynamic value){
    _stateDataManager.set(key, value);
  }

  void setValueIfNotExist(String key, dynamic val){
    if(!existKey(key)) {
      setKeyValue(key, val);
    }
  }

  T getValue<T>(String key){
    return _stateDataManager.state(key);
  }

  T getValueOr<T>(String key, T defaultVal){
    return _stateDataManager.state(key)?? defaultVal;
  }

  bool existKey(String key){
    return _stateDataManager.existKey(key);
  }

  void clearKeyValues(){
    return _stateDataManager.clear();
  }
  //..............................................................................
  void dispose() {
    _allControllers.remove(this);

    /*no need: for(var s in _stateList){
      if(s.mounted) {
        s.disposeWidget();
      }
    }*/

    _assistStateList.clear();
    _groupList.clear();
    _stateDataManager.clear();
    _notifyMainStateUpdate.clear();

    for(final k in _observerList){
      k._remove(this);
    }

    _observerList.clear();
    _mainStateRef = null;
  }

  void _widgetIsDisposed(IAssist state){
    final temp = [];

    for(final s in _assistStateList){
      if(s == state){
        temp.add(s);
      }
    }

    for(final x in temp){
      _assistStateList.remove(x);
    }

    if(state == _mainStateRef){
      _mainStateRef = null;
    }

    temp.clear();

    final gTemp = [];
    for(final g in _groupList){
      for(final s in g.stateList){
        if(s == state) {
          temp.add(s);
          break;
        }
      }

      for(final x in temp){
        g.stateList.remove(x);
      }

      temp.clear();

      if(g.stateList.isEmpty){
        gTemp.add(g);
      }
    }

    for(final x in gTemp){
      _groupList.remove(x);
    }

    /// means this controller is empty and no control any Assist.
    if(_assistStateList.isEmpty){
      dispose();
    }
  }

  static void globalUpdateMains({dynamic stateData, Duration? delay}){
    for(final c in _allControllers){
      c.updateMain(stateData: stateData, delay: delay);
    }
  }

  static void globalUpdate(String stateId, {dynamic stateData, Duration? delay}){
    for(final c in _allControllers){
      c.update(stateId, stateData: stateData, delay: delay);
    }
  }

  static void globalUpdateAll({dynamic stateData, Duration? delay}){
    for(final c in _allControllers){
      c.updateAll(stateData: stateData, delay: delay);
    }
  }

  static void globalUpdateGroup(String groupId, {dynamic stateData, Duration? delay}){
    for(final c in _allControllers){
      c.updateGroup(groupId, stateData: stateData, delay: delay);
    }
  }
}
///===================================================================================================
class GroupOfAssist {
  late String groupId;
  final stateList = <IAssist>{};

  GroupOfAssist();

  GroupOfAssist.fill(String id, IAssist state){
    groupId = id;
    stateList.add(state);
  }
}
///===================================================================================================
class KeyValueManager {
  final Set<MapEntry> _objList = {};

  KeyValueManager();

  KeyValueManager.add(String key, dynamic value){
    _objList.add(MapEntry(key, value));
  }

  void set(String key, dynamic value){
    remove(key);
    _objList.add(MapEntry(key, value));
  }

  bool setIfAbsent(String key, dynamic value){
    if(!existKey(key)) {
      _objList.add(MapEntry(key, value));
      return true;
    }

    return false;
  }

  bool existKey(String key){
    for(final e in _objList){
      if(e.key == key){
        return true;
      }
    }

    return false;
  }

  bool remove(String key){
    MapEntry? find;

    for(final e in _objList){
      if(e.key == key){
        find = e;
        break;
      }
    }

    if(find != null){
      return _objList.remove(find);
    }

    return false;
  }

  dynamic state(String key){
    for(final e in _objList){
      if(e.key == key){
        return e.value;
      }
    }

    return null;
  }

  void clear(){
    _objList.clear();
  }
}
///===================================================================================================
class AssistObserver<T> {
  T? _value;
  final List<AssistController> _assistController = [];

  AssistObserver([T? value]) :_value = value;

  T? get value => _value;

  void changeValue(T? value){
    _value = value;
  }

  void notify(){
    for(final assist in _assistController){
      assist.updateAll();
    }
  }

  void changeAndNotify(T? value){
    _value = value;
    notify();
  }

  bool hasListeners(){
    return _assistController.isNotEmpty;
  }

  List<AssistController> get listeners {
    return _assistController;
  }

  void _add(AssistController controller){
    if(!_assistController.contains(controller)){
      _assistController.add(controller);
    }
  }

  void _remove(AssistController controller){
    _assistController.remove(controller);
  }
}