import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetManager {
  NetManager._();

  static StreamSubscription? _listener;
  static final List<void Function(List<ConnectivityResult> connectivityResult)> _listeners = [];


  static Future<bool> isConnected() async {
    //if(!kReleaseMode)
    //return true;

    final connectivityResult = await Connectivity().checkConnectivity();

    return Future.value(!connectivityResult.contains(ConnectivityResult.none));
  }

  static Future<List<ConnectivityResult>> getConnections() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return Future.value(connectivityResult);
  }

  static Future<bool> isMobileDataConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return Future.value(connectivityResult.contains(ConnectivityResult.mobile));
  }

  static Future<bool> isWifiConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return Future.value(connectivityResult.contains(ConnectivityResult.wifi));
  }

  static Future<bool> isVpn() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return Future.value(connectivityResult.contains(ConnectivityResult.vpn));
  }

  static Future<bool> isBluetooth() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return Future.value(connectivityResult.contains(ConnectivityResult.bluetooth));
  }

  static void addChangeListener(void Function(List<ConnectivityResult> connectivityResult) listener) async {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }

    startConnectionChangeListen();
  }

  static void removeChangeListener(Function listener) async {
    _listeners.remove(listener);

    if (_listeners.isEmpty) {
      stopListening();
    }
  }

  static void startConnectionChangeListen() async {
    if (_listener != null && !_listener!.isPaused) {
      return;
    }

    _listener?.cancel();

    _listener = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      for (final lis in _listeners) {
        try {
          lis(result);
        } catch (e) {}
      }

      if (_listeners.isEmpty) stopListening();
    });
  }

  static void stopListening() {
    _listener?.cancel();
    _listener = null;
  }
}
///=============================================================================
typedef OnConnected = void Function(bool isWifi);
typedef OnDisConnected = void Function();

class NetListener {
  NetListener._();

  static final Map<String, NetListener> _holder = {};
  bool _isActive = false;
  bool _isPurge = false;
  int _callCount = 0;
  ConnectivityResult _oldState = ConnectivityResult.none;
  ConnectivityResult _currentState = ConnectivityResult.none;
  OnConnected? onConnected;
  OnDisConnected? onDisConnected;


  factory NetListener(String name) {
    //old: if (name == null) throw Exception('name is null for NetListener.');

    if (_holder.containsKey(name)) {
      return _holder[name]!;
    }

    NetListener obj = NetListener._();
    _holder[name] = obj;

    return obj;
  }

  int get callCount => _callCount;
  bool get isActive => _isActive;
  ConnectivityResult get currentState => _currentState;
  ConnectivityResult get oldState => _oldState;

  void listenIfNot() async {
    if (_isActive || _isPurge) {
      return;
    }

    //if (_isPurge) throw Exception('this NetListener is purge.');

    _isActive = true;
    final r = await NetManager.getConnections();

    NetManager.addChangeListener(_onChangeConnection);
    _onChangeConnection(r);
  }

  void listenForce() async {
    _isActive = false;
    _isPurge = false;

    listenIfNot();
  }

  void stop() {
    NetManager.removeChangeListener(_onChangeConnection);
    _isActive = false;
  }

  void purge() {
    stop();
    _holder.removeWhere((name, listener) => listener == this);
    onConnected = null;
    onDisConnected = null;
    _isPurge = true;
  }

  void _onChangeConnection(connectivityResult) {
    if(!_isActive){
      return;
    }

    _currentState = connectivityResult;
    _callCount++;

    if (connectivityResult == ConnectivityResult.none) {
      onDisConnected?.call();
    } else {
      onConnected?.call(connectivityResult == ConnectivityResult.wifi);
    }

    _oldState = connectivityResult;
  }
}
///===============================================================================================
