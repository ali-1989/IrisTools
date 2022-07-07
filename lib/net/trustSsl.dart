import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class TrustAllCertificates {

  static http.Client getTrustClint() {
    var ioClient = HttpClient()..badCertificateCallback = (X509Certificate cert, String host, int port) {
      return true;//host.startsWith('https://appapi');
    };

    return IOClient(ioClient);
  }

  static Future acceptBadCertificateByPem() async {
    ByteData data = await PlatformAssetBundle().load('assets/raw/lets-encrypt-r3.pem');
    SecurityContext.defaultContext.setTrustedCertificatesBytes(data.buffer.asUint8List());
  }

  static Future acceptBadCertificate() async {
    HttpOverrides.global = MyHttpOverrides();
  }
}
///=================================================================================================
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}