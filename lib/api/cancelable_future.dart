import 'dart:async';

class CancelableFuture<T> {
  bool _isCancelled = false;
  final Completer<T?> _completer = Completer<T?>();


  CancelableFuture(Future<T> future){
    future
        .then((value) {
      if(!_isCancelled && !_completer.isCompleted){
        _completer.complete(value);
      }
    });
  }

  CancelableFuture.timeout(Future<T> future, Duration timeout) {
    future
        .then<T?>((value) => value)
        .timeout(timeout, onTimeout: (){
          if(!_completer.isCompleted){
            _completer.complete(null);
          }

          _isCancelled = true;
          return null;
        })
        .then((value) {
          if(!_isCancelled && !_completer.isCompleted){
            _completer.complete(value);
          }
    });
  }

  Future<T?> get future => _completer.future;

  bool get isCanceled => _isCancelled;

  cancel() {
    _isCancelled = true;
    _completer.complete(null);
  }
}