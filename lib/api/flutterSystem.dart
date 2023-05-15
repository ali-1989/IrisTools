import 'dart:typed_data';
import 'dart:ui';

class FlutterSystem {

  static FlutterView getFlutterWindow(){
    return PlatformDispatcher.instance.implicitView!;
  }

  static AccessibilityFeatures getAccessibilityFeatures(){
    return PlatformDispatcher.instance.accessibilityFeatures;
  }

  static bool use24HourFormat(){
    return PlatformDispatcher.instance.alwaysUse24HourFormat;
  }

  static int getFrameNumber(){
    return PlatformDispatcher.instance.frameData.frameNumber;
  }

  static List<Locale> getLocales(){
    return PlatformDispatcher.instance.locales;
  }

  static void setOnAccessibilityFeaturesChanged(Function() fn){
    PlatformDispatcher.instance.onAccessibilityFeaturesChanged = fn;
  }

  static void setOnLocaleChanged(Function() fn){
    PlatformDispatcher.instance.onLocaleChanged = fn;
  }

  static void setOnMetricsChanged(Function() fn){
    PlatformDispatcher.instance.onMetricsChanged = fn;
  }

  static void setOnBrightnessChanged(Function() fn){
    PlatformDispatcher.instance.onPlatformBrightnessChanged = fn;
  }

  static double getDevicePixelRatio(){
    return PlatformDispatcher.instance.implicitView!.devicePixelRatio;
  }

  static GestureSettings getGestureSettings(){
    return PlatformDispatcher.instance.implicitView!.gestureSettings;
  }

  static ViewPadding getViewPadding(){
    return PlatformDispatcher.instance.implicitView!.viewPadding;
  }

  static ViewPadding getViewInsets(){
    return PlatformDispatcher.instance.implicitView!.viewInsets;
  }

  static PlatformDispatcher getPlatformDispatcher(){
    return PlatformDispatcher.instance;
  }

  static bool isSemanticsEnabled(){
    return getPlatformDispatcher().semanticsEnabled;
  }

  static Iterable<FlutterView> getFlutterViews(){
    return getPlatformDispatcher().views;
  }

  static Future loadFont(Uint8List fontBytes, String fontFamily){
    return loadFontFromList(fontBytes, fontFamily: fontFamily);
  }
}