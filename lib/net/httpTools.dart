
import 'dart:io';

class HttpTools {
  HttpTools._();

  static void ignoreSslBadHandshake(){
    HttpOverrides.global = MyHttpOverrides();
  }
}
///============================================================================================
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}