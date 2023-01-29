import 'dart:async';

/*
  if(!AppManager.timeoutCache.addTimeout('getUtcTimeOfServer', Duration(seconds: 5))){
      return Future.value(false);
    }
 */

class TimeoutCache {
  final List<MapEntry<String, dynamic>> _timers = [];

  TimeoutCache();

  void clearAll(){
    _timers.clear();
  }

  void deleteTimeout(String key){
    _timers.removeWhere((element) => element.key == key);
  }

  bool addTimeout(String key, Duration dur, {dynamic value}){
    for(final x in _timers){
      if(x.key == key) {
        return false;
      }
    }

    _timers.add(MapEntry<String, dynamic>(key, value));

    Timer(dur, (){
      _timers.removeWhere((element) => element.key == key);
    });

    return true;
  }

  bool existTimeout(String key){
    for(final x in _timers){
      if(x.key == key) {
        return true;
      }
    }
    return false;
  }
}
