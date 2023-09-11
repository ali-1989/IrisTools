import 'dart:async';
import 'package:flutter/material.dart';

/*
enum AppAssistKeys implements GroupId {
  voicePlayerGroupId$vocabClickable(120);

  final int _number;

  const AppAssistKeys(this._number);

  int getNumber(){
    return _number;
  }
}
 */


typedef AssistBuilderFn = Widget Function(BuildContext context, AssistController controller, dynamic stateData);
typedef AssistOverlayBuilder = Widget Function(BuildContext context, AssistController controller);
///===================================================================================================
class AssistBuilder<T extends Assist, E extends EventScope> extends StatefulWidget {
  final String? id;
  /// define a (enum or class) that implements GroupId {}
  final List<GroupId> groupIds;
  final List<EventScope> eventScopes;//todo. <E>
  final AssistObserve? observable;
  final AssistBuilderFn builder;
  final AssistOverlayBuilder? overlayBuilder;
  final T? _typeDetector = null;


  AssistBuilder({
    Key? key,
    this.id,
    this.groupIds = const [],
    this.eventScopes = const [],
    this.observable,
    this.overlayBuilder,
    required this.builder,
  })
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AssistBuilderState();
  }
}
///===================================================================================================
abstract class IAssistState<w extends StatefulWidget> extends State<w> {
  void update({dynamic data});
  void disposeWidget();
}
///===================================================================================================
class _AssistBuilderState extends IAssistState<AssistBuilder> {
  late AssistController _controller;
  late ValueNotifier<int> _overlayNotifier;
  dynamic _lastData;

  dynamic get lastData => _lastData;

  @override
  void initState() {
    super.initState();

    _overlayNotifier = ValueNotifier(0);
    _controller = AssistController();
    _controller._add(this);
  }

