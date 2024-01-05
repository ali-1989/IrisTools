import 'dart:async';

class NoButtonReCall {
  static final List<_NoButtonReItem> _list = [];
  Future? _future;
  Duration? _duration;
  void Function()? _function;
  final void Function()? _onActionCall;
  bool _isCalled = false;

  static Timer? _timer;

  static NoButtonReCall? get(String id){
    _checkTimer();

    for(final i in _list){
      if(i.id == id){
        return i.noButtonRe;
      }
    }

    return null;
  }

  static NoButtonReCall build({
    required String id,
    void Function()? function,
    void Function()? onActionsCall,
  }){

    late NoButtonReCall i;
    final find = get(id);

    if(find != null){
      i = find;
    }
    else {
      i = NoButtonReCall._(onActionCall: onActionsCall);
      final r = _NoButtonReItem(id, i);

      _list.add(r);
    }

    i._function = function;

    return i;
  }

  static NoButtonReCall buildDuration({
    required String id,
    Duration duration = const Duration(milliseconds: 1600),
    void Function()? function,
    void Function()? onActionsCall,
  }){

    late NoButtonReCall i;
    final find = get(id);

    if(find != null){
      i = find;
      i._duration = duration;
    }
    else {
      i = NoButtonReCall._duration(duration, onActionCall: onActionsCall);
      final r = _NoButtonReItem(id, i);

      _list.add(r);
    }

    i._function = function;

    return i;
  }

  static NoButtonReCall buildFuture({
    required String id,
    required Future future,
    void Function()? function,
    void Function()? onActionsCall,
  }){

    late NoButtonReCall i;
    final find = get(id);

    if(find != null){
      i = find;
      i._future = future;
    }
    else {
      i = NoButtonReCall._future(future, onActionCall: onActionsCall);
      final r = _NoButtonReItem(id, i);

      _list.add(r);
    }

    i._function = function;

    return i;
  }

  void Function()? get function {
    if(_isCalled || _function == null){
      return null;
    }

    void res(){
      if(_isCalled){
        return;
      }

      _isCalled = true;

      if(_duration != null){
        Future.delayed(_duration!, (){
          releaseButton();
        });
      }
      else if(_future != null){
        _future!.then((value) {
          releaseButton();
        });
      }

      _function!.call();
      _onActionCall?.call();
    }

    return res;
  }

  set function (void Function()? function) => _function = function;

  void releaseButton(){
    _isCalled = false;
    _onActionCall?.call();
  }

  static void _checkTimer(){
    if(_timer == null || !_timer!.isActive){
      if(_list.isNotEmpty){
        _timer = Timer.periodic(Duration(minutes: 5), (timer) {
          clear();
        });
      }
    }
  }
  static void clear(){
    _list.removeWhere((element) {
      return element.noButtonRe._isCalled == false;
    });

    if(_list.isEmpty && _timer != null && _timer!.isActive){
      _timer!.cancel();
      _timer = null;
    }
  }

  NoButtonReCall._({
    void Function()? function,
    void Function()? onActionCall,
  }): _function = function, _onActionCall = onActionCall;

 NoButtonReCall._duration(this._duration, {
    void Function()? function,
    void Function()? onActionCall,
  }): _function = function, _onActionCall = onActionCall;

  NoButtonReCall._future(this._future, {
    void Function()? function,
    void Function()? onActionCall,
  }) : _function = function, _onActionCall = onActionCall;
}
///=============================================================================
class _NoButtonReItem {
  String id;
  NoButtonReCall noButtonRe;

  _NoButtonReItem(this.id, this.noButtonRe);
}