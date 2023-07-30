import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:math';
import 'dart:ui' as ui;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iris_tools/api/helpers/imageHelper.dart';
import 'package:video_player/video_player.dart';

/// flutter_ffmpeg

enum ImageOrientation {
  square,
  landscape,
  portland
}
///==============================================================================================
class MediaHelper {
  MediaHelper._();

  static ImageOrientation getImageOrientation(int w, int h){
    if((w - h).abs() < 16){
      return ImageOrientation.square;
    }

    if(w > h){
      return ImageOrientation.landscape;
    }

    return ImageOrientation.portland;
  }

  static bool isLandscape(int w, int h) {
    return w >= h;
  }

  static bool isPortland(int w, int h) {
    return h > w;
  }

  static Point<int> getMaxSize(int w, int h, int maxW, int maxHLandscape, int maxHPortland) {
    var state = getImageOrientation(w, h);

    if(state == ImageOrientation.square){
      var v = math.min(w, maxW);
      return Point(v, v);
    }

    return state == ImageOrientation.landscape?
      Point(math.min(w, maxW), math.min(h, maxHLandscape))
        : Point(math.min(w, maxW), math.min(h, maxHPortland));
  }

  /*static Future<MediaInfo> getLocalVideoInfo(String vidPath) async {
    return VideoCompress.getMediaInfo(vidPath);
  }*/

  static Future<VideoPlayerController> getLocalVideoInfo(String vidPath) async {
    var info = VideoPlayerController.file(File(vidPath));
    await info.initialize();
    return info;
  }

  static Future<VideoPlayerController> getRemoteVideoInfo(String vidLink) async {
    var controller = VideoPlayerController.networkUrl(Uri.parse(vidLink));
    await controller.initialize();
    return controller;
  }

  static Future<math.Point> getLocalVideoDim(String vidPath) async {
    var controller = VideoPlayerController.file(File(vidPath));
    await controller.initialize();
    math.Point p = math.Point(controller.value.size.width, controller.value.size.height);
    controller.dispose();

    return p;
  }

  static Future<Duration?> getLocalAudioDuration(String filePath) async {
    final AudioPlayer player = AudioPlayer();
    await player.setSourceDeviceFile(filePath);
    final d = await player.getDuration();

    player.dispose();

    return d;
  }

  static Future<Duration?> getRemoteAudioDuration(String url) async {
    final AudioPlayer player = AudioPlayer();
    await player.setSourceUrl(url);
    final d = await player.getDuration();

    player.dispose();

    return d;
  }

  static Future<math.Point?> getImageDimFromBytes(Uint8List bytes) {
    return ImageHelper.getImageDimByBytesB(bytes);
  }

  static Future<math.Point> getImageDimFromPath(String path) async {
    return ImageHelper.getImageDimC(path);
  }

  static Future<math.Point?> getImageDimFromAsset(String asset) async {
    ByteData data = await rootBundle.load(asset);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    ui.FrameInfo fi = await codec.getNextFrame();

    var res = math.Point(fi.image.width, fi.image.height);
    fi.image.dispose();

    return res;
  }

  static Future<ImageInfo> getImageInfoFromFile(File img) async {
    return getImageInfo(Image.file(img));
  }

  static Future<ImageInfo> getImageInfo(Image img) async {
    final c = Completer<ImageInfo>();

    img.image.resolve(ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo i, bool _) {
          c.complete(i);
      })
    );

    return c.future;
  }
  ///-----------------------------------------------------------------------------------------------------------------
  /// video: Url or Path
  /*static Future<File?> screenshotVideoToFile(String videoPath,{
    int quality = 80,
    int timeMs = -1,
    }) async{

    return await VideoCompress.getFileThumbnail(
        videoPath,
        quality: quality,
        position: timeMs // millisecond
    );
  }

static Future<Uint8List?> screenshotVideo(String videoPath,{
    //ImageFormat outFormat: ImageFormat.PNG,
    //int maxWidth: 0,
    //int maxHeight: 0,
    int quality = 80,
    int timeMs = -1,
  }) async{

  return await VideoCompress.getByteThumbnail(
      videoPath,
      quality: quality,
      position: timeMs // millisecond
  );
    /*return await VideoThumbnail.thumbnailData(
        video: urlOrPath,
        imageFormat: outFormat,
        maxHeight: maxHeight,
        maxWidth: maxWidth,
        timeMs: timeMs,
        quality: quality);*/
  }*/
}