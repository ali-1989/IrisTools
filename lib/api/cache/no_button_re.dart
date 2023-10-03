class NoButtonRe {
  Future? _future;
  Duration? _duration;
  void Function()? _function;
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

  static NoButtonRe? build({
    required String id,
    void Function()? function,
  }){

    late NoButtonRe i;

    final find = get(id);

    if(find != null){
      i = find;
    }
    else {
      i = NoButtonRe._();
      final r = _NoButtonReItem(id, i);

      _list.add(r);
    }

    i._function = function;

    return i;
  }

  static NoButtonRe? buildDuration({
    required String id,
    Duration duration = const Duration(milliseconds: 1300),
    void Function()? function,
  }){

    late NoButtonRe i;

    final find = get(id);

    if(find != null){
      i = find;
      i._duration = duration;
    }
    else {
      i = NoButtonRe._duration(duration);
      final r = _NoButtonReItem(id, i);

      _list.add(r);
    }

    i._function = function;

      return i;
  }

  static NoButtonRe? buildFuture({
    required String id,
    required Future future,
    void Function()? function,
  }){

    late NoButtonRe i;

    final find = get(id);

    if(find != null){
      i = find;
      i._future = future;
    }
    else {
      i = NoButtonRe._future(future);
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
          _isCalled = false;
        });
      }
      else if(_future != null){
        _future!.then((value) {
          _isCalled = false;
        });
      }

      _function!.call();
    }

    return res;
  }

  set function (void Function()? function) => _function = function;

  void releaseButton(){
    _isCalled = false;
  }

  NoButtonRe._({
    void Function()? function,
  }): _function = function;

 NoButtonRe._duration(this._duration, {
    void Function()? function,
  }): _function = function;

  NoButtonRe._future(this._future, {
    void Function()? function,
  }) : _function = function;
}
///=============================================================================
class _NoButtonReItem {
  String id;
  NoButtonRe noButtonRe;

  _NoButtonReItem(this.id, this.noButtonRe);
}