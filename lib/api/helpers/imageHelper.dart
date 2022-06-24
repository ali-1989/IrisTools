import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
//import 'package:pic/pic.dart' as pic;   native - slow
//import 'package:pic/src/exif_data.dart';
//import 'package:pic/src/icc_profile_data.dart';

/// https://pub.dev/packages/image_compression_flutter

// todo : this package (package:image/image.dart) is slow, must replace with Canvas

class ImageHelper {
  ImageHelper._();

  static Future evictImageFile(File img){
    return FileImage(img).evict();
  }

  static void evictCacheImages(){
    PaintingBinding.instance!.imageCache?.clear();
  }
  //--------------------------------------------------------------------------
  static Future<Uint8List> readImageAsBytes(String path) {
    return File(path).readAsBytes();
  }

  static Uint8List readImageAsBytesSync(String path) {
    return File(path).readAsBytesSync();
  }

  static Future<ui.Image> readImage(String path) async{
    return decodeImageFromList(await File(path).readAsBytes());
  }

  static Future<File> writeImageBytes(String path, List<int> data) {
    return File(path).writeAsBytes(data, mode: FileMode.writeOnly, flush: true);
  }

  static Future<File?> writeImage(String path, ui.Image img) async {
    ByteData? bytes = await img.toByteData();
    File f = File(path);

    if(bytes == null) {
      return null;
    }

    await f.writeAsBytes(bytes.buffer.asUint32List());

    return f;
  }
  //--------------------------------------------------------------------------
  // use of [getImageDimFast]
  static Future<math.Point> getImageDim(String imgPath) async {
    ui.Image img = await readImage(imgPath);
    return math.Point(img.width, img.height);
  }

  static Future<math.Point> getImageDimB(String imgPath) async {
    Image img = Image.file(File(imgPath));
    return getImageWidgetDim(img);
  }

  static Future<math.Point> getImageDimC(String imgPath) async {
    var fb = await File(imgPath).readAsBytes();
    //ui.Image decodedImage = await decodeImageFromList(fb);

    final buffer = await ui.ImmutableBuffer.fromUint8List(fb);
    final descriptor = await ui.ImageDescriptor.encoded(buffer);

    var res = math.Point(descriptor.width, descriptor.height);
    descriptor.dispose();

    return res;
  }

  static Size getImageDim$GetterPkg(String file) {
    return ImageSizeGetter.getSize(FileInput(File(file)));
  }

  static Future<math.Point> getImageWidgetDim(Image img) async {
    Completer<ui.Image> completer = Completer<ui.Image>();

    ImageStream isStream = img.image.resolve(ImageConfiguration());
    ImageStreamListener isl = ImageStreamListener((ImageInfo image, bool _) {
      if(!completer.isCompleted) {
        completer.complete(image.image);
      }
    });

    isStream.addListener(isl);

    ui.Image info = await completer.future;
    isStream.removeListener(isl);
    int width = info.width;
    int height = info.height;

    return math.Point(width, height);
  }

  static Size getImageDimByFileBytes(Uint8List bytes) {
    return ImageSizeGetter.getSize(MemoryInput(bytes));
  }

  static Future<math.Point> getImageDimByBytesB(Uint8List bytes) async {
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    final descriptor = await ui.ImageDescriptor.encoded(buffer);

    var res = math.Point(descriptor.width, descriptor.height);
    descriptor.dispose();

    return res;
  }

  static Future<math.Point> getImageDimByBytesC(Uint8List bytes) async {
    Image img = Image.memory(bytes);
    return getImageWidgetDim(img);
  }
  //--------------------------------------------------------------------------
  static bool isWebp(File file) {
    return ImageSizeGetter.isWebp(FileInput(file));
  }

  static bool isWebpBytes(Uint8List bytes) {
    return ImageSizeGetter.isWebp(MemoryInput(bytes));
  }

  static bool isGif(File file) {
    return ImageSizeGetter.isGif(FileInput(file));
  }

  static bool isGifBytes(Uint8List bytes) {
    return ImageSizeGetter.isGif(MemoryInput(bytes));
  }

