import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetManager {
  NetManager._();

  static StreamSubscription? _listener;
  static List<void Function(ConnectivityResult connectivityResult)> _listeners = [];


  static Future<bool> isConnected() async {
    //if(!kReleaseMode)
    //return true;

    var connectivityResult = await Connectivity().checkConnectivity();
    return Future.value(connectivityResult != ConnectivityResult.none);
  }

  static Future<ConnectivityResult> getConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return Future.value(connectivityResult);
  }

  static Future<bool> isMobileDataConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return Future.value(connectivityResult == ConnectivityResult.mobile);
  }

  static Future<bool> isWifiConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return Future.value(connectivityResult == ConnectivityResult.wifi);
  }

  static void addChangeListener(void Function(ConnectivityResult connectivityResult) listener) async {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }

    startConnectionChangeListen();
  }

  static void removeChangeListener(Function listener) async {
    _listeners.remove(listener);

    if (_listeners.length < 1) {
      stopListening();
    }
  }

  static void startConnectionChangeListen() async {
    if (_listener != null && !_listener!.isPaused)
      return;

    _listener?.cancel();

    _listener = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      for (var lis in _listeners) {
        try {
          lis(result);
        } catch (e) {}
      }

      if (_listeners.length < 1) stopListening();
    });
  }

  static void stopListening() {
    _listener?.cancel();
    _listener = null;
  }
}
///===============================================================================================
typedef void OnConnected(bool isWifi);
typedef void OnDisConnected();

class NetListener {
  NetListener._();

  static Map<String, NetListener> _holder = {};
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
    ConnectivityResult r = await NetManager.getConnection();

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
