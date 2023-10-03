import 'dart:async';
import 'memoryCache.dart';

typedef StreamSinkHandler = Function(String key, StreamController streamCtr);
///========================================================================================
class StreamCache {
  StreamCache._();

  static final MemoryCache<StreamController> _cacheHolder = MemoryCache();

  static Future<T?> get<T>(String key, StreamSinkHandler streamSinkHandler) {
    var streamCtr = _cacheHolder.getValue(key);
    final handlerKey = '${key}_fn';

    /// if not exist StreamController, create once and add it.
    if(streamCtr == null || streamCtr.isClosed){
      streamCtr = StreamController.broadcast();
      _cacheHolder.addOrReplace(key, CacheItem(value: streamCtr));
    }

    late StreamSubscription lis;
    final completer = Completer<T?>();

    lis = streamCtr.stream.listen((result) {
      if(result is T) {
        lis.cancel();

        if(!streamCtr!.hasListener) {
          _cacheHolder.deleteCash(key);
          _cacheHolder.deleteCash(handlerKey);
          streamCtr.close();
        }

        completer.complete(result);
      }
    });

    /// if not exist handler, add this
    if(!_cacheHolder.existCash(handlerKey)) {
      _cacheHolder.addKey(handlerKey);
      streamSinkHandler(key, streamCtr);
    }

    return completer.future;
  }
}