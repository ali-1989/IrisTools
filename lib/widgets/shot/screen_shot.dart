import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;

class ScreenshotController {
  late GlobalKey _containerKey;

  ScreenshotController() {
    _containerKey = GlobalKey();
  }

  Future<File> _capFn(String path, double pixelRatio, ) async {
    try {
      RenderRepaintBoundary boundary = _containerKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      if (path == '') {
        final directory = (await getApplicationDocumentsDirectory()).path;
        String fileName = DateTime.now().toIso8601String();
        path = '$directory/$fileName.png';
      }

      File imgFile = File(path);
      await imgFile.writeAsBytes(pngBytes);
      return imgFile;
    }
    catch (e) {
      rethrow;
    }
  }

  Future<File> captureToFile({String path = '', double pixelRatio = 1, Duration delay = const Duration(milliseconds: 20)}) {
    return Future.delayed(delay, () => _capFn(path, pixelRatio));
  }


  Future<ui.Image> captureAsUiImage({double pixelRatio = 1, Duration delay = const Duration(milliseconds: 20)}) {
    return Future.delayed(delay, () async {
      try {
        RenderRepaintBoundary boundary = _containerKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
        return await boundary.toImage(pixelRatio: pixelRatio);
      }
      catch (e) {
        rethrow;
      }
    });
  }

}
///=============================================================================================================
class Screenshot<T> extends StatefulWidget {
  final Widget? child;
  final ScreenshotController? controller;
  final GlobalKey containerKey;

  const Screenshot({Key? key, this.child, this.controller, required this.containerKey}) : super(key: key);

  @override
  State<Screenshot> createState() {
    return ScreenshotState();
  }
}
///=============================================================================================================
class ScreenshotState extends State<Screenshot> with TickerProviderStateMixin {
  late ScreenshotController _controller;

  @override
  void initState() {
    super.initState();

    if (widget.controller == null) {
      _controller = ScreenshotController();
    } else {
      _controller = widget.controller!;
    }
  }

  @override
  void didUpdateWidget(Screenshot oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {

      if (widget.controller == null && oldWidget.controller != null) {
        _controller._containerKey = oldWidget.controller!._containerKey;
      }

      if (widget.controller != null) {
        widget.controller!._containerKey = oldWidget.controller!._containerKey;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _controller._containerKey,
      child: widget.child,
    );
  }
  ///===============================================================================================
  /*todo static Future<Uint8List> widgetToImage(Widget widget) async {
    final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();
    final PipelineOwner pipelineOwner = PipelineOwner(); // allows us to manage a separate render tree
    final BuildOwner buildOwner = BuildOwner(); // allows us to manage a separate element tree
    Size logicalSize = ui.window.physicalSize / ui.window.devicePixelRatio;
    Size imageSize = ui.window.physicalSize;

    final RenderView renderView = RenderView(
      window: null, // pass null since we don't want it to paint onscreen
      child: RenderPositionedBox(alignment: Alignment.center, child: repaintBoundary),
      configuration: ViewConfiguration(size: logicalSize, devicePixelRatio: 1.0 *//* or ui.window.devicePixelRatio*//*),
    );

    pipelineOwner.rootNode = renderView; // attach renderView as the root node. A root node is a unique object without a parent.
    renderView.prepareInitialFrame(); // Doesn't schedule the first frame

    final RenderObjectToWidgetElement<RenderBox> rootElement = RenderObjectToWidgetAdapter<RenderBox>(
      container: repaintBoundary,
      child: widget,
    ).attachToRenderTree(buildOwner);

    buildOwner.buildScope(rootElement); // Creates a scope for updating the widget tree and call the given callback
    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();

    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    final ui.Image image = await repaintBoundary.toImage(pixelRatio: imageSize.width / logicalSize.width);
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }*/
}