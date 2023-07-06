import 'package:iris_tools/api/helpers/pathHelper.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlHelper {
  UrlHelper._();

  static String contentTypeHeader = 'content-type';
  static String contentLengthHeader = 'content-length';
  static String contentDispositionHeader = 'content-disposition';

  static String? getContentTypeHeader(Map<String, dynamic> headers){
    if(headers is Map<String, String>){
      for(var x in headers.entries){
        if(x.key.toLowerCase() == contentTypeHeader) {
          return x.value;
        }
      }
    }
    else if(headers is Map<String, List<String>>){
      for(var x in headers.entries){
        if(x.key.toLowerCase() == contentTypeHeader) {
          return x.value[0];
        }
      }
    }

    return null;
  }

  static int getContentLengthHeader(Map<String, dynamic> headers){
    if(headers is Map<String, String>){
      for(var x in headers.entries){
        if(x.key.toLowerCase() == contentLengthHeader) {
          return int.parse(x.value);
        }
      }
    }
    else if(headers is Map<String, List<String>>){
      for(var x in headers.entries){
        if(x.key.toLowerCase() == contentLengthHeader) {
          return int.parse(x.value[0]);
        }
      }
    }

    return 0;
  }

  static String? getDispositionHeader(Map<String, dynamic> headers){
    if(headers is Map<String, String>){
      for(var x in headers.entries){
        if(x.key.toLowerCase() == contentDispositionHeader) {
          return x.value;
        }
      }
    }
    else if(headers is Map<String, List<String>>){
      for(var x in headers.entries){
        if(x.key.toLowerCase() == contentDispositionHeader) {
          return x.value[0];
        }
      }
    }

    return null;
  }

  static String getFileNameFromUrl(String? url){
    var filename = '';

    if(url == null) {
      return filename;
    }

    if(url.contains('?')) {
      url = url.split(RegExp(r'\?')).first;
    }

    var pathContents = url.split(RegExp(r'/'));

    var slashLength = pathContents.length;

    var lastPart = pathContents[slashLength-1];
    var lastPartContents = lastPart.split('.');

    if(lastPartContents.length > 1){
      var dotLength = lastPartContents.length;
      var name = '';

      for (var i = 0; i < dotLength; i++) {
        if(i < (lastPartContents.length -1)){
          name += lastPartContents[i];

          if(i < (dotLength -2)){
            name += '.';
          }
        }
      }

      var extension = lastPartContents[dotLength -1];
      filename = '$name.$extension';
    }
    else {
      filename = lastPart;
    }

    return filename;
  }

  static String getFileNameFromHeader(String? disposition){
    if(disposition == null || !disposition.contains('filename')) {
      return '';
    }

    var res = disposition.split(RegExp('filename(.)?='))[1].split(RegExp('[;\n]|\$'))[0];

    return res.replaceAll("'", '').replaceAll('"', '');
  }

  static String? resolveUri(String? uri) {
    if(uri == null) {
      return null;
    }

    //return uri.replaceAll(RegExp('/{2,}'), "/").replaceFirst(':\/', ':\/\/');
    uri = PathHelper.remove2Slash(uri)!;
    return uri.replaceFirst(RegExp('^/http'), 'http');
  }
  ///==============================================================================================
  static String? encodeUrl(String url) {
    try {
      return Uri.encodeFull(url);
    }
    catch (e) {
    return null;
    }
  }

  static String? decodeUrl(String? url) {
    try {
      return Uri.decodeFull(url!);
    }
    catch (e) {
    return null;
    }
  }

  static String? removeDomain(String url, {bool keepFirstSlash = true}) {
    try {
      final reg = RegExp('^http[s]?://.+?/');
      return url.replaceFirst(reg, keepFirstSlash? '/' : '');
    }
    catch (e) {
      return null;
    }
  }

  static String? encodeFilePathForDataBase(String path) {
    return encodeUrl(path);
  }

  static String? decodePathFromDataBase(String dbPath) {
    return decodeUrl(dbPath);
  }

  static String? resolveUrl(String address) {
    try {
      //no need for Url:  if (SystemMaster.isUnix()) {
      address = address.replaceAll(RegExp(r'\\'), '/'); //for windows
      address = PathHelper.remove2Slash(address)!;

      //address = PathHelper.removePathSeparateFromEnd(address);
      return address;
    }
    catch (e) {
    return null;
    }
  }

  static String? osLocalPathToDatabase(String filePath) {
    try {
      return encodeFilePathForDataBase(filePath);
    } catch (e) {
    return null;
    }
  }

  /// forBackToApp: mode: LaunchMode.externalApplication
  static Future<bool> launchLink(String url, {
    LaunchMode mode = LaunchMode.platformDefault,
    WebViewConfiguration webViewConfiguration = const WebViewConfiguration(),
  }) async {
    try {
      final Uri uri = Uri.parse(url);
      return await launchUrl(uri, mode: mode, webViewConfiguration: webViewConfiguration);
    }
    catch (e) {
      return false;
    }
  }

  static Future<bool> launchWeb(String url, {
    LaunchMode mode = LaunchMode.platformDefault,
    WebViewConfiguration webViewConfiguration = const WebViewConfiguration(),
  }) async {
    if(!url.toLowerCase().startsWith('http')){
      url = 'http://$url';
    }

    return launchLink(url, mode: mode, webViewConfiguration: webViewConfiguration);
  }
}