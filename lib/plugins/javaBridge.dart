import 'package:flutter/services.dart';

typedef ReceiveFromAndroid = Future<dynamic> Function(MethodCall call);
///================================================================================
class JavaBridge {
  late MethodChannel javaPlatform;
  late String _channelName;  //'myApp/AndroidBridge'
  bool isInitial = false;

  JavaBridge();

  void init(String channelName, ReceiveFromAndroid receiveFromAndroid){
    _channelName = channelName;
    javaPlatform = MethodChannel(_channelName);
    javaPlatform.setMethodCallHandler(receiveFromAndroid);
    isInitial = true;
  }

  Future<(T?, Exception?)> invokeMethod<T>(String methodName) async {
    if(!isInitial) {
      return (null, Exception('JavaBridge is not Initial.'));
    }

    try {
      return ((await javaPlatform.invokeMethod(methodName) as T), null);
    }
    //on PlatformException catch (e) {
    catch (e) {
      return (null, Exception("Failed to Invoke $methodName: '$e'."));
    }
  }

  // invokeMethodByArgs('isInStorageSD1', ['/storage/746D-2CBD/Android'])
  Future<Object?> invokeMethodByArgs(String methodName, List<dynamic> args) async {
    if(!isInitial) {
      return (null, Exception('JavaBridge is not Initial.'));
    }

    try {
      return ((await javaPlatform.invokeMethod(methodName, args)), null);
    }
    catch (e) {
      return (null, Exception("Failed to Invoke $methodName: '$e'."));
    }
  }

  /*Future<dynamic> receiveFromAndroid(MethodCall call) async {
    switch (call.method) {
      case 'hi':
        return Future.value('ok');
    }
  }*/



  /*Future isWritableStorageCards(){
    return invokeMethod('isWritableStorageCards');
  }

  Future getSdPath(){
    return invokeMethod('SdPath');
  }

  Future getShareStorage(){
    return invokeMethod('ShareStorage');
  }

  Future getSdAppDir(){
    return invokeMethod('SdAppDir');
  }

  Future getShareAppDir(){
    return invokeMethod('ShareAppDir');
  }

  Future getInternalAppDir(){
    return invokeMethod('InternalAppDir');
  }

  Future<String> getDatabaseDir(){
    return invokeMethod('DatabaseDir');
  }

  Future createFile(String path){
    return invokeMethodByArgs('CreateFile', [path]);
  }*/
}