//import 'dart:html';
import 'package:file/src/backends/memory.dart';

String getStoragePath(){
  return MemoryFileSystem().systemTempDirectory.path;
}

Future<bool> logToRelativeFile(String filePath, String text, String type){
  return Future.value(true);
}