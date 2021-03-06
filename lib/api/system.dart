import 'dart:io' show Platform;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:iris_tools/api/webTools.dart';

class System {
  System._();

  static int currentTimeMillis(){
    return DateTime.now().millisecondsSinceEpoch;
  }

  static int currentTimeMillisUtc(){
    var now = DateTime.now();
    var offset = now.timeZoneOffset.inMilliseconds;
    return now.millisecondsSinceEpoch - offset;
  }

  static bool isDesktop(){
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }

  static bool isLinux(){
    return Platform.isLinux;
  }

  static bool isWindows(){
    return Platform.isWindows;
  }

  static bool isMac(){
    return Platform.isMacOS;
  }

  static bool isAndroid(){
    return Platform.isAndroid;
  }

  static Future wait(Duration dur) {
    return Future.delayed(dur, (){});
  }

  static Future waitThen(Duration dur, void Function() fn) {
    return Future.delayed(dur, fn);
    //Timer(dur, fn);
  }

  static void hideBothStatusBar(){
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: []);
  }

  /// fullscreen
  static void hideTopStatusBar(){
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: [SystemUiOverlay.bottom]);
  }

  static void hideBottomStatusBar(){
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: [SystemUiOverlay.top]);
  }

  static void showTopStatusBar(){
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: [SystemUiOverlay.top]);
  }

  static void showBothStatusBar(){
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: SystemUiOverlay.values);
  }

  static void changeStatusBarNavBarColor(Color color){
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: color, systemNavigationBarColor: color));
  }

  static void removeColorTopStatusBar(){
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent,));
  }

  static void returnBackColorTopStatusBar(bool isLightTheme){
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: isLightTheme? Colors.black.withAlpha(70): Colors.black.withAlpha(70),)
    );
  }

  static void removeColorBottomStatusBar(){
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(systemNavigationBarColor: Colors.transparent,));
  }

  static SystemUiOverlayStyle getCurrentSystemUiOverlayStyle(){
    return SystemUiOverlayStyle.light;

    /*AnnotatedRegion<SystemUiOverlayStyle>(
			value: mySystemTheme,
			child: new MyRoute(),
		);*/
  }

  static TextDirection getCurrentDirectionality(BuildContext context){
    return Directionality.of(context);
  }
  
  static TargetPlatform getTargetPlatform(){
    if(isWeb()) {
      return WebTools.getPlatform();
    }

    if(Platform.isIOS) {
      return TargetPlatform.iOS;
    }
    if(Platform.isAndroid) {
      return TargetPlatform.android;
    }
    if(Platform.isMacOS) {
      return TargetPlatform.macOS;
    }
    if(Platform.isFuchsia) {
      return TargetPlatform.fuchsia;
    }
    if(Platform.isWindows) {
      return TargetPlatform.windows;
    }

    return TargetPlatform.linux;
  }

  static bool isMobile(){
    if(isWeb()) {
      return false;
    }

    return Platform.isAndroid || Platform.isIOS;
  }

  static bool isIOS(){
    if(isWeb()) {
      return WebTools.isIOS;
    }

    return Platform.isIOS;
  }

  static bool isWeb(){
    return kIsWeb;
  }

  static bool isWebMobile(){
    return kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android);
  }

  static bool isWebDesktop(){
    return !isWebMobile();
  }

  static bool isReleaseMode(){
    return kReleaseMode;
  }

  static WidgetsBinding? getWidgetsBinding(){
    return WidgetsBinding.instance;
  }

  static FocusManager? getFocusManager(){
    return getWidgetsBinding()?.focusManager;
  }

  static ViewConfiguration? getViewConfiguration(){
    return getWidgetsBinding()?.createViewConfiguration();
  }

  static AccessibilityFeatures? getAccessibilityFeatures(){
    return getWidgetsBinding()?.accessibilityFeatures;
  }

  static AppLifecycleState? getLifecycleState(){
    return getWidgetsBinding()?.lifecycleState;
  }

  static GestureArenaManager? getGestureArenaManager(){
    return getWidgetsBinding()?.gestureArena;
  }

  static void exitApp(){
    SystemNavigator.pop();
  }

  static Locale getPlatformLocale() {
    return Locale(Platform.localeName.substring(0,2), Platform.localeName.substring(3,5));
  }

  static List<Locale>? getPlatformLocales() {
    return getWidgetsBinding()?.window.locales;
  }

  static Locale? getCurrentLocalizationsLocale(BuildContext context) {
    try {
      // ui.window.locale
      return Localizations.localeOf(context);
    }
    catch (e){
      // err: To request the Locale, the context used to retrieve the Localizations widget must be ...
      return null;
    }
  }

  static String? getLocalizationsLanguageCode(BuildContext context) {
    return getCurrentLocalizationsLocale(context)?.languageCode;
  }

  static String? getLocalizationsCountryCode(BuildContext context) {
    return getCurrentLocalizationsLocale(context)?.countryCode;
  }

  static String getFlutterLanguageCode(BuildContext context) {
    return ui.window.locale.languageCode;
  }

  static String? getFlutterCountryCode(BuildContext context) {
    return ui.window.locale.countryCode;
  }

  static void vibrate(BuildContext context) {
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        HapticFeedback.vibrate();
        break;
      default:
        break;
    }
  }
}