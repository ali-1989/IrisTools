import 'dart:async';
import 'package:flutter/material.dart';

/* Hlp:
enum Keys implements GroupId {
  voicePlayerGroupId$vocabClickable(120);

  final int _number;

  const Keys(this._number);

  int getNumber(){
    return _number;
  }
}
 */


typedef UpdaterBuilderFn = Widget Function(BuildContext context, UpdaterController controller, dynamic stateData);
typedef UpdaterOverlayBuilder = Widget Function(BuildContext context, UpdaterController controller);
typedef GroupIds<T extends UpdaterGroupId> = T;
///=============================================================================
class UpdaterBuilder<T extends Updater, E extends EventScope> extends StatefulWidget {
  final String? id;
  /// define a (enum or class) that implements GroupId {}
  final List<GroupIds> groupIds;
  //final dynamic groupScope;
  final List<EventScope> eventScopes;//todo. <E>
  final UpdaterObserve? observable;
  final UpdaterBuilderFn builder;
  final UpdaterOverlayBuilder? overlayBuilder;
  final T? _typeDetector = null;


  UpdaterBuilder({
    super.key,
    this.id,
    this.groupIds = const [],
    this.eventScopes = const [],
    this.observable,
    this.overlayBuilder,
    required this.builder,
  })
      : super();

  @override
  State<StatefulWidget> createState() {
    return _UpdaterBuilderState();
  }
}
///=============================================================================
abstract class IUpdaterState<w extends StatefulWidget> extends State<w> {
  void update({dynamic data});
  void disposeWidget();
}
///=============================================================================
class _UpdaterBuilderState extends IUpdaterState<UpdaterBuilder> {
  late UpdaterController _controller;
  late ValueNotifier<int> _overlayNotifier;
  dynamic _lastData;

  dynamic get lastData => _lastData;

  @override
  void initState() {
    super.initState();
    _overlayNotifier = ValueNotifier(0);
    _controller = UpdaterController();
    _controller._add(this);
  }

  @override
  void didUpdateWidget(UpdaterBuilder oldWidget) {
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

    final elem = (context as Element);

    if(mounted && !elem.dirty) {
      setState(() {});
    }
  }

  @override
  void disposeWidget() {
    dispose();
  }
}
///=============================================================================
class UpdaterController<S> {
  /// public list of all updater
  static final List<UpdaterController> _allControllers = [];
  static final List<_GroupListenerHolder> _allGroupListenerFn = [];
  static final Map<UpdaterGroupId, dynamic> _updaterDataHolder = {};
  static final _ItemCache<int> _idsCache = _ItemCache();

  late _UpdaterBuilderState _stateRef;
  final _stateManager = UpdaterStateManager<S>();
  final KeyValueManager _kvManager = KeyValueManager();
  final String _stateShareSection = '_stateShareSection';

  UpdaterController();

  void _add(_UpdaterBuilderState state){
    if(state.widget.id != null) {
      final sameId = UpdaterController._forId(state.widget.id!);

      if (sameId != null) {
        final elem = (sameId._stateRef.context as Element);

        /// if UpdaterBuilder be wrapping in other Widget when coding, must ignore else on SetState take error.
        if(elem.dirty){
          sameId.dispose();
        }
        else {
          throw Exception('this id [${state.widget.id}] exist in Updater, use other id');
        }
      }
    }

    _stateRef = state;
    _allControllers.add(this);
    state.widget.observable?._add(this);

    _idsCache.add(state.hashCode);
  }

  BuildContext? getContext(){
    return _stateRef.context;
  }

  static UpdaterController? _forId(String updaterId){
    for(final c in _allControllers){
      if(c._stateRef.widget.id == updaterId){
        return c;
      }
    }

    return null;
  }

  static UpdaterController? forId(String updaterId){
    for(final c in _allControllers){
      if(c._stateRef.widget.id == updaterId && !_idsCache.exist(c.hashCode)){
        return c;
      }
    }

    return null;
  }

