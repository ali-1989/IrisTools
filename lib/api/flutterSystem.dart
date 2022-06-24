import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/widgets.dart';

class FlutterSystem {

  static SingletonFlutterWindow getFlutterWindow(){
    return PaintingBinding.instance!.window;
  }

  static AccessibilityFeatures getAccessibilityFeatures(){
    return PaintingBinding.instance!.window.accessibilityFeatures;
  }

  static bool use24HourFormat(){
    return PaintingBinding.instance!.window.alwaysUse24HourFormat;
  }

  static int getFrameNumber(){
    return PaintingBinding.instance!.window.frameData.frameNumber;
  }

  static List<Locale> getLocales(){
    return PaintingBinding.instance!.window.locales;
  }

  static void setOnAccessibilityFeaturesChanged(Function() fn){
    PaintingBinding.instance!.window.onAccessibilityFeaturesChanged = fn;
  }

  static void setOnLocaleChanged(Function() fn){
    PaintingBinding.instance!.window.onLocaleChanged = fn;
  }

  static void setOnMetricsChanged(Function() fn){
    PaintingBinding.instance!.window.onMetricsChanged = fn;
  }

  static void setOnBrightnessChanged(Function() fn){
    PaintingBinding.instance!.window.onPlatformBrightnessChanged = fn;
  }

  static ViewConfiguration getViewConfiguration(){
    return PaintingBinding.instance!.window.viewConfiguration;
  }

  static double getDevicePixelRatio(){
    return PaintingBinding.instance!.window.viewConfiguration.devicePixelRatio;
  }

  static GestureSettings getGestureSettings(){
    return PaintingBinding.instance!.window.viewConfiguration.gestureSettings;
  }

  static WindowPadding getViewPadding(){
    return PaintingBinding.instance!.window.viewConfiguration.viewPadding;
  }

  static WindowPadding getViewInsets(){
    return PaintingBinding.instance!.window.viewConfiguration.viewInsets;
  }

  static PlatformDispatcher getPlatformDispatcher(){
    return PaintingBinding.instance!.window.platformDispatcher;
  }

  static bool isSemanticsEnabled(){
    return PaintingBinding.instance!.window.platformDispatcher.semanticsEnabled;
  }

  static Iterable<FlutterView> getFlutterViews(){
    return PaintingBinding.instance!.window.platformDispatcher.views;
  }

  static Future loadFont(Uint8List fontBytes, String fontFamily){
    return loadFontFromList(fontBytes, fontFamily: fontFamily);
  }
}