  static bool isPng(File file) {
    return ImageSizeGetter.isPng(FileInput(file));
  }

  static bool isPngBytes(Uint8List bytes) {
    return ImageSizeGetter.isPng(MemoryInput(bytes));
  }

  static bool isJpg(File file) {
    return ImageSizeGetter.isJpg(FileInput(file));
  }

  static bool isJpgBytes(Uint8List bytes) {
    return ImageSizeGetter.isJpg(MemoryInput(bytes));
  }
  //--------------------------------------------------------------------------
  static num degreesToRadian(num deg) {
    return (deg * math.pi) / 180.0;
  }

  // newWidth: srcWidth / scale
  static double calcMinScaleRatio({
    required double srcWidth,
    required double srcHeight,
    required double minWidth,
    required double minHeight,
  }) {
    var scaleW = srcWidth / minWidth;
    var scaleH = srcHeight / minHeight;

    var scale = math.max(1.0, math.min(scaleW, scaleH));

    return scale;
  }

  static math.Point<double> calcMinScale({
    required double srcWidth,
    required double srcHeight,
    required double minWidth,
    required double minHeight,
  }) {
    var scaleW = srcWidth / minWidth;
    var scaleH = srcHeight / minHeight;

    var scale = math.max(1.0, math.min(scaleW, scaleH));

    return math.Point(srcWidth / scale, srcHeight / scale);
  }

  static math.Point<double> calcMaxScale({
    required double srcWidth,
    required double srcHeight,
    required double maxWidth,
    required double maxHeight,
  }) {
    double ratio = srcWidth / srcHeight;

    if (srcWidth > maxWidth) {
      srcWidth = maxWidth;
      srcHeight = srcWidth / ratio;
    }

    if (srcHeight > maxHeight) {
      srcHeight = maxHeight;
      srcWidth = srcHeight * ratio;
    }

    return math.Point(srcWidth, srcHeight);
  }

  static math.Point<double> calcScale({
    required double srcWidth,
    required double srcHeight,
    required double newWidth,
    required double newHeight,
  }) {
    double ratio = srcWidth / srcHeight;

    var maximizedToWidth = math.Point(newWidth, newWidth / ratio);
    var maximizedToHeight = math.Point(newHeight * ratio, newHeight);

    if (maximizedToWidth.y > newHeight) {
      return maximizedToHeight;
    } else {
      return maximizedToWidth;
    }
  }

  /// use
  static math.Point<int> getScaledDimension(int w, int h, int boundWidth, int boundHeight) {
    int newWidth = w;
    int newHeight = h;

    if (w > boundWidth) {
      newWidth = boundWidth;
      newHeight = ((newWidth * h) ~/ w);
    }

    if (newHeight > boundHeight) {
      newHeight = boundHeight;
      newWidth = ((newHeight * w) ~/ h);
    }

    return math.Point<int>(newWidth, newHeight);
  }

  static math.Point<double> getScaledDimensionByRate(int w, int h, int boundWidth, int boundHeight) {
    double widthRatio = boundWidth / w;
    double heightRatio = boundHeight / h;

    double ratio = math.min(widthRatio, heightRatio);

    return math.Point<double>((w * ratio), (h * ratio));
  }

  /*static bool hasNormalDimension(int w, int h, int maxLandscapeWidth, int maxLandscapeH) {
    bool isLandscape = w >= h;
    return isLandscape
        ? (w <= maxLandscapeWidth && h <= maxLandscapeH)
        : (w <= maxLandscapeH && h <= maxLandscapeWidth);
  }

  static math.Point getScaleDimIfNeed(int w, int h, int maxLandscapeWidth, int maxLandscapeH) {
    bool isNormalSize = hasNormalDimension(w, h, maxLandscapeWidth, maxLandscapeH);

    if (isNormalSize) {
      return math.Point(w, h);
    }

    var res = getScaledDimension(w, h, maxLandscapeWidth, maxLandscapeH);
    bool isLandscape = w >= h;

    if (!isLandscape) {
      res = getScaledDimension(w, h, maxLandscapeH, maxLandscapeWidth);
    }

    return res;
  }*/
  //--------------------------------------------------------------------------
  static Future<Uint8List> compressBytes(Uint8List fileBytes, int minWidth, int minHeight, {
    int quality = 90,
    int rotate = 0,
    int inSampleSize = 1,
    CompressFormat format = CompressFormat.jpeg,
  }) async {
    var result = await FlutterImageCompress.compressWithList(
        fileBytes,
        minHeight: minHeight,
        minWidth: minWidth,
        quality: quality,
        rotate: rotate,
        inSampleSize: inSampleSize,
        autoCorrectionAngle : true,
        format: format,
        keepExif: false,
    );

    return result;
  }

