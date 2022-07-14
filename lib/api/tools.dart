import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:open_file/open_file.dart';

class Tools {
  Tools._();

  static void verbosePrint(dynamic obj){
    if(obj == null){
      return;
    }

    final txt = obj.toString();

    for(int i = 0; i< txt.length; i+= 500){
      print(txt.substring(i, min(i+500, txt.length)));
    }
  }

  static Future<OpenResult> openFileByOtherApp(String path){
    return OpenFile.open(path);
  }

  static Future<bool?> saveImageToGallery(String imgPath){
    return GallerySaver.saveImage(imgPath);
  }

  static Future<bool?> saveVideoToGallery(String vidPath){
    return GallerySaver.saveVideo(vidPath);
  }

  static Future<FilePickerResult?> openPickFiles({bool isMulti = false}){
    return FilePicker.platform.pickFiles(allowMultiple: isMulti);
  }

  static Future<String?> openSaveDirectory({String? title}){
    // not imp: return FilePicker.platform.saveFile(fileName: 'pdfff.pdf');
    return FilePicker.platform.getDirectoryPath(dialogTitle: title);
  }

  /// Android: 21+ , iOS:11+
  static Future<String?> selectDirectory(){
    return FilePicker.platform.getDirectoryPath();
  }
  ///..... Youtube .....................................................................................
  static bool isYoutubeSameUrl(String? link){
    return link != null &&
        (link.contains('youtube.')
        || link.contains('youtu.be'));
  }
  ///..... Toggle btn .....................................................................................
  static List<Widget> generateToggleButtonChildren(Map<String, bool> items, {TextStyle? style}){
    List<Widget> res = [];

    for(var i in items.entries){
      res.add(Text(i.key, style: style,));
    }

    return res;
  }

  static List<bool> getTogglesSelected(Map<String, bool> items){
    var res = <bool>[];

    for(var i in items.entries){
      res.add(i.value);
    }

    return res;
  }

  static void setToggleState(Map<String, bool> items, String key, bool state, {bool others = false}){
    items.updateAll((key, value) => others);
    items[key] = state;
  }

  static void setToggleStateByIndex(Map<String, bool> items, int idx){
    setToggleState(items, items.keys.elementAt(idx), true, others: false);
  }

  static String? getToggleSelectedName(Map<String, bool> items, {String? defValue}){
    for(var i in items.entries){
      if(i.value) {
        return i.key;
      }
    }

    return defValue;
  }
  ///..... Math map .....................................................................................
  static dynamic findByKey(Map<String, dynamic> src, String k, {dynamic ifNotFound}){
    for(var x in src.entries){
      if(x.key == k) {
        return x.value;
      }
    }

    return ifNotFound;
  }

  static dynamic findKeyByValue(Map<dynamic, dynamic> src, dynamic val, {dynamic ifNotFound}){
    for(var x in src.entries){
      if(x.value == val) {
        return x.key;
      }
    }

    return ifNotFound;
  }

}
///******************************************************************************************************************

///******************************************************************************************************************