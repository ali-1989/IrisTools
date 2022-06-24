library widget_record;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;

class WidgetRecorder extends StatefulWidget {
  final Widget? child;
  final WidgetRecorderController controller;

  WidgetRecorder({Key? key, this.child, required this.controller,}) : super(key: key);

  @override
  _WidgetRecorderState createState() => _WidgetRecorderState();
}
///=================================================================================================================
class _WidgetRecorderState extends State<WidgetRecorder> {
  late WidgetRecorderController _controller;

  @override
  void initState() {
    super.initState();

    /*if (widget.controller == null)
      _controller = WidgetRecorderController(childAnimationCtr: null);
    else*/
      _controller = widget.controller;
  }

  @override
  void didUpdateWidget(WidgetRecorder oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      _controller = widget.controller;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(key: _controller._containerKey, child: widget.child,);
  }
}
///=================================================================================================================
class WidgetRecorderController {
  late GlobalKey _containerKey;
  late RecorderInfo _recorderInfo;
  List<img.Image>? _frameImages;
  late final AnimationController childAnimationCtr;
  final Fps fps;
  late Completer _newFrameAvailable;
  final ObserverList<VoidCallback> _listeners = ObserverList<VoidCallback>();

  int get _recordedFrameCount => _frameImages == null ? 0 : _frameImages!.length;

  WidgetRecorderController({required this.childAnimationCtr, this.fps = Fps.fps25,}) {
    _containerKey = GlobalKey();
    _recorderInfo = RecorderInfo(Fps.fps50, childAnimationCtr.duration!.inMilliseconds,);
  }

  /// Reset the [childAnimationCtr], play it frame by frame
  /// and record each new frame and add it to an animation
  ///
  /// Returns the recorded animation
  Future<img.Animation> captureAnimation({double pixelRatio = 1,}) async {
    _frameImages = List<img.Image>.empty(growable: true);

    while (_recordedFrameCount < _recorderInfo.totalFrameNeeded) {
      childAnimationCtr.value = _recordedFrameCount / _recorderInfo.totalFrameNeeded;
      requestFrame();
      _newFrameAvailable = Completer();
      await _newFrameAvailable.future;
      final image = await _captureAsUiImage(pixelRatio: pixelRatio);
      await _addUiImageToAnimation(image);
    }

    return _createAnimation();
  }

  Future _addUiImageToAnimation(ui.Image image) async {
    final frameDuration = Duration(milliseconds: _recorderInfo.frameDurationsInMs[_recordedFrameCount],);

    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final List<int> pngBytes = byteData!.buffer.asUint8List();
    final decodedImage = img.decodeImage(pngBytes)!..duration = frameDuration.inMilliseconds;
    decodedImage.blendMethod = img.BlendMode.over;
    _frameImages!.add(decodedImage);
  }

  img.Animation _createAnimation() {
    final animation = img.Animation();
    for (var frame in _frameImages!) {
      animation.addFrame(frame);
    }

    return animation;
  }

  Future<ui.Image> _captureAsUiImage({double pixelRatio = 1, Duration delay = const Duration(milliseconds: 20)}) {

    return Future.delayed(delay, () async {
      try {
        final boundary = _containerKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
        return await boundary.toImage(pixelRatio: pixelRatio);
      }
      catch (e) {
        rethrow;
      }
    });
  }

  void requestFrame() {
    notifyListeners();
  }

  void newFrameReady() {
    _newFrameAvailable.complete();
  }

  /// Calls the listener every time a new frame is requested.
  ///
  /// Listeners can be removed with [removeListener].
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  /// Stop calling the listener every time a new frame is requested.
  ///
  /// Listeners can be added with [addListener].
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  /// Calls all the listeners.
  ///
  /// If listeners are added or removed during this function, the modifications
  /// will not change which listeners are called during this iteration.
  void notifyListeners() {
    final localListeners = List<VoidCallback>.from(_listeners);

    for (final listener in localListeners) {
      //InformationCollector collector;

      try {
        if (_listeners.contains(listener)) {
          listener();
        }
      }
      catch (exception, stack) {
        FlutterError.reportError(FlutterErrorDetails(exception: exception, stack: stack,
          context: ErrorDescription('while notifying listeners for $runtimeType'),
          //informationCollector: collector,
        ));
      }
    }
  }
}
///=================================================================================================================
class Fps {
  final int _value;

  const Fps._(this._value);

  int toInt() {
    return _value;
  }

  static const Fps fps5 = Fps._(5);
  static const Fps fps10 = Fps._(10);
  static const Fps fps20 = Fps._(20);
  static const Fps fps25 = Fps._(25);
  static const Fps fps50 = Fps._(50);
}
///=================================================================================================================
class RecorderInfo {
  final Fps fps;
  late int totalFrameNeeded;
  late List<int> frameDurationsInMs;

  RecorderInfo(this.fps, int durationInMs) {
    final dottedFrameCount = (fps.toInt() * durationInMs).roundToDouble() / 1000;
    final frameDurationInMs = (1000 / fps.toInt()).round();

    if (dottedFrameCount.round().roundToDouble() == dottedFrameCount) {
      totalFrameNeeded = dottedFrameCount.round();
      frameDurationsInMs = List<int>.filled(totalFrameNeeded, frameDurationInMs);
    }
    else {
      totalFrameNeeded = dottedFrameCount.floor() + 1;
      frameDurationsInMs = List<int>.filled(totalFrameNeeded, frameDurationInMs);
      frameDurationsInMs.last = durationInMs - (dottedFrameCount.floor() * frameDurationInMs);
    }
  }
}