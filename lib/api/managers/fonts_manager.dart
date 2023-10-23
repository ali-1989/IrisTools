import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';

class FontsManager {
  double? startFontSize;
  double maximumAppFontSize = 13;
  double minimumAppFontSize = 11;
  double? webScreenWidth;
  final Set<Font> _fontList = {};
  late Font _platformDefaultFont;

  FontsManager({this.startFontSize, this.maximumAppFontSize = 14, this.minimumAppFontSize = 11, this.webScreenWidth}){
    _init();
  }

  void calcFontSize(){
    startFontSize = Font.genScreenRelativeFontSize(minSize: minimumAppFontSize, maxSize: maximumAppFontSize, webMaxWidthSize: webScreenWidth);
  }

  void _init(){
    final theme = TextTheme();

    String? ff = theme.bodyMedium?.fontFamily;
    ff ??= (kIsWeb? 'Segoe UI' : 'Roboto');

    _platformDefaultFont = Font()..family = ff;
  }

  Set<Font> fontList(){
    return _fontList;
  }

  void addFont(Font font){
    _fontList.add(font);
  }

  void deleteFont(Font font){
    _fontList.remove(font);
  }

  Font? fontByFamily(String family){
    for (final font in _fontList) {
      if(font.family == family){
        return font;
      }
    }

    return null;
  }

  String getPlatformFontFamily(){
    BuildContext? context = _getBuildContext();

    try{
      return getPlatformFontFamilyOf(context!)!;
    }
    catch (e){/**/}

    return (kIsWeb? 'Segoe UI' : 'Roboto'); // monospace
  }

  BuildContext? _getBuildContext(){
    BuildContext? context;

    try{
      context = WidgetsBinding.instance.focusManager.primaryFocus?.context;
      context ??= WidgetsBinding.instance.focusManager.rootScope.focusedChild?.context;
      context ??= WidgetsBinding.instance.focusManager.rootScope.context;

      return context;
    }
    catch (e){/**/}

    return null;
  }

  String? getPlatformFontFamilyOf(BuildContext context){
    return getDefaultTextStyleOf(context).style.fontFamily;
  }

  DefaultTextStyle getDefaultTextStyleOf(BuildContext context){
    return DefaultTextStyle.of(context);
  }

  List<Font> fontListFor(String language, FontUsage usage, bool onlyDefault) {
    final result = <Font>[];
    
    for(final fon in _fontList){
      var matchLanguage = fon.defaultLanguage == language;
      var matchUsage = fon.defaultUsage == usage;

      if(!matchLanguage && fon.defaultLanguage == null) {
        matchLanguage = fon.languages.isEmpty || fon.languages.contains(language);
      }

      if(!matchUsage && !onlyDefault) { // && fon.defaultUsage == null
        matchUsage = fon.usages.isEmpty || fon.usages.contains(usage);
      }

      if(matchLanguage && matchUsage){
        result.add(fon.clone());
      }
    }

    return result;
  }

  // defaultFontFor(Settings.appLocale.languageCode, FontUsage.bold);
  Font defaultFontFor(String language, FontUsage usage) {
    for(final fon in _fontList){
      final matchLanguage = fon.defaultLanguage == language;
      final matchUsage = fon.defaultUsage == usage;

      if(matchLanguage && matchUsage) {
        return fon.clone();
      }
    }

    for(final fon in _fontList){
      final matchLanguage = fon.defaultLanguage == language;
      final matchUsage = fon.usages.any((element) => element == usage);

      if(matchLanguage && matchUsage) {
        return fon.clone();
      }
    }

    return _platformDefaultFont.clone();
  }

  String defaultFontFamilyFor(String language, FontUsage usage) {
    return defaultFontFor(language, usage).family!;
  }

  Font getPlatformFont(){
    return _platformDefaultFont;
  }

  Font? getEnglishFont(){
    return defaultFontFor('en', FontUsage.regular);
  }

