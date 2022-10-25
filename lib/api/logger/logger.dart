import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:iris_tools/api/helpers/fileHelper.dart';

import 'loggerStub.dart'
  if (dart.library.io) 'loggerMobile.dart'
  if (dart.library.html) 'loggerWeb.dart';

class Logger {
  static Logger? _staticLogger;
  String dirPath;
  String fileName = 'log';
  int counter = 1;

  static Logger get L {
    _staticLogger ??= Logger(getStoragePath(), logName: 'commonLog');
    return _staticLogger!;
  }

  Logger(this.dirPath, {String? logName}): fileName = logName?? 'log';

  Future logToAll(String text, {String type = ''}){
    logToScreen(text, type: type);
    return logToFile(text, type: type);
  }

  Future logToFile(String text, {String type = ''}){
    if(kIsWeb){
      return Future.value();
    }

    return _log(text, type);
  }

  void logToScreen(String text, {String type = ''}){
    if(type.isNotEmpty) {
      print('======> LOG:[$type] $text');
    }
    else {
      print('======> LOG: $text');
    }
  }

  Future<bool> _log(String text, String type) async {
    final path = await getFilePath();

    if(path != null) {
      return logToRelativeFile(path, text, type);
    }

    return false;
  }

  String _ps(){
    try {
      if (kIsWeb) {
        return '/';
      }

      return Platform.pathSeparator;
    }
    catch (e){
      return '/';
    }
  }

  Future<String?> getFilePath() async {
    try {
      final p = '$dirPath${_ps()}$fileName$counter.txt';
      final f = File(p);

      if (!f.existsSync()) {
        final res = await FileHelper.createNewFile(p)
            .then<File?>((value) => value)
            .catchError((e){return null;});

        return res != null? p : null;
      }
      else {
        var size = await f.length();

        if (size < 1024000) {
          return p;
        }

        counter++;
        return getFilePath();
      }
    }
    catch (e){
      print('======> error in logging');
      return null;
    }
  }

  /*void _logToRelativeFile(String filePath, String text, String type) async {
    var f = File(filePath);

    var pr = '$type::$text\n----------------------------\n';
    await f.writeAsString(pr, mode: FileMode.append);
  }*/
}