  static Set<UpdaterController> forType<T extends Updater>({List<EventScope>? scopes}){
    final res = <UpdaterController>{};

    for(final c in _allControllers){
      if(c._stateRef.widget._typeDetector.runtimeType == T && !_idsCache.exist(c.hashCode)){
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

  static Set<UpdaterController> forGroup(UpdaterGroupId groupId, {dynamic gScope}){
    final res = <UpdaterController>{};

    for(final c in _allControllers){
      if(c._stateRef.widget.groupIds.contains(groupId) && !_idsCache.exist(c.hashCode)){
        res.add(c);
      }
    }

    return res;
    // if(c._stateRef.widget.groupScope != null){ if(c._stateRef.widget.groupScope == gScope)
  }

  static void updateById(String updaterId, {dynamic stateData, Duration? delay}){
    forId(updaterId)?.update(stateData: stateData, delay: delay);
  }

  static void updateByGroup(UpdaterGroupId groupId, {dynamic groupScope, dynamic data, Duration? delay}){
    _updaterDataHolder[groupId] = data;

    for(final i in _allGroupListenerFn){
      if(i.hasGroupId(groupId)){
        i.fn.call(groupId);
      }
    }

    forGroup(groupId, gScope: groupScope).forEach((element) {
      element.update(stateData: data, delay: delay);
    });
  }

  static dynamic lastGroupDataFor(UpdaterGroupId groupId){
    return _updaterDataHolder[groupId];
  }

  static dynamic deleteGroupDataFor(UpdaterGroupId groupId){
    return _updaterDataHolder.remove(groupId);
  }

  static void updateByType<T extends Updater>({List<EventScope>? scopes, dynamic stateData, Duration? delay}){
    forType(scopes: scopes).forEach((element) {
      element.update(stateData: stateData, delay: delay);
    });
  }
  ///............. group listener ..............................................
  static void addGroupListener(List<UpdaterGroupId> ids, void Function(UpdaterGroupId) fn){
    for(final i in _allGroupListenerFn){
      if(i.isSame(ids, fn)){
        return;
      }
    }

    final lis = _GroupListenerHolder();
    lis.groupIds = ids;
    lis.fn = fn;

    _allGroupListenerFn.add(lis);
  }

  static void removeGroupListener(void Function(UpdaterGroupId) fn){
    _allGroupListenerFn.removeWhere((element) => element.fn == fn);
  }
  ///............. Overlay .....................................................
  void updateOverlay(){
    _stateRef._overlayNotifier.value++;
  }
  ///............. states .......................................................
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
  ///............. shareDataManager ............................................
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
  ///...........................................................................
  void dispose() {
    _allControllers.remove(this);
    _stateRef.widget.observable?._remove(this);
    _kvManager.clear();
  }

  void _widgetIsDisposed(IUpdaterState state){
    dispose();
  }
}
///=============================================================================
mixin class Updater {
  void emit<T extends Updater>({List<EventScope>? scopes, dynamic data}){
    UpdaterController.updateByType<T>(scopes: scopes, stateData: data);
  }
}

abstract class EventScope {}
///=============================================================================
abstract class UpdaterGroupId {}
//enum Or Class implements GroupId {}
///=============================================================================
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
///=============================================================================
class UpdaterStateManager<T> {
  final Map<String, Set<T>> _objList = {};

  UpdaterStateManager();

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
///=============================================================================
class UpdaterObserve<T> {
  T? _value;
  final List<UpdaterController> _observers = []; // = listeners

  UpdaterObserve([T? value]) :_value = value;

  T? get value => _value;

  void changeValue(T? value){
    _value = value;
  }

  void notify(){
    for(final ob in _observers){
      ob.update();
    }
  }

  void changeAndNotify(T? value){
    _value = value;
    notify();
  }

  bool hasListeners(){
    return _observers.isNotEmpty;
  }

  List<UpdaterController> get listeners {
    return _observers;
  }

  void _add(UpdaterController controller){
    if(!_observers.contains(controller)){
      _observers.add(controller);
    }
  }

  void _remove(UpdaterController controller){
    _observers.remove(controller);
  }
}
///=============================================================================
class _GroupListenerHolder {
  List<UpdaterGroupId> groupIds = [];
  late void Function(UpdaterGroupId groupId) fn;

  bool hasGroupId(UpdaterGroupId groupId){
    return groupIds.contains(groupId);
  }

  bool isSame(List<UpdaterGroupId> ids, void Function(UpdaterGroupId p1) fn) {
    return this.fn == fn && groupIds.length == ids.length && groupIds.every((element) => ids.contains(element));
  }
}
///=============================================================================
class _ItemCache<T> {
  _ItemCache();

  final Map<T, DateTime> _list = {};
  Timer? _timer;

  void add(T itm){
    if(!_list.keys.contains(itm)){
      _list[itm] = DateTime.now();
    }

    _startTimer();
  }

  bool exist(int id){
    return _list.keys.contains(id);
  }

  void _startTimer(){
    if(_timer == null || !_timer!.isActive){
      _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
        final nowTime = DateTime.now().subtract(Duration(milliseconds: 100));

        _list.removeWhere((key, value) {
          return value.isAfter(nowTime);
        });

        if(_list.isEmpty){
          _timer?.cancel();
          _timer = null;
        }
      });
    }
  }
}
