import 'web_tools_stub.dart' if (dart.library.html) 'dart:html' as html;
//import 'dart:html' as html;
import 'dart:io';
import 'package:flutter/foundation.dart';
//import 'package:universal_io/io.dart';//''dart:io';

// ignore: avoid_classes_with_only_static_members
class WebTools {
  WebTools._();

  static bool? _isApple;
  static bool? _isAndroid;
  static bool? _isIOS;
  static bool? _isMacOS;
  static bool? _isWindows;
  static bool? _isLinux;

  static bool get isApple => _isApple ?? _getIsApple();
  static bool get isAndroid => _isAndroid ?? _getIsAndroid();
  static bool get isIOS => _isIOS ?? _getIsIOS();
  static bool get isMacOS => _isMacOS ?? _getIsMacOS();
  static bool get isWindows => _isWindows ?? _getIsWindows();
  static bool get isLinux => _isLinux ?? _getIsLinux();
  static bool get isWeb => kIsWeb;

  static void _getPlatforms() {
    if (kIsWeb) {
      _getWebPlatforms();
    }
    else {
      _isApple = Platform.isIOS || Platform.isMacOS;
      _isAndroid = Platform.isAndroid;
      _isIOS = Platform.isIOS;
      _isMacOS = Platform.isMacOS;
      _isWindows = Platform.isWindows;
      _isLinux = Platform.isLinux;
    }
  }

  static void _getWebPlatforms() {
    final platforms = {
      'iPad Simulator': 'I',
      'iPhone Simulator': 'I',
      'iPod Simulator': 'I',
      'iPad': 'I',
      'iPhone': 'I',
      'iPod': 'I',
      'Linux': 'L',
      'X11': 'L',
      'like Mac': 'I',
      'Mac': 'M',
      'Win': 'W',
      'Android': 'A',
    };

    var platform = 'A';

    for (final name in platforms.keys) {
      if (html.window.navigator.platform!.contains(name) || html.window.navigator.userAgent.contains(name)) {
        platform = platforms[name]!;
        break;
      }
    }

    _isApple = platform == 'I' || platform == 'M';
    _isAndroid = platform == 'A';
    _isIOS = platform == 'I';
    _isMacOS = platform == 'M';
    _isWindows = platform == 'W';
    _isLinux = platform == 'L';
  }

  static bool _getIsApple() {
    _getPlatforms();
    return _isApple!;
  }

  static bool _getIsAndroid() {
    _getPlatforms();
    return _isAndroid!;
  }

  static bool _getIsIOS() {
    _getPlatforms();
    return _isIOS!;
  }

  static bool _getIsMacOS() {
    _getPlatforms();
    return _isMacOS!;
  }

  static bool _getIsWindows() {
    _getPlatforms();
    return _isWindows!;
  }

  static bool _getIsLinux() {
    _getPlatforms();
    return _isLinux!;
  }

  static TargetPlatform getPlatform() {
    _getPlatforms();

    if(_isLinux!) {
      return TargetPlatform.linux;
    }
    if(_isAndroid!) {
      return TargetPlatform.android;
    }
    if(_isIOS!) {
      return TargetPlatform.iOS;
    }
    if(_isWindows!) {
      return TargetPlatform.windows;
    }
    if(_isMacOS!) {
      return TargetPlatform.macOS;
    }

    return TargetPlatform.fuchsia;
  }

  static Future<List<String>> deviceLocales() async {
    List<String> result = [];
    html.window.navigator.languages?.forEach(result.add);

    return result;
  }

  static Future<String> deviceLocale() async {
    return html.window.navigator.language;
  }
}