import 'package:flutter/foundation.dart';

typedef PropertyCallback<T> = void Function(T?);
///================================================================================================
class PropertyChangeNotifier<Pro> extends ChangeNotifier {
  static final List<PropertyNotifierHandler> _listeners = [];

  @override
  //@protected
  //@visibleForTesting
  bool get hasListeners {
    return _listeners.isNotEmpty;
  }

  @override
  void addListener(Function listener, [PropertyNotifierHandler? obj]) {
    assert(listener is VoidCallback || listener is PropertyCallback<Pro>,
      'Listener must be a Function() or Function(T?)');

    obj ??= PropertyNotifierHandler();

    obj._fn = listener;
    obj._myHash = hashCode;

    _listeners.add(obj);
  }

  @override
  void removeListener(Function listener, [Iterable<Pro>? properties]) {
    final removes = <PropertyNotifierHandler>[];

    for (final handler in _listeners) {
      if (handler._fn == listener) {
        removes.add(handler);
      }
    }

    for (final handler in removes) {
      _listeners.remove(handler);
    }
  }

  @override
  @mustCallSuper
  void dispose() {
    _listeners.clear();

    super.dispose();
  }

  @override
  @protected
  @visibleForTesting
  void notifyListeners([Pro? property]) {
    assert(property is! Iterable, 'notifyListeners() should only be called for one property at a time');

    for (final handler in _listeners) {
      if(handler.modelType != runtimeType){
        continue;
      }

      if (handler.onAnyInstance) {
        if(handler.onAnyProperty) {
          _callListener(handler, property);
        }
        else {
          if(handler.properties.contains(property)) {
            _callListener(handler, property);
          }
        }
      }
      else {
        if (handler._myHash == hashCode) {
          if(handler.onAnyProperty) {
            _callListener(handler, property);
          }
          else {
            if(handler.properties.contains(property)) {
              _callListener(handler, property);
            }
          }
        }
      }
    }
  }

  void _callListener(PropertyNotifierHandler handler, Pro? property){
    if (handler._fn is PropertyCallback<Pro>) {
      handler._fn?.call(property);
    }
    else {
      handler._fn?.call();
    }
  }

  /// Reimplemented from [ChangeNotifier].
  bool _debugAssertNotDisposed() {
    return true;
  }
}

class PropertyNotifierHandler<Pro> {
  bool onAnyInstance = false;
  bool onAnyProperty = false;
  Function? _fn;
  int? _myHash;
  Type? modelType;
  final List<Pro> properties = [];
}
