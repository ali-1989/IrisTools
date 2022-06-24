import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';

class Launcher {
  Launcher._();

  /// type: "text/plain"
  static Future<OpenResult> openFileBySystem(String path, {String? type}) async {
    return OpenFile.open(path, type: type);
  }

  /// url: https://flutter.dev
  static Future<void> launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
      );
    } else {
      return Future.error('can not launch');
    }
  }

  static Future<void> launchInBrowserByHeaders(
      String url, Map<String, String> headers) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: headers,
      );
    } else {
      return Future.error('can not launch');
    }
  }

  static Future<void> launchInWebViewOrVC(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        enableJavaScript: true,
        forceSafariVC: true,
        forceWebView: true,
      );
    } else {
      return Future.error('can not launch');
    }
  }

  static Future<void> launchInWebViewOrVCByHeaders(
      String url, Map<String, String> headers) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        enableJavaScript: true,
        forceSafariVC: true,
        forceWebView: true,
        headers: headers,
      );
    } else {
      return Future.error('can not launch');
    }
  }

  static Future<void> launchInWebViewWithDomStorage(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: true,
        forceWebView: true,
        enableDomStorage: true,
      );
    } else {
      return Future.error('can not launch');
    }
  }

  static Future<void> launchUniversalLinkIos(String url) async {
    if (await canLaunch(url)) {
      final bool nativeAppLaunchSucceeded = await launch(
        url,
        forceSafariVC: false,
        universalLinksOnly: true,
      );

      if (!nativeAppLaunchSucceeded) {
        await launch(
          url,
          forceSafariVC: true,
        );
      }
    }
  }

  /// url:  tel:+1 555 010 999
  static Future<void> makePhoneCall(String num) async {
    if (await canLaunch(num)) {
      await launch(num);
    } else {
      return Future.error('can not launch $num');
    }
  }

  /// url:  sms:5550101234
  static Future<void> sendSmsTo(String num) async {
    if (await canLaunch(num)) {
      await launch(num);
    } else {
      return Future.error('can not launch $num');
    }
  }

  static Future<void> sendSmsToByBody(String num, String text) async {
    final Uri sms =
        Uri(scheme: 'sms', path: num, queryParameters: {'sms_body': text});

    await launch(sms.toString());
  }

  /// url:  mailto:smith@example.org?subject=News&body=New%20plugin
  static Future<void> sendEmail(String url) async {
    final Uri _emailLaunchUri = Uri(
        scheme: 'mailto',
        path: 'smith@example.com',
        queryParameters: {'subject': 'Example Subject & Symbols are allowed!'});

    if (await canLaunch(url)) {
      await launch(_emailLaunchUri.toString());
    } else {
      return Future.error('can not launch $url');
    }
  }
}