  @override
  void didUpdateWidget(AssistBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _overlayNotifier.dispose();
    _controller._widgetIsDisposed(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.builder.call(context, _controller, _lastData),

        ValueListenableBuilder(
          valueListenable: _overlayNotifier,
          builder: (ctx, val, child){
            if(widget.overlayBuilder == null) {
              return SizedBox();
            }

            return widget.overlayBuilder!.call(ctx, _controller);
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
class AssistController<S> {
  /// public list of all assists
  static final List<AssistController> _allControllers = [];

  late _AssistBuilderState _stateRef;
  final _stateManager = AssistStateManager<S>();
  final KeyValueManager _kvManager = KeyValueManager();
  final String _stateShareSection = '_stateShareSection';

  AssistController();

  void _add(_AssistBuilderState state){
    if(state.widget.id != null) {
      final sameId = AssistController.forId(state.widget.id!);

      if (sameId != null) {
        throw Exception('this id [${state.widget.id}] exist in Assist, use other id');
      }
    }

    _stateRef = state;
    _allControllers.add(this);
    state.widget.observable?._add(this);
  }

  BuildContext? getContext(){
    return _stateRef.context;
  }

  static AssistController? forId(String assistId){
    for(final c in _allControllers){
      if(c._stateRef.widget.id == assistId){
        return c;
      }
    }

    return null;
  }

  static Set<AssistController> forType<T extends Assist>({List<EventScope>? scopes}){
    final res = <AssistController>{};

    for(final c in _allControllers){
      if(c._stateRef.widget._typeDetector.runtimeType == T){
        if(scopes == null || c._stateRef.widget.eventScopes.isEmpty){
          res.add(c);
        }
        else {
          for(final s in c._stateRef.widget.eventScopes){
            if(scopes.contains(s)){
              res.add(c);
              break;
            }
          }
        }
      }
    }

    return res;
  }

  static Set<AssistController> forGroup(GroupId groupId){
    final res = <AssistController>{};

    for(final c in _allControllers){
      if(c._stateRef.widget.groupIds.contains(groupId)){
        res.add(c);
      }
    }

    return res;
  }

  static void updateById(String assistId, {dynamic stateData, Duration? delay}){
    forId(assistId)?.update(stateData: stateData, delay: delay);
  }

  static void updateByGroup(GroupId groupId, {dynamic stateData, Duration? delay}){
    forGroup(groupId).forEach((element) {
      element.update(stateData: stateData, delay: delay);
    });
  }

  static void updateByType<T extends Assist>({List<EventScope>? scopes, dynamic stateData, Duration? delay}){
    forType(scopes: scopes).forEach((element) {
      element.update(stateData: stateData, delay: delay);
    });
  }
  ///............. Overlay ......................................................
  void updateOverlay(){
    _stateRef._overlayNotifier.value++;
  }
  ///............. states ........................................................
  bool hasState(S state, {String? scopeId}){
    return _stateManager.existState(scopeId?? _stateShareSection, state);
  }

  bool hasStates(List<S> states, {String? scopeId}){
    return _stateManager.existStates(scopeId?? _stateShareSection, states);
  }

  bool existAnyStates(List<S> states, {String? scopeId}){
    for(final x in states){
      if(_stateManager.existState(scopeId?? _stateShareSection, x)){
        return true;
      }
    }

    return false;
  }

  void addState(S state, {String? scopeId}){
    _stateManager.addState(scopeId?? _stateShareSection, state);
  }

  void addStateAfterClear(S state, {String? scopeId}){
    _stateManager.clearStates(scopeId?? _stateShareSection);
    _stateManager.addState(scopeId?? _stateShareSection, state);
  }

  void removeState(S state, {String? scopeId}){
    _stateManager.removeState(scopeId?? _stateShareSection, state);
  }

  void clearStates({String? scopeId}){
    _stateManager.clearStates(scopeId?? _stateShareSection);
  }

  void addStateAndUpdate(S state, {dynamic data}){
    addState(state);
    update(stateData: data);
  }

  void removeStateAndUpdate(S state, {dynamic data}){
    removeState(state);
    update(stateData: data);
  }

  void update({dynamic stateData, Duration? delay}) {
    void fn(){
      _stateRef.update(data: stateData);
    }

    if(delay == null) {
      fn();
    }
    else {
      Timer(delay, (){fn();});
    }
  }
  ///............. shareDataManager ......................................................
  void setKeyValue(String key, dynamic value){
    _kvManager.set(key, value);
  }

  void setValueIfNotExist(String key, dynamic val){
    if(!existKey(key)) {
      setKeyValue(key, val);
    }
  }

  C getValue<C>(String key){
    return _kvManager.getValue(key) as C;
  }

  C getValueOr<C>(String key, C defaultVal){
    return _kvManager.getValue(key)?? defaultVal;
  }

  bool existKey(String key){
    return _kvManager.existKey(key);
  }

  void clearKeyValues(){
    return _kvManager.clear();
  }
  ///..............................................................................
  void dispose() {
    _allControllers.remove(this);
    _stateRef.widget.observable?._remove(this);
    _kvManager.clear();
  }

  void _widgetIsDisposed(IAssistState state){
    dispose();
  }
}
///===================================================================================================
mixin class Assist {

  void emit<T extends Assist>({List<EventScope>? scopes, dynamic data}){
    AssistController.updateByType<T>(scopes: scopes, stateData: data);
  }
}

abstract class EventScope {}
///===================================================================================================
abstract class GroupId {}
//enum Or Class implements GroupId {}
///---------------------------------------
class GroupOfAssist {
  late GroupId groupId;
  final stateList = <IAssistState>{};

  GroupOfAssist();

  GroupOfAssist.fill(GroupId id, IAssistState state){
    groupId = id;
    stateList.add(state);
  }
}
///===================================================================================================
class KeyValueManager<T> {
  final Set<MapEntry> _objList = {};

  KeyValueManager();

  KeyValueManager.add(String key, T value){
    _objList.add(MapEntry(key, value));
  }

  void set(String key, T value){
    remove(key);
    _objList.add(MapEntry(key, value));
  }

  bool setIfAbsent(String key, T value){
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

  dynamic getValue(String key){
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
class AssistStateManager<T> {
  final Map<String, Set<T>> _objList = {};

  AssistStateManager();

  void addState(String section, T state){
    if(existSection(section)){
      getStates(section).add(state);
    }
    else {
      _objList[section] = {state};
    }
  }

  void removeState(String section, T state){
    if(existSection(section)){
      getStates(section).remove(state);
    }
  }

  bool existState(String section, T state){
    return getStates(section).contains(state);
  }

  bool existStates(String section, List<T> states){
    final sectionList = getStates(section);

    for(final s in states){
      if(!sectionList.contains(s)){
        return false;
      }
    }

    return true;
  }

  bool existSection(String section){
    for(final e in _objList.entries){
      if(e.key == section){
        return true;
      }
    }

    return false;
  }

  bool removeSection(String section){
    _objList.removeWhere((k, v) => k == section);

    return true;
  }

  Set<T> getStates(String section){
    for(final e in _objList.entries){
      if(e.key == section){
        return e.value;
      }
    }

    return {};
  }

  void clearStates(String section){
    getStates(section).clear();
  }

  void clearAll(){
    _objList.clear();
  }
}
///===================================================================================================
class AssistObserve<T> {
  T? _value;
  final List<AssistController> _observers = []; // = listeners

  AssistObserve([T? value]) :_value = value;

  T? get value => _value;

  void changeValue(T? value){
    _value = value;
  }

  void notify(){
    for(final assist in _observers){
      assist.update();
    }
  }

  void changeAndNotify(T? value){
    _value = value;
    notify();
  }

  bool hasListeners(){
    return _observers.isNotEmpty;
  }

  List<AssistController> get listeners {
    return _observers;
  }

  void _add(AssistController controller){
    if(!_observers.contains(controller)){
      _observers.add(controller);
    }
  }

  void _remove(AssistController controller){
    _observers.remove(controller);
  }
}