  static Future<Uint8List?> compressAsset(String src, int minWidth, int minHeight, {
    int quality = 90,
    int rotate = 0,
    int inSampleSize = 1,
    CompressFormat format = CompressFormat.jpeg,
  }) async {
    var result = await FlutterImageCompress.compressAssetImage(
        src,
        minHeight: minHeight,
        minWidth: minWidth,
        quality: quality,
        rotate: rotate,
        autoCorrectionAngle : true,
        format: format,
        keepExif: false,
    );

    return result;
  }

  static Future<Uint8List?> compressFile(String srcPath, int minWidth, int minHeight, {
    int quality = 90,
    int rotate = 0,
    int inSampleSize = 1,
    CompressFormat format = CompressFormat.jpeg,
  }) async {
    var result = await FlutterImageCompress.compressWithFile(
        srcPath,
        minHeight: minHeight,
        minWidth: minWidth,
        quality: quality,
        rotate: rotate,
        autoCorrectionAngle : true,
        format: format,
        keepExif: false,
    );

    return result;
  }

  static Future<File?> compressFileAndSave(String srcPath, String savePath, int minWidth, int minHeight, {
    int quality = 90,
    int rotate = 0,
    int inSampleSize = 1,
    CompressFormat format = CompressFormat.jpeg,
  }) async {
    var result = await FlutterImageCompress.compressAndGetFile(
        srcPath,
        savePath,
        minHeight: minHeight,
        minWidth: minWidth,
        quality: quality,
        rotate: rotate,
        autoCorrectionAngle : true,
        format: format,
        keepExif: false,
    );

    return result;
  }
  //--------------------------------------------------------------------------
  static Future<Uint8List> rotateBytes(Uint8List list, int minWidth, int minHeight, int rotate,{
    int quality = 100,
    int inSampleSize = 1,
    CompressFormat format = CompressFormat.jpeg,
  }) async {
    var result = await FlutterImageCompress.compressWithList(
      list,
      minHeight: minHeight,
      minWidth: minWidth,
      quality: quality,
      rotate: rotate,
      inSampleSize: inSampleSize,
      autoCorrectionAngle : true,
      format: format,
      keepExif: false,
    );

    return result;
  }

  static Future<Uint8List?> rotateFile(String srcPath, int minWidth, int minHeight, int rotate, {
    int inSampleSize = 1,
    CompressFormat format = CompressFormat.jpeg,
  }) async {
    var result = await FlutterImageCompress.compressWithFile(
      srcPath,
      minHeight: minHeight,
      minWidth: minWidth,
      quality: 100,
      rotate: rotate,
      autoCorrectionAngle : true,
      format: format,
      keepExif: false,
    );

    return result;
  }
  //----------------- fast resize ---------------------------------------------------------
  static Future<ui.FrameInfo> resizeBytesAsFrame(Uint8List rawImage, {int? newWidth, int? newHeight}) async {
    ui.Codec codec = await ui.instantiateImageCodec(rawImage, targetWidth: newWidth, targetHeight: newHeight);
    return codec.getNextFrame();
  }

  static Future<Uint8List?> resizeBytesAsPng(Uint8List rawImage, {int? newWidth, int? newHeight}) async {
    final codec = await ui.instantiateImageCodec(rawImage, targetWidth: newWidth, targetHeight: newHeight);
    final resizedImage = (await codec.getNextFrame()).image;
    final s = await resizedImage.toByteData(format: ui.ImageByteFormat.png);
    return s!.buffer.asUint8List();
  }

