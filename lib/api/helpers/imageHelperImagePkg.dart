import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:image/src/filter/adjust_color.dart' as ac;
import 'package:image/src/command/command.dart' as img_cmd;

/// this package (package:image/image.dart) is slow

class ImageHelperImagePkg {
  ImageHelperImagePkg._();

  /// for (2800*1800, 500KB) take 5 sec
  /// for (7200*5400, 29MB) take 48 sec

  static Future<img.Image?> readAsImage(String path) async {
    return img.decodeImage(await File(path).readAsBytes());
  }

  static img.Image? bytesToImage(Uint8List bytes) {
    return img.decodeImage(bytes);
  }

  static img.Image? bytesToImageSized(ByteBuffer bytes, int w, int h) {
    return img.Image.fromBytes(bytes: bytes, width: w, height: h);
  }

  static Future<img.Image?> bytesToImage$isolate(Uint8List bytes, int w, int h) {
    return compute<Uint8List, Uint8List>(_decodeImage, bytes).then((Uint8List value) {
      return img.Image.fromBytes(bytes:value.buffer, width: w, height: h);
    });
  }
  //------------------------------------------------------------------------------------------
  static List<int> imageToPng(img.Image image, int level) {
    return img.encodePng(image, level: level);
  }

  /// for (7200*5400, 29MB) take 620 mil
  static List<int> imageToJpg(img.Image image, {int quality = 100}) {
    return img.encodeJpg(image, quality: quality);
  }

  static List<int> imageToGif(img.Image image, int factor) {
    return img.encodeGif(image, samplingFactor: factor);
  }

  static img.Image? jpgToImage(Uint8List list) {
    return img.decodeJpg(list);
  }

  static img.Image? pngToImage(Uint8List list) {
    return img.decodePng(list);
  }

  static img.Image? tgaToImage(Uint8List list) {
    return img.decodeTga(list);
  }

  static img.Image? bmpToImage(Uint8List list) {
    return img.decodeBmp(list);
  }

  static img.Image? webpToImage(Uint8List list) {
    return img.decodeWebP(list);
  }

  static img.Image? tifToImage(Uint8List list) {
    return img.decodeTiff(list);
  }

  static img.Image? psdToImage(Uint8List list) {
    return img.decodePsd(list);
  }

  static img.Image flipH$image(img.Image image) {
    return img.flip(image, direction: img.FlipDirection.horizontal);
  }

  static img.Image flipV$image(img.Image image) {
    return img.flip(image, direction: img.FlipDirection.vertical);
  }

  static img.Image rotateDegrees$image(img.Image image, num angle) {
    return img.copyRotate(image, angle: angle);
  }

  static img.Image crop$image(img.Image image, int top, int left, int w, int h) {
    return img.copyCrop(image, y: top, x: left, width: w, height: h);
  }

  static img.Image cropByRect$image(img.Image image, ui.Rect rect) {
    return img.copyCrop(image, y: rect.top as int, x: rect.left as int, width: rect.width as int, height: rect.height as int);
  }

  /// for (7200*5400, 29MB) take 900 mil
  static img.Image resize$image(img.Image src, {int? newWidth, int? newHeight, img.Interpolation interpolation = img.Interpolation.nearest}) {
    return img.copyResize(src, width: newWidth, height: newHeight, interpolation: interpolation);
  }

  static img.Image colorOffset$image(img.Image image,
      {int red = 0, int green = 0, int blue = 0, int alpha = 0}) {
    return img.colorOffset(image,
        red: red, green: green, blue: blue, alpha: alpha);
  }

  static img.Image? contrast$image(img.Image image, num contrast) {
    return img.contrast(image, contrast: contrast);
  }

  static img.Image grayscale$image(img.Image image) {
    return img.grayscale(image);
  }

  static img.Image? brightness$image(img.Image image, int val) {
    return ac.adjustColor(image, brightness: val);
    //return img.brightness(image, val);
  }

  static img.Image gaussianBlur$image(img.Image image, int deg) {
    final cmd = img_cmd.Command();
    cmd.image(image);
    //cmd.execute();
    cmd.gaussianBlur(radius: deg);
    cmd.execute();
    return cmd.outputImage!;
  }

  static img.Image invertColor$image(img.Image src) {
    return img.invert(src);
  }

  static img.Image vignette$image(img.Image src) {
    return img.vignette(src);
  }

  static img.Image emboss$image(img.Image src) {
    return img.emboss(src);
  }

  static img.Image noise$image(img.Image src, num sig, img.NoiseType type) {
    return img.noise(src, sig, type: type);
  }

  //img.PixelateMode.upperLeft
  static img.Image pixelByPixel$image(img.Image src, int blockSize, img.PixelateMode mode) {
    return img.pixelate(src, size: blockSize, mode: mode);
  }

  static img.Image normalize$image(img.Image src, int min, int max) {
    return img.normalize(src, min: min, max: max);
  }

  static img.Image sepia$image(img.Image src, int amount) {
    return img.sepia(src, amount: amount);
  }

  static img.Image sobel$image(img.Image src, int amount) {
    return img.sobel(src, amount: amount);
  }

  static img.Image smooth$image(img.Image src, int w) {
    return img.smooth(src, weight: w);
  }

  static Future<int?> getSystemImageSize$image(ui.Image img) async {
    ByteData? b = await img.toByteData();

    if(b == null) {
      return null;
    }

    return Future.value(b.lengthInBytes);
  }

  static img.Image fixImageRotation$image(img.Image image) {
    return img.bakeOrientation(image);
  }

  static List<num> rgbToHsl$image(num r, num g, num b) {
    return img.rgbToHsl(r, g, b);
  }

  static List<num> hslToRgb$image(num h, num s, num l) {
    return img.hslToRgb(h, s, l);
  }
}
//--------------------------------------------------------------------------
/// isolate
Uint8List _decodeImage(Uint8List bytes){
  return img.decodeImage(bytes)!.getBytes();
}