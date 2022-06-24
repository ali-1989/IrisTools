import 'package:iris_tools/api/panGestureRecognizer.dart';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:iris_tools/api/logger/logger.dart';

part 'imageCropperCtr.dart';
/// src: https://pub.dev/packages/image_crop_widget

class ImageCropper extends StatefulWidget {
  final EditOptions editOptions;

  //old; assert(editOptions != null), assert(editOptions.image != null)
  ImageCropper(this.editOptions, {Key? key}) : super(key: key);

  @override
  ImageCropperState createState() => ImageCropperState();
}
///===================================================================================
class ImageCropperState extends State<ImageCropper> {
  var controller = ImageCropperCtr();

  @override
  void initState() {
    super.initState();
    controller.onInitState(this);
  }

  @override
  Widget build(BuildContext context) {
    controller.onBuild();

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: controller.editState.editOptions.backgroundColor,
      child: CustomPaint(
        painter: _ImagePainter(controller.editState),
        foregroundPainter: _CropBoxPainter(controller.editState),
        child: RawGestureDetector(
          gestures: {
            PanGestureRecognizer: GestureRecognizerFactoryWithHandlers<PanGestureRecognizer>(
                  () => PanGestureRecognizer(
                    onPanStart: controller.onPanUpdate,
                    onPanMove: controller.onPanUpdate,
                    onPanEnd: controller.onPanEnd,
                  ),
                  (PanGestureRecognizer recognizer) {},
            )
          },
        ),
      ),
    );
  }

  void update(){
    setState(() {});
  }
}
///================================================================================================
class EditOptions {
  EditOptions(this.image);

  ui.Image image;
  Color backgroundColor = Colors.black;
  Color iconsColor = Colors.white;
  Color cropBoxColor = Colors.white30;
  Color cropBoxCornerColor = Colors.grey[300]!;
  Size cropBoxInitSize = Size(130, 200);
  bool canResizeBox = true;
  bool fillBoxRect = true;
  double cropCornerSize = 12;
  double cropBoxLineSize = 2;
}
///================================================================================================
class EditorState {
  EditorState();
  
  late EditOptions editOptions;
  Offset? currentTouchPosition;
  Offset? oldTouchPosition;
  Size? editorSize;
  Size? imageSize;
  FittedSizes? fittedImageSize;
  double? horizontalGap;
  double? verticalGap;
  Rect? imageContainingRect;
  CropArea? cropArea;
  CropAreaTouchHandler? cropAreaTouchHandler;
}
///================================================================================================
class _ImagePainter extends CustomPainter {
  final EditorState editorState;

  _ImagePainter(this.editorState);

  @override
  void paint(ui.Canvas canvas, ui.Size paintSize) {
    editorState.editorSize = paintSize;

    Rect displayRect = Rect.fromLTWH(0.0, 0.0, paintSize.width, paintSize.height);
    paintImage(
      canvas: canvas,
      image: editorState.editOptions.image,
      rect: displayRect,
      fit: BoxFit.contain,
    );

    editorState.imageSize = Size(
      editorState.editOptions.image.width.toDouble(),
      editorState.editOptions.image.height.toDouble(),
    );

    editorState.fittedImageSize = applyBoxFit(
      BoxFit.contain,
      editorState.imageSize!,
      paintSize,
    );

    editorState.horizontalGap = (paintSize.width - editorState.fittedImageSize!.destination.width) / 2;
    editorState.verticalGap = (paintSize.height - editorState.fittedImageSize!.destination.height) / 2;
    editorState.imageContainingRect = Rect.fromLTWH(
        editorState.horizontalGap!,
        editorState.verticalGap!,
        editorState.fittedImageSize!.destination.width,
        editorState.fittedImageSize!.destination.height);
  }

  @override
  bool shouldRepaint(_ImagePainter oldDelegate) {
    return editorState.editOptions.image != oldDelegate.editorState.editOptions.image;
  }
}
///================================================================================================
class _CropBoxPainter extends CustomPainter {
  final EditorState editorState;
  final paintCorner = Paint();
  final paintBox = Paint();

  _CropBoxPainter(this.editorState){
    paintCorner.strokeWidth = editorState.editOptions.cropCornerSize;
    paintCorner.strokeCap = StrokeCap.round;
    paintCorner.color = editorState.editOptions.cropBoxCornerColor;

    paintBox.color = editorState.editOptions.cropBoxColor;
    paintBox.strokeWidth = editorState.editOptions.cropBoxLineSize;

    if(!editorState.editOptions.fillBoxRect) {
      paintBox.style = PaintingStyle.stroke;
    }
  }

