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
    }).onError((error, stackTrace) {
      if (!_isCancelled && !_completer.isCompleted) {
        _completer.completeError(error!, stackTrace);
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
      }).onError((error, stackTrace) {
        if(!_isCancelled && !_completer.isCompleted){
          _completer.completeError(error!, stackTrace);
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

/*------------------------------
Future<int> tenCounter() async {
    int i = 0;

    while(i < 10){
      i++;
      print('i: $i');
      await Future.delayed(const Duration(seconds: 1));

      if(i == 4){
        throw Exception(' ohh ');
      }
    }

    return i;
  }



  final i = await tenCounter()
          .timeout(Duration(seconds: 8), onTimeout: () {
        print('timeooooooooout');
        return -1;
      });
 */