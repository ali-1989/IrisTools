import 'package:flutter/services.dart';

class JavaBridge {
  JavaBridge._();

  static late MethodChannel javaPlatform;
  static bool isInitial = false;

  static void _init(){
    javaPlatform = MethodChannel('myApp/AndroidBridge');
    javaPlatform.setMethodCallHandler(receiveFromAndroid);
    isInitial = true;
  }

  static Future<T> invokeMethod<T>(String methodName) async {
    try {
      if(!isInitial) {
        _init();
      }

      return await javaPlatform.invokeMethod(methodName);
    }
    //on PlatformException catch (e) {
    catch (e) {
      return "Failed to Invoke $methodName: '$e'." as T;
    }
  }

  // invokeMethodByArgs('isInStorageSD1', ['/storage/746D-2CBD/Android'])
  static Future<Object?> invokeMethodByArgs(String methodName, List<dynamic> args) async {
    try {
      if(!isInitial) {
        _init();
      }

      return await javaPlatform.invokeMethod(methodName, args);
    }
    on PlatformException catch (e) {
      return "Failed to Invoke $methodName: '${e.message}'.";
    }
  }
  //===========================================================================================================
  // called from java to flutter
  static Future<dynamic> receiveFromAndroid(MethodCall call) async {
    switch (call.method) {
      case 'hi':
        return Future.value('ok');
    }
  }
  //===========================================================================================================
  static Future isWritableStorageCards(){
    return invokeMethod('isWritableStorageCards');
  }

  static Future getSdPath(){
    return invokeMethod('SdPath');
  }

  static Future getShareStorage(){
    return invokeMethod('ShareStorage');
  }

  static Future getSdAppDir(){
    return invokeMethod('SdAppDir');
  }

  static Future getShareAppDir(){
    return invokeMethod('ShareAppDir');
  }

  static Future getInternalAppDir(){
    return invokeMethod('InternalAppDir');
  }

  static Future<String> getDatabaseDir(){
    return invokeMethod('DatabaseDir');
  }

  static Future createFile(String path){
    return invokeMethodByArgs('CreateFile', [path]);
  }
}