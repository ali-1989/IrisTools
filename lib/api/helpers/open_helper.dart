import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';

class OpenHelper {
  OpenHelper._();

  /// type: "text/plain"
  static Future<OpenResult> openFile(String path, {String? type}) async {
    return OpenFile.open(path, type: type);
  }

  static Future<bool> launchFile(String path) async {
    final uri = Uri(
      scheme: 'file',
      path: path,
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        webOnlyWindowName: ' ',
        mode: LaunchMode.externalApplication,
      );

      return true;
    }
    else {
      return false;
    }
  }

  static Future<bool> launchUri(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      return true;
    }
    else {
      return false;
    }
  }

  /// url: https://flutter.dev
  static Future<bool> launchInBrowser(String url, {Map<String, String>? headers}) async {
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webViewConfiguration: WebViewConfiguration(
            headers: headers?? {},
        ),
      );

      return true;
    }
    else {
      return false;
    }
  }

  static Future<bool> launchInWebView(String url, {Map<String, String>? headers}) async {
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.inAppWebView,
        webViewConfiguration: WebViewConfiguration(
          headers: headers?? {},
        ),
      );

      return true;
    }
    else {
      return false;
    }
  }

  /// num: +1 555 010 999
  static Future<bool> makePhoneCall(String num) async {
    final uri = Uri.parse('tel://$num');

    return launchUri(uri);
  }

  static Future<bool> sendSmsTo(String num) async {
    final sms = Uri(scheme: 'sms', path: num);

    return launchUri(sms);
  }

  static Future<bool> sendSmsToByBody(String num, String text) async {
    final sms = Uri(
        scheme: 'sms',
        path: num,
        queryParameters: {'body': text}
    );

    return launchUri(sms);
  }

  /// url:  mailto:smith@example.org?subject=News&body=New%20plugin
  static Future<bool> sendEmail(String emailAddress, String subject) async {
    final emailUri = Uri(
        scheme: 'mailto',
        path: emailAddress,
        query: _encodeQueryParameters({'subject': subject, 'body': 'hi'}),
    );

    return launchUri(emailUri);
  }

  static String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries.map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&');
  }
}