  @override
  void paint(Canvas canvas, Size paintSize) {
    if (editorState.cropArea!.cropRect == null) {
      editorState.cropArea!.setValues(
        bounds: editorState.imageContainingRect!,
        center: Offset(paintSize.width / 2, paintSize.height / 2),
        width: editorState.editOptions.cropBoxInitSize.width,
        height: editorState.editOptions.cropBoxInitSize.height,
      );
    }

    canvas.drawRect(editorState.cropArea!.cropRect!, paintBox);

    final points = <Offset>[
      editorState.cropArea!.cropRect!.topLeft,
      editorState.cropArea!.cropRect!.topRight,
      editorState.cropArea!.cropRect!.bottomLeft,
      editorState.cropArea!.cropRect!.bottomRight
    ];

    canvas.drawPoints(ui.PointMode.points, points, paintCorner);
  }

  @override
  bool shouldRepaint(_CropBoxPainter oldDelegate) {
    return editorState.cropArea!.cropRect != oldDelegate.editorState.cropArea!.cropRect;
  }
}
///================================================================================================
class CropAreaTouchHandler {
  final CropArea cropArea;
  late Offset activeAreaDelta;
  late CropTouchCorner activeArea;

  CropAreaTouchHandler({required CropArea cropArea}) : cropArea = cropArea;

  void startTouch(Offset touchPosition) {
    activeArea = cropArea.getActionArea(touchPosition);
    activeAreaDelta = cropArea.getActionAreaDelta(touchPosition, activeArea);
  }

  void updateTouch(Offset touchPosition) {
    cropArea.moveOrResize(touchPosition, activeAreaDelta, activeArea);
  }

  void endTouch() {
    //activeArea = null;
    //activeAreaDelta = null;
  }
}
///================================================================================================
class CropArea {
  double _sizeOfCornerTouch = 40;
  bool canResizeBox = true;
  late Rect _boundsRect;
  Rect? _cropRect;
  late Rect _topLeftCorner;
  late Rect _topRightCorner;
  late Rect _bottomRightCorner;
  late Rect _bottomLeftCorner;

  CropArea();

  Rect? get cropRect => _cropRect;

  void setValues({
    required Offset center,
    required double width,
    required double height,
    required Rect bounds,
    double? cornerTouchSize
  }) {
    if(cornerTouchSize != null) {
      _sizeOfCornerTouch = cornerTouchSize;
    }

    _boundsRect = bounds;
    _cropRect = Rect.fromCenter(center: center, width: width, height: height);

    _updateCorners();
  }

  void _updateCorners() {
    _topLeftCorner = Rect.fromCenter(
      center: _cropRect!.topLeft,
      width: _sizeOfCornerTouch,
      height: _sizeOfCornerTouch,
    );
    
    _topRightCorner = Rect.fromCenter(
      center: _cropRect!.topRight,
      width: _sizeOfCornerTouch,
      height: _sizeOfCornerTouch,
    );
    
    _bottomRightCorner = Rect.fromCenter(
      center: _cropRect!.bottomRight,
      width: _sizeOfCornerTouch,
      height: _sizeOfCornerTouch,
    );
    
    _bottomLeftCorner = Rect.fromCenter(
      center: _cropRect!.bottomLeft,
      width: _sizeOfCornerTouch,
      height: _sizeOfCornerTouch,
    );
  }

  bool contains(Offset position) {
    return _cropRect!.contains(position) ||
        _topLeftCorner.contains(position) ||
        _topRightCorner.contains(position) ||
        _bottomRightCorner.contains(position) ||
        _bottomLeftCorner.contains(position);
  }

  void moveArea(Offset newCenter) {
    final newRect = Rect.fromCenter(
      center: newCenter,
      width: _cropRect!.width,
      height: _cropRect!.height,
    );

    var offset = Offset(0.0, 0.0);
    
    if (newRect.left < _boundsRect.left) {
      offset = offset.translate(_boundsRect.left - newRect.left, 0.0);
    }

    if (newRect.top < _boundsRect.top) {
      offset = offset.translate(0.0, _boundsRect.top - newRect.top);
    }

    if (newRect.right > _boundsRect.right) {
      offset = offset.translate(_boundsRect.right - newRect.right, 0.0);
    }

    if (newRect.bottom > _boundsRect.bottom) {
      offset = offset.translate(0.0, _boundsRect.bottom - newRect.bottom);
    }

    _cropRect = newRect.shift(offset);
    _updateCorners();
  }

  double _applyLeftBounds(double left) {
    var boundedLeft = max(left, _boundsRect.left); // left bound
    boundedLeft = min(boundedLeft, _cropRect!.right - _sizeOfCornerTouch); // right bound
    
    return boundedLeft;
  }

