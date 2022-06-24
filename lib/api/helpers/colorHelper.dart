import 'dart:math';
import 'package:flutter/material.dart';
import 'package:iris_tools/api/textToColor.dart';

class ColorHelper {
  ColorHelper._();

  static Color textToColor(String text) {
    return TextToColor.toColor(text);
  }

  static Color getColorFromHex(String code) {
    return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  static Color getRandomARGB() {
    final _random = Random();
    return Color.fromARGB(
      _random.nextInt(256),
      _random.nextInt(256),
      _random.nextInt(256),
      _random.nextInt(256),);
  }

  static Color getRandomRGB() {
    final _random = Random();
    return Color.fromARGB(
      255,
      _random.nextInt(256),
      _random.nextInt(256),
      _random.nextInt(256),);
  }

  static bool isLightColor(Color c, {num val = 0.5}) {
    final baseHsl = HSLColor.fromColor(c);
    return baseHsl.lightness >= val;
  }

  static bool isDarkColor(Color c) {
    final baseHsl = HSLColor.fromColor(c);
    return baseHsl.lightness < 0.5;
  }

  static Color inverseColor(Color color) {
    final newR = 255 - color.red;
    final newG = 255 - color.green;
    final newB = 255 - color.blue;

    return Color.fromARGB(color.alpha, newR, newG, newB);
  }

  static Color darkPlus(Color color, {num val = .06}) {
    final baseHsl = HSLColor.fromColor(color);
    return baseHsl.withLightness(max(0, baseHsl.lightness - val)).toColor();
  }

  static Color lightPlus(Color color, {num val = .06}) {
    final baseHsl = HSLColor.fromColor(color);
    return baseHsl.withLightness(min(1, baseHsl.lightness + val)).toColor();
  }

  // changeHSL(AppThemes.currentTheme.accentColor, 4, 0, 0.05)
  static Color changeAbsoluteHSL(Color color, num h, num s, num l) {
    //hlp: Hue:0 - 360, Saturation & Light: 0 - 1.0

    if (h > 360 || h < -360) {
      throw Exception('Hue must be between 0 to +-360');
    }

    if (s > 1 || s < -1) {
      throw Exception('Saturation must be between 0 to +-1');
    }

    if (l > 1 || l < -1) {
      throw Exception('Lightness must be between 0 to +-1');
    }

    final hsl = HSLColor.fromColor(color);

    return hsl.withSaturation(min(1, max(hsl.saturation + s, 0)))
        .withLightness(min(1, max(hsl.lightness + l, 0)))
        .withHue(min(360, max(hsl.hue + h, 0)))
        .toColor();
  }

  static Color changeHSLByRelativeDarkLight(Color color, num h, num s, num l) {
    if (h > 360 || h < 0) {
      throw Exception('Hue must be between 0 to +360');
    }

    if (s > 1 || s < 0) {
      throw Exception('Saturation must be between 0 to 1');
    }

    if (l > 1 || l < 0) {
      throw Exception('Lightness must be between 0 to 1');
    }

    final hsl = HSLColor.fromColor(color);

    if(hsl.hue > 180 && h > 0) {
      h *= -1;
    }

    if(hsl.lightness > 0.5 && l > 0) {
      l *= -1;
    }

    if(hsl.saturation > 0.5 && s > 0) {
      s *= -1;
    }

    return hsl.withSaturation(min(1, max(0, hsl.saturation + s)))
        .withLightness(min(1, max(0, hsl.lightness + l)))
        .withHue(min(360, max(0, hsl.hue + h)))
        .toColor();
  }

  // degrees: 0 - 255
  static bool isNearColor(Color base, Color dif, {num degrees = 70}) {
    final baseHsl = HSLColor.fromColor(base);
    final difHsl = HSLColor.fromColor(dif);

    if (degrees > 255) {
      degrees = 255;
    }

    final num lightV = (baseHsl.lightness - difHsl.lightness).abs();
    final num rV = (base.red - dif.red).abs();
    final num gV = (base.green - dif.green).abs();
    final num bV = (base.blue - dif.blue).abs();
    final num aV = (base.alpha - dif.alpha).abs();

    final light = lightV < (degrees/255);//0.18
    final red = rV < degrees;
    final green = gV < degrees;
    final blue = bV < degrees;
    final alpha = aV < degrees;

    return red && green && blue && alpha && light;
  }

  static bool isNearColors(Color base, List<Color> colors, {num degrees = 60}) {
    var sum = false;

    for(var c in colors) {
      sum = sum || isNearColor(base, c, degrees: degrees);
    }

    return sum;
  }

  static dynamic ifNearColors(Color base, List<Color> colors, Function() nearFn, Function() others, {num degrees = 70}) {
    var sum = false;

    for(var c in colors) {
      sum = sum || isNearColor(base, c, degrees: degrees);
    }

    if(sum) {
      return nearFn();
    }

    return others();
  }

  static bool isNearLightness(Color base, Color other, {double val = 0.37}) {
    final baseHsl = HSLColor.fromColor(base);
    final otherHsl = HSLColor.fromColor(other);

    final isBothBlack = (baseHsl.lightness <= 0.08 && otherHsl.lightness <= 0.08);

    if(isBothBlack) {
      return true;
    }

    final isBothWhite = (baseHsl.lightness >= 0.9 && otherHsl.lightness >= 0.9) &&
        otherHsl.saturation >= 0.5 && ((baseHsl.saturation - otherHsl.saturation).abs() <= 0.1);

    if(isBothWhite) {
      return true;
    }

    final num briDif = (baseHsl.lightness - otherHsl.lightness).abs();
    final num hueDif = (baseHsl.hue - otherHsl.hue).abs();

    return briDif < val && hueDif < 80;
  }

  static Color getUnNearColor(Color useColor, Color checkColor, Color replaceColor, {int degrees = 70}) {
    if (isNearColor(useColor, checkColor, degrees: degrees)) {
      return replaceColor;
    }

    return useColor;
  }

  static Color darkIfIsLight(Color color) {
    var baseHsl = HSLColor.fromColor(color);

    if(isNearLightness(color, Colors.black)) {
      return color;
    }

    if(isNearLightness(color, Colors.white)) {
      baseHsl = baseHsl.withSaturation(max(0, baseHsl.saturation - 0.1));
      baseHsl = baseHsl.withLightness(baseHsl.lightness - 0.08);

      return baseHsl.toColor();
    }

    baseHsl = baseHsl.withSaturation(max(0, baseHsl.saturation - 0.02));
    baseHsl = baseHsl.withLightness(max(0, baseHsl.lightness - 0.1));
    return baseHsl.toColor();
  }

  static Color changeLight(Color color) {
    var baseHsl = HSLColor.fromColor(color);

    if(isNearLightness(color, Colors.black)) {
      baseHsl = baseHsl.withSaturation(0.1); // fix to 0.1
      baseHsl = baseHsl.withLightness(baseHsl.lightness + 0.1);
      return baseHsl.toColor();
    }

    if(isNearLightness(color, Colors.white)) {
      return changeAbsoluteHSL(color, 0, -0.4, -0.2);
    }

    return changeHSLByRelativeDarkLight(color, 0, 0, 0.08);
  }

  static Color highLightMore(Color color) {
    if(isNearLightness(color, Colors.black)) {
      return changeAbsoluteHSL(color, 0, -1, 0.17);
    } // saturation: -1 for remove red color from black

    if(isNearLightness(color, Colors.white)) {
      return changeAbsoluteHSL(color, 0, -0.4, -0.3);
    }

    return changeHSLByRelativeDarkLight(color, 6, 0, 0.09);
  }

  static Color changeHue(Color color) {
    return changeHSLByRelativeDarkLight(color, 4, 0, 0.09);
  }

  static List<Color> getColorGradient(Color color) {
    final baseHsl = HSLColor.fromColor(color);
    final res = <Color>[];
    HSLColor c1, c2, c3;

    if(baseHsl.lightness < 0.5) {
      c1 = baseHsl.withLightness(baseHsl.lightness + 0.06);
      c2 = baseHsl;//.withLightness(baseHsl.lightness + 0.02);
      c3 = baseHsl.withLightness(max(0, baseHsl.lightness - 0.06));
    }
    else{
      c1 = baseHsl.withLightness(baseHsl.lightness - 0.06);
      c2 = baseHsl;//.withLightness(baseHsl.lightness - 0.02);
      c3 = baseHsl.withLightness(min(1, baseHsl.lightness + 0.06));
    }

    if(baseHsl.hue < 180) {
      c1 = c1.withHue(baseHsl.hue + 5);
      c2 = c2.withHue(baseHsl.hue + 1);
      c3 = c3.withHue(max(0, baseHsl.hue - 5));
    }
    else{
      c1 = c1.withHue(baseHsl.hue - 5);
      c2 = c2.withHue(baseHsl.hue - 1);
      c3 = c3.withHue(min(360, baseHsl.hue +5));
    }

    res.add(c1.toColor());
    res.add(c2.toColor());
    res.add(c3.toColor());

    return res;
  }

  static Map<int, Color> getColorMap(Color primaryColor) {
    final hsl = HSLColor.fromColor(primaryColor);

    return {
      50: hsl.withLightness(min(hsl.lightness + .20, 1)).withSaturation(min(hsl.saturation + .04, 1)).toColor(),
      100: hsl.withLightness(min(hsl.lightness + .16, 1)).withSaturation(min(hsl.saturation + .04, 1)).toColor(),
      200: hsl.withLightness(min(hsl.lightness + .12, 1)).withSaturation(min(hsl.saturation + .04, 1)).toColor(),
      300: hsl.withLightness(min(hsl.lightness + .08, 1)).withSaturation(min(hsl.saturation + .04, 1)).toColor(),
      400: hsl.withLightness(min(hsl.lightness + .04, 1)).withSaturation(min(hsl.saturation + .04, 1)).toColor(),
      500: primaryColor,
      600: hsl.withSaturation(max(hsl.saturation - .04, 0)).withLightness(max(hsl.lightness - .04, 0)).toColor(),
      700: hsl.withSaturation(max(hsl.saturation - .04, 0)).withLightness(max(hsl.lightness - .08, 0)).toColor(),
      800: hsl.withSaturation(max(hsl.saturation - .04, 0)).withLightness(max(hsl.lightness - .12, 0)).toColor(),
      900: hsl.withSaturation(max(hsl.saturation - .04, 0)).withLightness(max(hsl.lightness - .16, 0)).toColor(),
    };
  }

  static Map<int, Color> getColorMapByInt(int primaryColor) {
    return getColorMap(Color(primaryColor));
  }
}