class NoButtonRe {
  Future? _future;
  Duration? _duration;
  void Function()? _function;
  void Function()? _onActionCall;
  bool _isCalled = false;

  static final List<_NoButtonReItem> _list = [];

  static NoButtonRe? get(String id){
      for(final i in _list){
        if(i.id == id){
          return i.noButtonRe;
        }
      }

     return null;
  }

  static NoButtonRe build({
    required String id,
    void Function()? function,
    void Function()? onActionsCall,
  }){

    late NoButtonRe i;
    final find = get(id);

    if(find != null){
      i = find;
    }
    else {
      i = NoButtonRe._(onActionCall: onActionsCall);
      final r = _NoButtonReItem(id, i);

      _list.add(r);
    }

    i._function = function;

    return i;
  }

  static NoButtonRe buildDuration({
    required String id,
    Duration duration = const Duration(milliseconds: 1600),
    void Function()? function,
    void Function()? onActionsCall,
  }){

    late NoButtonRe i;
    final find = get(id);

    if(find != null){
      i = find;
      i._duration = duration;
    }
    else {
      i = NoButtonRe._duration(duration, onActionCall: onActionsCall);
      final r = _NoButtonReItem(id, i);

      _list.add(r);
    }

    i._function = function;

      return i;
  }

  static NoButtonRe buildFuture({
    required String id,
    required Future future,
    void Function()? function,
    void Function()? onActionsCall,
  }){

    late NoButtonRe i;
    final find = get(id);

    if(find != null){
      i = find;
      i._future = future;
    }
    else {
      i = NoButtonRe._future(future, onActionCall: onActionsCall);
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
    
    Future.delayed(Duration(seconds: 2), (){
      _list.removeWhere((element) {
        print('remove ${_list.length}');

        if(element.noButtonRe == this){
          print('yeessssssssss ');
        }
        else {
          print('noooooo');
        }

        return element.noButtonRe == this;
      });
    });
  }

  NoButtonRe._({
    void Function()? function,
    void Function()? onActionCall,
  }): _function = function, _onActionCall = onActionCall;

 NoButtonRe._duration(this._duration, {
    void Function()? function,
    void Function()? onActionCall,
  }): _function = function, _onActionCall = onActionCall;

  NoButtonRe._future(this._future, {
    void Function()? function,
    void Function()? onActionCall,
  }) : _function = function, _onActionCall = onActionCall;
}
///=============================================================================
class _NoButtonReItem {
  String id;
  NoButtonRe noButtonRe;

  _NoButtonReItem(this.id, this.noButtonRe);
}