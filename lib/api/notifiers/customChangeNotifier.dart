import 'package:flutter/foundation.dart';

class CustomChangeNotifier implements Listenable {
  static final List<VoidCallback?> _emptyListeners = List<VoidCallback?>.filled(0, null);
  int _count = 0;
  List<VoidCallback?> _listeners = _emptyListeners;
  int _notificationCallStackDepth = 0;
  int _reEntrantlyRemovedListeners = 0;
  bool _isDisposed = false;
  bool _creationDispatched = false;

  bool get hasListeners => _count > 0;

  @override
  void addListener(VoidCallback listener) {
    if(_isDisposed){
      return;
    }

    if (kFlutterMemoryAllocationsEnabled && !_creationDispatched) {
      MemoryAllocations.instance.dispatchObjectCreated(
        library: 'package:flutter/foundation.dart',
        className: '$CustomChangeNotifier',
        object: this,
      );
      _creationDispatched = true;
    }

    if (_count == _listeners.length) {
      if (_count == 0) {
        _listeners = List<VoidCallback?>.filled(1, null);
      }
      else {
        final List<VoidCallback?> newListeners = List<VoidCallback?>.filled(_listeners.length * 2, null);

        for (int i = 0; i < _count; i++) {
          newListeners[i] = _listeners[i];
        }

        _listeners = newListeners;
      }
    }

    _listeners[_count++] = listener;
  }

  void _removeAt(int index) {
    _count -= 1;

    if (_count * 2 <= _listeners.length) {
      final List<VoidCallback?> newListeners = List<VoidCallback?>.filled(_count, null);

      for (int i = 0; i < index; i++) {
        newListeners[i] = _listeners[i];
      }

      for (int i = index; i < _count; i++) {
        newListeners[i] = _listeners[i + 1];
      }

      _listeners = newListeners;
    }
    else {
      for (int i = index; i < _count; i++) {
        _listeners[i] = _listeners[i + 1];
      }

      _listeners[_count] = null;
    }
  }

  @override
  void removeListener(VoidCallback listener) {
    for (int i = 0; i < _count; i++) {
      final VoidCallback? listenerAtIndex = _listeners[i];

      if (listenerAtIndex == listener) {
        if (_notificationCallStackDepth > 0) {
          // We don't resize the list during notifyListeners iterations
          // but we set to null, the listeners we want to remove. We will
          // effectively resize the list at the end of all notifyListeners
          // iterations.
          _listeners[i] = null;
          _reEntrantlyRemovedListeners++;
        } else {
          // When we are outside the notifyListeners iterations we can
          // effectively shrink the list.
          _removeAt(i);
        }
        break;
      }
    }
  }

  @mustCallSuper
  void dispose() {

    /*assert(
    _notificationCallStackDepth == 0,
    'The "dispose()" method on $this was called during the call to '
        '"notifyListeners()". This is likely to cause errors since it modifies '
        'the list of listeners while the list is being used.',
    );*/

    if(_isDisposed){
      return;
    }

    if (kFlutterMemoryAllocationsEnabled && _creationDispatched) {
      MemoryAllocations.instance.dispatchObjectDisposed(object: this);
    }

    _listeners = _emptyListeners;
    _count = 0;
    _isDisposed = true;
  }

  @pragma('vm:notify-debugger-on-exception')
  void notifyListeners() {
    if (_isDisposed || _count == 0) {
      return;
    }

    _notificationCallStackDepth++;

    final int end = _count;

    for (int i = 0; i < end; i++) {
      try {
        _listeners[i]?.call();
      }
      catch (exception, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'foundation library',
          context: ErrorDescription('while dispatching notifications for $runtimeType'),
          informationCollector: () => <DiagnosticsNode>[
            DiagnosticsProperty<CustomChangeNotifier>(
              'The $runtimeType sending notification was',
              this,
              style: DiagnosticsTreeStyle.errorProperty,
            ),
          ],
        ));
      }
    }

    _notificationCallStackDepth--;

    if (_notificationCallStackDepth == 0 && _reEntrantlyRemovedListeners > 0) {
      // We really remove the listeners when all notifications are done.
      final int newLength = _count - _reEntrantlyRemovedListeners;
      if (newLength * 2 <= _listeners.length) {
        // As in _removeAt, we only shrink the list when the real number of
        // listeners is half the length of our list.
        final List<VoidCallback?> newListeners = List<VoidCallback?>.filled(newLength, null);

        int newIndex = 0;
        for (int i = 0; i < _count; i++) {
          final VoidCallback? listener = _listeners[i];
          if (listener != null) {
            newListeners[newIndex++] = listener;
          }
        }

        _listeners = newListeners;
      }
      else {
        // Otherwise we put all the null references at the end.
        for (int i = 0; i < newLength; i += 1) {
          if (_listeners[i] == null) {
            // We swap this item with the next not null item.
            int swapIndex = i + 1;
            while(_listeners[swapIndex] == null) {
              swapIndex += 1;
            }
            _listeners[i] = _listeners[swapIndex];
            _listeners[swapIndex] = null;
          }
        }
      }

      _reEntrantlyRemovedListeners = 0;
      _count = newLength;
    }
  }
}