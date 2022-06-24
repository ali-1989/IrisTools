import 'package:flutter/services.dart';

class ClipboardHelper {
  ClipboardHelper._();

  static Future<void> insert(String text){
    return Clipboard.setData(ClipboardData(text: text,));
  }

  static Future<ClipboardData?> read(){
    return Clipboard.getData(Clipboard.kTextPlain);
  }

  static Future<String?> readText() async{
    ClipboardData? c = await Clipboard.getData(Clipboard.kTextPlain);
    return c?.text;
  }
}