  static Future<Uint8List> resizeBytesAsRgba(Uint8List rawImage,
      {
        int? newWidth,
        int? newHeight,
        format = ui.ImageByteFormat.rawRgba,
      }) async {
    final codec = await ui.instantiateImageCodec(rawImage, targetWidth: newWidth, targetHeight: newHeight);
    final resizedImage = (await codec.getNextFrame()).image;
    final s = await resizedImage.toByteData(format: format);
    return s!.buffer.asUint8List();
  }

  static Future<ui.Image> resizeRgbaAsImage(Uint8List rgb, {
    required int width, required int height,
    required int newWidth, required int newHeight,
    }) async {
    late ui.Image img;
    //ui.Image decodedImage = await decodeImageFromList(fileBytes);

    var c = Completer();
    ui.decodeImageFromPixels(rgb, width, height, ui.PixelFormat.rgba8888, (ui.Image result) {
      img = result;
      c.complete();
      },
      targetWidth: newWidth, targetHeight: newHeight);

    await c.future;
    return img;
  }

  static Future<Uint8List> resizeRgbaToRgba(Uint8List rgb, {
    required int width, required int height,
    required int newWidth, required int newHeight,
    }) async {
    late ui.Image img;
    var c = Completer();
    ui.decodeImageFromPixels(rgb, width, height, ui.PixelFormat.rgba8888, (ui.Image result) {
        img = result;
        c.complete();
      },
      targetWidth: newWidth,
        targetHeight: newHeight);

    await c.future;
    var res = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
    return res!.buffer.asUint8List();
  }
  //--------------------------------------------------------------------------
  static Future<ui.Image> bytesToImage(Uint8List rawBytes) async {
    ui.Codec codec = await ui.instantiateImageCodec(rawBytes);
    ui.FrameInfo frame = await codec.getNextFrame();
    return frame.image;
  }

  static Future<ui.FrameInfo> bytesToFrameInfo(Uint8List rawBytes) async {
    ui.Codec codec = await ui.instantiateImageCodec(rawBytes);
    return await codec.getNextFrame();
  }

  static Future<Uint8List> bytesToRgba(Uint8List rawBytes) async {
    ui.Codec codec = await ui.instantiateImageCodec(rawBytes);
    ui.FrameInfo frame = await codec.getNextFrame();
    var bd = await frame.image.toByteData();
    return bd!.buffer.asUint8List();
  }

  static Future<Uint8List?> imageToPng(ui.Image img) async {
    ByteData? data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data?.buffer.asUint8List();
  }

