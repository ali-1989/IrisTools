import 'dart:async';
import 'memoryCache.dart';

typedef StreamFn = Function(String key, StreamController streamCtr);
///========================================================================================
class StreamCache {
  StreamCache._();

  static final MemoryCache<StreamController> _holder = MemoryCache();

  static Future<T?> get<T>(String key, StreamFn streamFn) {
    var stream = _holder.getValue(key);

    if(stream == null || stream.isClosed){
      stream = StreamController.broadcast();
      _holder.addOrReplace(key, CacheItem(value: stream));
    }

    StreamSubscription? lis;
    final completer = Completer<T?>();

    lis = stream.stream.listen((event) {
      if(event is T) {
        lis?.cancel();

        if(!stream!.hasListener) {
          _holder.deleteCash('${key}fn');
          stream.close();
        }

        completer.complete(event);
      }
    });

    if(!_holder.existCash('${key}fn')) {
      _holder.addKey('${key}fn');
      streamFn(key, stream);
    }

    return completer.future;
  }
}