  double _applyTopBounds(double top) {
    var boundedTop = max(top, _boundsRect.top); // top bound
    boundedTop = min(boundedTop, _cropRect!.bottom - _sizeOfCornerTouch); // bottom bound
    
    return boundedTop;
  }

  double _applyRightBounds(double right) {
    var boundedRight = min(right, _boundsRect.right); // right bound
    boundedRight = max(boundedRight, _cropRect!.left + _sizeOfCornerTouch); // left bound
    
    return boundedRight;
  }

  double _applyBottomBounds(double bottom) {
    var boundedBottom = min(bottom, _boundsRect.bottom); // bottom bound
    boundedBottom = max(boundedBottom, _cropRect!.top + _sizeOfCornerTouch); // top bound
    
    return boundedBottom;
  }

  void moveTopLeftCorner(Offset newPosition) {
    _cropRect = Rect.fromLTRB(
      _applyLeftBounds(newPosition.dx),
      _applyTopBounds(newPosition.dy),
      _cropRect!.right,
      _cropRect!.bottom,
    );
    
    _updateCorners();
  }

  void moveTopRightCorner(Offset newPosition) {
    _cropRect = Rect.fromLTRB(
      _cropRect!.left,
      _applyTopBounds(newPosition.dy),
      _applyRightBounds(newPosition.dx),
      _cropRect!.bottom,
    );
    
    _updateCorners();
  }

  void moveBottomRightCorner(Offset newPosition) {
    _cropRect = Rect.fromLTRB(
      _cropRect!.left,
      _cropRect!.top,
      _applyRightBounds(newPosition.dx),
      _applyBottomBounds(newPosition.dy),
    );
    
    _updateCorners();
  }

  void moveBottomLeftCorner(Offset newPosition) {
    _cropRect = Rect.fromLTRB(
      _applyLeftBounds(newPosition.dx),
      _cropRect!.top,
      _cropRect!.right,
      _applyBottomBounds(newPosition.dy),
    );
    
    _updateCorners();
  }

  Offset _getTopLeftDelta(Offset position) {
    return _topLeftCorner.center - position;
  }

  Offset _getTopRightDelta(Offset position) {
    return _topRightCorner.center - position;
  }

  Offset _getBottomRightDelta(Offset position) {
    return _bottomRightCorner.center - position;
  }

  Offset _getBottomLeftDelta(Offset position) {
    return _bottomLeftCorner.center - position;
  }

  Offset _getCenterDelta(Offset position) {
    return _cropRect!.center - position;
  }

  CropTouchCorner getActionArea(Offset position) {
    if (_topLeftCorner.contains(position)) {
      return CropTouchCorner.top_left;
    }

    if (_topRightCorner.contains(position)) {
      return CropTouchCorner.top_right;
    }

    if (_bottomLeftCorner.contains(position)) {
      return CropTouchCorner.bottom_left;
    }

    if (_bottomRightCorner.contains(position)) {
      return CropTouchCorner.bottom_right;
    }

    if (_cropRect!.contains(position)) {
      return CropTouchCorner.center;
    }

    return CropTouchCorner.none;
  }

  Offset getActionAreaDelta(Offset position, CropTouchCorner activeArea) {
    switch (activeArea) {
      case CropTouchCorner.top_left:
        return _getTopLeftDelta(position);
      case CropTouchCorner.top_right:
        return _getTopRightDelta(position);
      case CropTouchCorner.bottom_right:
        return _getBottomRightDelta(position);
      case CropTouchCorner.bottom_left:
        return _getBottomLeftDelta(position);
      case CropTouchCorner.center:
        return _getCenterDelta(position);
      default:
        return Offset.zero;
    }
  }

  void moveOrResize(Offset position, Offset delta, CropTouchCorner actionArea) {
    if(!canResizeBox) {
      if(actionArea == CropTouchCorner.center) {
        moveArea(position + delta);
      }

      return;
    }

    switch (actionArea) {
      case CropTouchCorner.top_left:
        moveTopLeftCorner(position + delta);
        break;
      case CropTouchCorner.top_right:
        moveTopRightCorner(position + delta);
        break;
      case CropTouchCorner.bottom_right:
        moveBottomRightCorner(position + delta);
        break;
      case CropTouchCorner.bottom_left:
        moveBottomLeftCorner(position + delta);
        break;
      case CropTouchCorner.center:
        moveArea(position + delta);
        break;
      default:
    }
  }
}
///================================================================================================
enum CropTouchCorner {
  top_left,
  top_right,
  bottom_right,
  bottom_left,
  center,
  none
}
///================================================================================================