  static Future<Uint8List> rgbaToPng(Uint8List rgb, int width, int height) async {
    ui.Image? img;
    var c = Completer();
    ui.decodeImageFromPixels(rgb, width, height, ui.PixelFormat.rgba8888, (ui.Image result) {
      img = result;
      c.complete();
    });

    await c.future;
    return (await img!.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  static Future<Uint8List?> imageToRgba(ui.Image img) async {
    ByteData? data = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
    return data?.buffer.asUint8List();
  }
  //------------- blur -------------------------------------------------------------
  /// await ImageHelper.rgbaToPng(blur, point.x, point.y)
  static Future<ui.Image> blurImage(ui.Image img, {double sigma = 12.0}) async {
    var pr = ui.PictureRecorder();
    var canvas = ui.Canvas(pr);

    canvas.drawImage(
        img,
        ui.Offset(0, 0),
        ui.Paint()..maskFilter = ui.MaskFilter.blur(BlurStyle.normal, sigma)
    );

    var pic = pr.endRecording();
    return pic.toImage(img.width, img.height);
  }

  /// https://pub.dev/packages/stack_blur
  static void blurRgbaSlow(Uint32List rgbaPixels, int width, int height, int radius) {
    if (width < 0) {
      throw ArgumentError.value(width, 'width');
    }

    if (height < 0) {
      throw ArgumentError.value(height, 'height');
    }

    if (rgbaPixels.length != width * height) {
      throw ArgumentError('Image size does not correspond to the number of pixels');
    }

    if (radius < 1) {
      throw ArgumentError.value(radius, 'radius');
    }

    if (radius == 1) {
      return;
    }

    int wm = width - 1;
    int hm = height - 1;
    int wh = width * height;
    int div = radius + radius + 1;

    final r = Int16List(wh);
    final g = Int16List(wh);
    final b = Int16List(wh);
    int rSum, gSum, bSum, x, y, i, p, yp, yi, yw;
    final vMin = Int32List(max(width, height));

    int divSum = (div + 1) >> 1;
    divSum *= divSum;

    final dv = Int16List(256 * divSum);
    for (i = 0; i < 256 * divSum; i++) {
      int short = i ~/ divSum;
      assert(-32768 <= short && short <= 32767);
      dv[i] = short;
    }

    yw = yi = 0;

    //int[][] stack = new int[div][3];
    // todo maybe optimize initialization to avoid calling function
    final stack = List<Int32List>.generate(div, (_) => Int32List(3), growable: false);

    int stackPointer;
    int stackStart;

    Int32List sir = Int32List(0);

    int rbs;
    int r1 = radius + 1;
    int routSum, goutSum, boutSum;
    int rinSum, ginSum, binSum;

    for (y = 0; y < height; y++) {
      rinSum = ginSum = binSum = routSum = goutSum = boutSum = rSum = gSum = bSum = 0;
      for (i = -radius; i <= radius; i++) {
        p = rgbaPixels[yi + min(wm, max(i, 0))];
        sir = stack[i + radius];
        sir[0] = (p & 0xff0000) >> 16;
        sir[1] = (p & 0x00ff00) >> 8;
        sir[2] = (p & 0x0000ff);

        // todo from this line use three local integers instead Int32List sir

        rbs = r1 - i.abs();
        rSum += sir[0] * rbs;
        gSum += sir[1] * rbs;
        bSum += sir[2] * rbs;

        if (i > 0) {
          rinSum += sir[0];
          ginSum += sir[1];
          binSum += sir[2];
        } else {
          routSum += sir[0];
          goutSum += sir[1];
          boutSum += sir[2];
        }
      }
      stackPointer = radius;

      for (x = 0; x < width; x++) {
        assert(yi >= 0);
        assert(rSum >= 0);
        assert(gSum >= 0);
        assert(bSum >= 0);

        r[yi] = dv[rSum];
        g[yi] = dv[gSum];
        b[yi] = dv[bSum];

        rSum -= routSum;
        gSum -= goutSum;
        bSum -= boutSum;

        stackStart = stackPointer - radius + div;
        sir = stack[stackStart % div];

        routSum -= sir[0];
        goutSum -= sir[1];
        boutSum -= sir[2];

        if (y == 0) {
          vMin[x] = min(x + radius + 1, wm);
        }
        p = rgbaPixels[yw + vMin[x]];

        sir[0] = (p & 0xff0000) >> 16;
        sir[1] = (p & 0x00ff00) >> 8;
        sir[2] = (p & 0x0000ff);

        // todo from this line use three local integers instead Int32List sir

        rinSum += sir[0];
        ginSum += sir[1];
        binSum += sir[2];

        rSum += rinSum;
        gSum += ginSum;
        bSum += binSum;

        stackPointer = (stackPointer + 1) % div;
        sir = stack[(stackPointer) % div];

        routSum += sir[0];
        goutSum += sir[1];
        boutSum += sir[2];

        rinSum -= sir[0];
        ginSum -= sir[1];
        binSum -= sir[2];

        yi++;
      }
      yw += width;
    }
    for (x = 0; x < width; x++) {
      rinSum = ginSum = binSum = routSum = goutSum = boutSum = rSum = gSum = bSum = 0;
      yp = -radius * width;
      for (i = -radius; i <= radius; i++) {
        yi = max(0, yp) + x; // todo avoid function call?

        final Int32List sir = stack[i + radius];

        sir[0] = r[yi];
        sir[1] = g[yi];
        sir[2] = b[yi];

        // todo from this line use three local integers instead Int32List sir

        rbs = r1 - i.abs();

        rSum += r[yi] * rbs;
        gSum += g[yi] * rbs;
        bSum += b[yi] * rbs;

        if (i > 0) {
          rinSum += sir[0];
          ginSum += sir[1];
          binSum += sir[2];
        } else {
          routSum += sir[0];
          goutSum += sir[1];
          boutSum += sir[2];
        }

        if (i < hm) {
          yp += width;
        }
      }
      yi = x;
      stackPointer = radius;
      for (y = 0; y < height; y++) {
        // Preserve alpha channel: ( 0xff000000 & pix[yi] )
        rgbaPixels[yi] =
        (0xff000000 & rgbaPixels[yi]) | (dv[rSum] << 16) | (dv[gSum] << 8) | dv[bSum];

        rSum -= routSum;
        gSum -= goutSum;
        bSum -= boutSum;

        stackStart = stackPointer - radius + div;
        Int32List sir = stack[stackStart % div];

        routSum -= sir[0];
        goutSum -= sir[1];
        boutSum -= sir[2];

        if (x == 0) {
          vMin[y] = min(y + r1, hm) * width;
        }
        p = x + vMin[y];

        sir[0] = r[p];
        sir[1] = g[p];
        sir[2] = b[p];

        // todo from this line use three local integers instead Int32List sir

        rinSum += sir[0];
        ginSum += sir[1];
        binSum += sir[2];

        rSum += rinSum;
        gSum += ginSum;
        bSum += binSum;

        stackPointer = (stackPointer + 1) % div;
        sir = stack[stackPointer];

        routSum += sir[0];
        goutSum += sir[1];
        boutSum += sir[2];

        rinSum -= sir[0];
        ginSum -= sir[1];
        binSum -= sir[2];

        yi += width;
      }
    }
  }
  //--------------------------------------------------------------------------
  static ui.PictureRecorder getPictureRecorder() {
    return ui.PictureRecorder();
  }

  static ui.Canvas generateCanvas(ui.PictureRecorder pr) {
    return ui.Canvas(pr);
  }

  static Future<ui.Image> canvasToImage(ui.PictureRecorder pr, int w, int h) {
    ui.Picture pic = pr.endRecording();
    return pic.toImage(w, h);
  }

  static Future<ui.Image> rotateByCanvas(ui.Image img, num degrees) {
    var pr = ui.PictureRecorder();
    var canvas = ui.Canvas(pr);

    //Matrix4 mat = Matrix4.rotationZ(degreesToRadian(degrees));
    canvas.drawColor(Colors.green, BlendMode.src);
    canvas.save();
    //canvas.transform(mat.storage);
    canvas.translate(img.width / 2, img.height / 2);
    canvas.rotate(degreesToRadian(degrees).toDouble());
    //canvas.drawImage(img, ui.Offset(-(img.width/2), -(img.height/2)), ui.Paint());
    canvas.translate(
        (-img.width) / 1, (-img.height / 2) * (img.height / img.width));
    canvas.drawImage(img, ui.Offset(0, 0), ui.Paint());
    canvas.restore();

    var pic = pr.endRecording();
    return pic.toImage(img.width, img.height);
  }
}
//--------------------------------------------------------------------------
/// isolate




/*
  ui.ImageFilter.matrix(mat);
  ---------------------------------------------------------------------------
  rotate sample:
  img.Image xx = img.decodeImage(state.editOptions.imageBytes);
  img.Image im = img.copyRotate(xx, 90);
  state.editOptions.imageBytes = Uint8List.fromList(ImageHelper.imageToJpg(im, 100));
  state.editOptions._image = await PicEditorState.bytesToImage(state.editOptions.imageBytes);
  -------------------------------------------
  brightness:
  img.Image image;

  await Future((){
    image = img.decodeImage(state.editOptions.imageBytes);
    image = img.brightness(image, state.brightnessValue.toInt());
    state.editOptions.imageBytes = Uint8List.fromList(img.encodeJpg(image, quality: 100));
  });

  state.editOptions._image = await PicEditorState.bytesToImage(state.editOptions.imageBytes);
 */
