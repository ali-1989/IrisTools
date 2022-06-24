import 'dart:io';
import 'package:iris_tools/api/helpers/fileHelper.dart';
import 'package:iris_tools/api/helpers/storageHelper.dart';

String getStoragePath(){
  // /data/user/0/ir.iris.family_bank/code_cache
  return StorageHelper.getFileSystem().systemTempDirectory.path;
}

Future<bool> logToRelativeFile(String filePath, String text, String type) async {
  File f = File(filePath);

  if(!f.existsSync()) {
    await FileHelper.createNewFile(filePath);
  }

  String pr = '$type::$text\n-------------------------\n';
  return f.writeAsString(pr, mode: FileMode.append, flush: true).then((value) => true);
}