import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';

class OpenHelper {
  OpenHelper._();

  /// type: "text/plain"
  static Future<OpenResult> openFileBySystem(String path, {String? type}) async {
    return OpenFile.open(path, type: type);
  }

  static Future<OpenResult> openFileByOtherApp(String path){
    return OpenFile.open(path);
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

  static Future<bool> launch(Uri uri) async {
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

    return launch(uri);
  }

  static Future<bool> sendSmsTo(String num) async {
    final sms = Uri(scheme: 'sms', path: num);

    return launch(sms);
  }

  static Future<bool> sendSmsToByBody(String num, String text) async {
    final Uri sms = Uri(scheme: 'sms', path: num, queryParameters: {'sms_body': text});

    return launch(sms);
  }

  /// url:  mailto:smith@example.org?subject=News&body=New%20plugin
  static Future<bool> sendEmail(String emailAddress, String subject) async {
    final Uri emailUri = Uri(
        scheme: 'mailto',
        path: emailAddress,
        queryParameters: {'subject': subject});

    return launch(emailUri);
  }
}
