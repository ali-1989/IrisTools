import 'dart:async';
import 'package:flutter/material.dart';

typedef AssistBuilder = Widget Function(BuildContext context, AssistController controller, dynamic sendData);
typedef OverlayBuilder = Widget Function(BuildContext context);
typedef NotifierUpdate = void Function(dynamic sendData);
///===================================================================================================
class Assist extends StatefulWidget {
  final AssistController? controller;
  final bool? isHead;
  final bool selfControl;
  final String? id;
  final AssistObserver? observable;
  final AssistBuilder builder;

  /// define a (enum or class) that implements GroupId {}
  final List<GroupId> groupIds;

  Assist({
    Key? key,
    this.id,
    this.groupIds = const [],
    this.controller,
    this.observable,
    this.isHead,
    this.selfControl = false,
    required this.builder,
  })
      : super(key: key) {
     //assert(!(observable != null && controller != null), 'can not set observable and controller together'), super(key: key);
     assert(!(selfControl && controller != null), 'if this is a selfControl then it is can not have controller');
  }
  @override
  State<StatefulWidget> createState() {
    return _AssistState();
  }
}
///===================================================================================================
abstract class IAssistState<w extends StatefulWidget> extends State<w> {
  void update({dynamic data});
  void disposeWidget();
}
///===================================================================================================
class _AssistState extends IAssistState<Assist> {
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
    _controller._add(this, widget.isHead);
  }

  @override
  void didUpdateWidget(Assist oldWidget) {
    super.didUpdateWidget(oldWidget);

    if(widget.controller != oldWidget.controller){
      oldWidget.controller?.dispose();

      if(widget.controller != null) {
        _controller = widget.controller!;
        _controller._add(this, widget.isHead);
      }
      else {
        _controller = AssistController();
        _controller._add(this, widget.isHead);
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
  static const state$error = 'ErrorState';
  static const state$loading = 'LoadingState';
  static const state$noData = 'NoDataState';
  static const state$noResponse = 'noResponseState';
  static const state$disconnected = 'DisconnectedState';

  /// public list of all assists
  static final List<AssistController> _allControllers = [];

  _AssistState? _headStateRef;
  _AssistState? _selfStateRef;
  final List<_AssistState> _assistStateList = [];
  final List<GroupOfAssist> _groupList = [];
  final List<AssistObserver> _observerList = [];
  final Set<NotifierUpdate> _notifyHeadStateUpdate = {};
  final AssistStateManager _stateManager = AssistStateManager();
  final KeyValueManager _shareDataManager = KeyValueManager();
  final String _shareSection = '_shareSection';

  AssistController(){
    _allControllers.add(this);
  }

  void _add(_AssistState state, bool? isHead){
    if(state.widget.id == null && state.widget.groupIds.isEmpty && state.widget.observable == null){
      if(isHead != null && !isHead && !state.widget.selfControl/*&& _headStateRef == null*/){
        throw Exception('this assist must be a head or have (an id or an groupId or an observer) or be selfControl');
      }
    }

    if(state.widget.selfControl){
      _selfStateRef = state;
    }
    else {
      if((isHead == null && _headStateRef == null) || (isHead != null && isHead)){
        _headStateRef ??= state;
      }

      if(!_assistStateList.contains(state)){
        if(state.widget.id != null){
          final sameId = _getAssist(state.widget.id!);

          if(sameId != null){
            throw Exception('this id [${state.widget.id}] exist in Assist, use other');
          }
        }

        _assistStateList.add(state);
      }
    }


    /// groupId
    if(state.widget.groupIds.isNotEmpty) {
      List<GroupOfAssist> temp = [];

      for (final gId in state.widget.groupIds) {
        var isAddToGroup = false;

        for (final gAssist in _groupList){
          if (gAssist.groupId == gId) {
            gAssist.stateList.add(state);
            isAddToGroup = true;
            break;
          }
        }

        if(!isAddToGroup){
          temp.add(GroupOfAssist.fill(gId, state));
        }
      }

      if(temp.isNotEmpty){
        _groupList.addAll(temp);
      }
    }

    /// observable
    if(state.widget.observable != null){
      addObservable(state.widget.observable!);
    }
  }

  void addHeadListener(NotifierUpdate fn){
    if(!_notifyHeadStateUpdate.contains(fn)) {
      _notifyHeadStateUpdate.add(fn);
    }
  }

  void removeHeadListener(NotifierUpdate fn){
    _notifyHeadStateUpdate.remove(fn);
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

  _AssistState? _getHeadOrSelfState(){
    return _headStateRef?? _selfStateRef;
  }

  _AssistState? _getAssist(String assistId){
    for(final s in _assistStateList){
      if(s.widget.id == assistId){
        return s;
      }
    }

    return null;
  }
  ///.........................................................................
  bool hasState(String state, {String? scopeId}){
    return _stateManager.existState(scopeId?? _shareSection, state);
  }

  bool hasStateIn(String scopeId, String state){
    return _stateManager.existState(scopeId, state);
  }

  bool hasStates(List<String> states, {String? scopeId}){
    return _stateManager.existStates(scopeId?? _shareSection, states);
  }

  bool existAnyStates(List<String> states, {String? scopeId}){
    for(final x in states){
      if(_stateManager.existState(scopeId?? _shareSection, x)){
        return true;
      }
    }

    return false;
  }

  void addState(String state){
    _stateManager.addState(_shareSection, state);
  }

  void addStateWithClear(String state){
    _stateManager.clearStates(_shareSection);
    _stateManager.addState(_shareSection, state);
  }

  void addStateTo({required String state, required String scopeId}){
    _stateManager.addState(scopeId, state);
  }

  void addStateToWithClear({required String state, required String scopeId}){
    _stateManager.clearStates(_shareSection);
    _stateManager.addState(scopeId, state);
  }

  void removeState(String state){
    _stateManager.removeState(_shareSection, state);
  }

  void removeStateFrom({required String state, required String scopeId}){
    _stateManager.removeState(scopeId, state);
  }

  void clearStates({String? scopeId}){
    _stateManager.clearStates(scopeId?? _shareSection);
  }

  void clearStatesFrom(String scopeId){
    _stateManager.clearStates(scopeId);
  }

  void addStateAndUpdateHead(String state, {dynamic data}){
    addState(state);
    updateHead(stateData: data);
  }

  void removeStateAndUpdateHead(String state, {dynamic data}){
    removeState(state);
    updateHead(stateData: data);
  }

  void addStateAndUpdateUnHeads(String state, {dynamic stateData, Duration? delay}){
    addState(state);
    updateUnHeads(stateData: stateData, delay: delay);
  }

  void removeStateAndUpdateUnHeads(String state, {dynamic stateData, Duration? delay}){
    removeState(state);
    updateUnHeads(stateData: stateData, delay: delay);
  }

  void addStateAndUpdateAssist(String state, String assistId, {dynamic stateData, Duration? delay}){
    addState(state);
    updateAssist(assistId, stateData: stateData, delay: delay);
  }

  void removeStateAndUpdateAssist(String state, String assistId, {dynamic stateData, Duration? delay}){
    removeState(state);
    updateAssist(assistId, stateData: stateData, delay: delay);
  }

  void updateSelf({dynamic stateData, Duration? delay}) {
    void fn(){
      (_selfStateRef?? _headStateRef)?.update(data: stateData);
    }

    if(delay == null) {
      fn();
    }
    else {
      Timer(delay, (){fn();});
    }
  }

  void updateHead({dynamic stateData, Duration? delay}) {
    void fn(){
      _headStateRef?.update(data: stateData);

      for(final fn in _notifyHeadStateUpdate){
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

  void updateAssist(String assistId, {dynamic stateData, Duration? delay}){
    void fn(){
      _getAssist(assistId)?.update(data: stateData);
    }

    if(delay == null) {
      fn();
    }
    else {
      Timer(delay, (){fn();});
    }
  }

  void updateGroup(GroupId groupId, {dynamic stateData, Duration? delay}){
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

  void updateUnHeads({dynamic stateData, Duration? delay}){
    void fn(){
      for(final s in _assistStateList){
        if(s != _headStateRef) {
          s.update(data: stateData);
        }
      }
    }

    if(delay == null) {
      fn();
    }
    else {
      Timer(delay, (){fn();});
    }
  }

  Set<State> getGroups(GroupId groupId){
    for(final m in _groupList){
      if(m.groupId == groupId){
        return m.stateList;
      }
    }

    return {};
  }
  ///............. Overlay ......................................................
  void setOverlay(OverlayBuilder? overlay, {String? assistId}){
    if(assistId == null) {
      if(_getHeadOrSelfState() == null){
        return;
      }

      _getHeadOrSelfState()!._overlayBuilder = overlay;
      _getHeadOrSelfState()!.overlayNotifier.value++;
    }
    else {
      _getAssist(assistId)?._overlayBuilder = overlay;
      _getAssist(assistId)?.overlayNotifier.value++;
    }
  }
  ///............. shareDataManager ......................................................
  void setKeyValue(String key, dynamic value){
    _shareDataManager.set(key, value);
  }

  void setValueIfNotExist(String key, dynamic val){
    if(!existKey(key)) {
      setKeyValue(key, val);
    }
  }

  T getValue<T>(String key){
    return _shareDataManager.getValue(key);
  }

  T getValueOr<T>(String key, T defaultVal){
    return _shareDataManager.getValue(key)?? defaultVal;
  }

  bool existKey(String key){
    return _shareDataManager.existKey(key);
  }

  void clearKeyValues(){
    return _shareDataManager.clear();
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
    _shareDataManager.clear();
    _notifyHeadStateUpdate.clear();

    for(final k in _observerList){
      k._remove(this);
    }

    _observerList.clear();
    _headStateRef = null;
    _selfStateRef = null;
  }

  void _widgetIsDisposed(IAssistState state){
    final temp = [];

    for(final s in _assistStateList){
      if(s == state){
        temp.add(s);
      }
    }

    for(final x in temp){
      _assistStateList.remove(x);
    }

    if(state == _headStateRef){
      _headStateRef = null;
    }

    if(state == _selfStateRef){
      _selfStateRef = null;
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

    // no need
    /// means this controller is empty and no control any Assist.
    /*if(_assistStateList.isEmpty){
      dispose();
    }*/
  }
  ///........... commons ...................................................................
  /// if return false: stop
  static void _touchAncestorsToRoot(BuildContext context, bool Function(Element elem) onParent) {
    final e = context as Element;

    e.visitAncestorElements((element) {
      return onParent(element);
    });
  }

  static void updateByClass(Type classType, {dynamic stateData, Duration? delay}){
    for(final c in _allControllers){
      if(c._headStateRef != null){
        _touchAncestorsToRoot(c._headStateRef!.context, (element){
          if(element.widget.runtimeType == classType){
            c.updateHead(stateData: stateData, delay: delay);
            return false;
          }

          return true;
        });
      }
    }
  }

  static void updateAllHeads({dynamic stateData, Duration? delay}){
    for(final c in _allControllers){
      c.updateHead(stateData: stateData, delay: delay);
    }
  }

  static void updateAssistGlobal(String assistId, {dynamic stateData, Duration? delay}){
    for(final c in _allControllers){
      c.updateAssist(assistId, stateData: stateData, delay: delay);
    }
  }

  static void updateGroupGlobal(GroupId groupId, {dynamic stateData, Duration? delay}){
    for(final c in _allControllers){
      c.updateGroup(groupId, stateData: stateData, delay: delay);
    }
  }

  static void updateUnHeadsGlobal({dynamic stateData, Duration? delay}){
    for(final c in _allControllers){
      c.updateUnHeads(stateData: stateData, delay: delay);
    }
  }

  static AssistController? getController(String assistId){
    for(final c in _allControllers){
      for(final ass in c._assistStateList){
        if(ass.widget.id == assistId){
          return ass._controller;
        }
      }
    }

    return null;
  }

  static Set<AssistController> getGroupControllers(GroupId groupId){
    final res = <AssistController>{};

    for(final c in _allControllers){
      for(final ass in c._assistStateList){
        if(ass.widget.groupIds.contains(groupId)){
          res.add(ass._controller);
        }
      }
    }

    return res;
  }
}
///===================================================================================================
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
class AssistStateManager {
  final Map<String, Set<String>> _objList = {};

  AssistStateManager();

  void addState(String section, String state){
    if(existSection(section)){
      getStates(section).add(state);
    }
    else {
      _objList[section] = {state};
    }
  }

  void removeState(String section, String state){
    if(existSection(section)){
      getStates(section).remove(state);
    }
  }

  bool existState(String section, String state){
    return getStates(section).contains(state);
  }

  bool existStates(String section, List<String> states){
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

  Set<String> getStates(String section){
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
      assist.updateUnHeads();
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
///===================================================================================================
abstract class GroupId {}

//enum AS implements GroupId {}