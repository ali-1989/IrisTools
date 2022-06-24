import 'dart:io';
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
    return _log(text, type);
  }

  void logToScreen(String text, {String type = ''}){
    if(type.isNotEmpty) {
      print('LOG:[$type] $text');
    }
    else {
      print('$text');
    }
  }

  Future _log(String text, String type) async{
    return logToRelativeFile(await getFilePath(), text, type);
  }

  Future<String> getFilePath() async{
    var p = dirPath + Platform.pathSeparator + '$fileName$counter.txt';
    var f = File(p);

    if(!f.existsSync()) {
      await FileHelper.createNewFile(p);
      return p;
    }
    else {
      var size = await f.length();

      if(size < 1024000){
        return p;
      }

      counter++;
      return getFilePath();
    }
  }

  /*void _logToRelativeFile(String filePath, String text, String type) async {
    var f = File(filePath);

    var pr = '$type::$text\n----------------------------\n';
    await f.writeAsString(pr, mode: FileMode.append);
  }*/
}