import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show AssetBundle, rootBundle;

//  Image.asset('assets/images/i1.jpg');

class AssetsManager {
  AssetsManager._();

  static AssetBundle getDefaultAssetBundle(BuildContext context) {
    return DefaultAssetBundle.of(context);
  }

  static AssetBundle getRootBundle() {
    return rootBundle;
  }

  static void evictAssetCash(String assetsPath) {
    return rootBundle.evict(assetsPath);
  }

  // sample: load('assets/fonts/sahel-Black.ttf')
  static Future<ByteData?> load(String assetsPath) async{
    try {
      return rootBundle.load(assetsPath);
    }
    catch (e){
      return null;
    }
  }

  static Future<String?> loadAsString(String assetsPath) async{
    try {
      return rootBundle.loadString(assetsPath);
    }
    catch (e){
      return null;
    }
  }

  static Future<ByteData> loadByContext(BuildContext context, String assetsPath) async {
    return await DefaultAssetBundle.of(context).load(assetsPath);
  }

  static Future<String> loadStringByContext(BuildContext context, String assetsPath) async {
    return await DefaultAssetBundle.of(context).loadString(assetsPath);
  }

  static Future<File> assetsToFile(String assetsPath, String storagePath) async{
    ByteData bytes = await rootBundle.load(assetsPath);
    //String dir = (await getApplicationDocumentsDirectory()).path;
    return writeToFile(bytes, storagePath);
  }

  static Future<File> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return File(path).writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }
}