  double? appFontSize(){
    return startFontSize;
  }

  double appFontSizeOrRelative(){
    return appFontSize()?? Font.genScreenRelativeFontSize(maxSize: maximumAppFontSize, minSize: minimumAppFontSize, webMaxWidthSize: webScreenWidth);
  }

  double themeFontSizeOrRelative(BuildContext context){
    final theme = Theme.of(context);
    return theme.textTheme.bodyMedium?.fontSize?? appFontSizeOrRelative();
  }
}
///=============================================================================
enum FontUsage {
  regular,
  thin,
  bold;

  static FontUsage fromName(String name){
    for(final f in FontUsage.values){
      if(f.name == name){
        return f;
      }
    }

    return FontUsage.regular;
  }
}
///=============================================================================
class Font {
  String? family;
  String? fileName;
  double? height;
  double? size;
  FontUsage defaultUsage = FontUsage.regular;
  String? defaultLanguage;
  TextHeightBehavior? textHeightBehavior;
  List<String> languages = [];
  List<FontUsage> usages = [];

  Font();

  Font.bySize(this.size);

  Font.fromMap(Map? map){
    if(map == null){
      return;
    }

    family = map['family'];
    fileName = map['file_name'];
    size = map['size'];
    height = map['height'];
    textHeightBehavior = _fromMapTextHeightBehavior(map['text_height_behavior']);
    defaultUsage = FontUsage.fromName(map['default_usage']);
    defaultLanguage = map['default_language'];
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};

    map['family'] = family;
    map['file_name'] = fileName;
    map['size'] = size;
    map['height'] = height;
    map['text_height_behavior'] = _toMapTextHeightBehavior(textHeightBehavior);
    map['default_usage'] = defaultUsage.name;
    map['default_language'] = defaultLanguage;

    return map;
  }

  Font clone(){
    return Font.fromMap(toMap());
  }

  static double genScreenRelativeFontSize({double? webMaxWidthSize, required double minSize, required double maxSize}) {
    double realPixelWidth = PlatformDispatcher.instance.implicitView!.physicalSize.width;
    double realPixelHeight = PlatformDispatcher.instance.implicitView!.physicalSize.height;
    double pixelRatio = PlatformDispatcher.instance.implicitView!.devicePixelRatio;

    if(kIsWeb) {
      pixelRatio = realPixelHeight / (webMaxWidthSize ?? realPixelWidth);
    }

    final factor = MathHelper.between(15, 3.3, 10.5, 1.0, pixelRatio);
    final minNum =  max(minSize, factor);

    return min(maxSize, minNum);
  }

  /*
  if(kIsWeb) {
      return 13;
    }

    final realPixelWidth = PlatformDispatcher.instance.implicitView!.physicalSize.width;
    final realPixelHeight = PlatformDispatcher.instance.implicitView!.physicalSize.height;
    final pixelRatio = PlatformDispatcher.instance.implicitView!.devicePixelRatio;
    final isLandscape = realPixelWidth > realPixelHeight;

    final factor = (isLandscape ? realPixelWidth : realPixelHeight) / pixelRatio;
    final fSize = factor / 52;
    final minNum =  max(FontManager.minForFontSize, fSize);

    return min(FontManager.maxForFontSize, minNum);
   */
  Map<String, dynamic>? _toMapTextHeightBehavior(TextHeightBehavior? itm){
    if(itm == null){
      return null;
    }

    return <String, dynamic>{
      'applyHeightToFirstAscent': itm.applyHeightToFirstAscent,
      'applyHeightToLastDescent': itm.applyHeightToLastDescent,
    };
  }

  TextHeightBehavior? _fromMapTextHeightBehavior(Map<String, dynamic>? map){
    if(map == null){
      return null;
    }

    return TextHeightBehavior(
        applyHeightToLastDescent: map['applyHeightToLastDescent'],
        applyHeightToFirstAscent: map['applyHeightToFirstAscent']
    );
  }
}
