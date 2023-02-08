import 'package:collection/collection.dart';

/// best way to clone is toMap() & fromMap()

class Clone {
  Clone._();

  static bool deepEquals(Map s1, Map s2){
    return DeepCollectionEquality.unordered().equals(s1, s2);
  }

  static Map<I,J> cloneShallow<I,J>(Map<I, J> src){
    return Map.from(src);
    //return {...src};
    //return src.map((key, value) => MapEntry(key, value));

    //return []..addAll(originalList);
  }

  static dynamic clone<T>(dynamic obj){
    if(obj is List){
      return listDeepCopy(obj).map((e) => e as T).toList();
    }

    if(obj is Set){
      return setDeepCopy(obj) as T;
    }

    if(obj is Map){
      return mapDeepCopy(obj) as T;
    }

    return null;
  }

  static List<T> listDeepCopy<T>(List list){
    final newList = <T>[];

    for (final itm in list) {
      newList.add(
          itm is Map ? mapDeepCopy(itm) :
          itm is List ? listDeepCopy(itm) :
          itm is Set ? setDeepCopy(itm) : itm
      );
    }

    return newList;
  }

  static Set<T> setDeepCopy<T>(Set orgSet){
    final newSet = <T>{};

    for (final itm in orgSet) {
      newSet.add(
          itm is Map ? mapDeepCopy(itm) :
          itm is List ? listDeepCopy(itm) :
          itm is Set ? setDeepCopy(itm) :
          itm
      );
    }

    return newSet;
  }

  static Map<K,V> mapDeepCopy<K,V>(Map map){
    final newMap = <K,V>{};

    map.forEach((key, value){
      newMap[key] = (
      value is Map ? mapDeepCopy(value) :
      value is List ? listDeepCopy(value) :
      value is Set ? setDeepCopy(value) :
      value
      ) /*as V*/;
    });

    return newMap;
  }
}