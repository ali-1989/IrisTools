part of 'imageCropper.dart';

class ImageCropperCtr {
  late ImageCropperState state;
  late EditorState editState;
  late RenderBox renderBox;

  ImageCropperCtr();

  void onInitState(State s){
    state = s as ImageCropperState;

    editState = EditorState();
    editState.editOptions = state.widget.editOptions;

    editState.cropArea = CropArea();
    editState.cropAreaTouchHandler = CropAreaTouchHandler(cropArea: editState.cropArea!);
  }

  void onBuild(){
    editState.cropArea!.canResizeBox = editState.editOptions.canResizeBox;
  }

  void onDispose(){
  }
  ///==============================================================================================
  void onPanUpdate(PointerEvent event) {
    onUpdate(event.position);
  }

  void onPanEnd(PointerEvent event) {
    editState.oldTouchPosition = null;
    editState.currentTouchPosition = null;

    state.update();
  }

  void onUpdate(Offset globalPosition) {
    editState.oldTouchPosition = editState.currentTouchPosition;
    editState.currentTouchPosition = renderBox.globalToLocal(globalPosition);

    if (editState.oldTouchPosition == null) {
      editState.cropAreaTouchHandler!.startTouch(editState.currentTouchPosition!);
    }
    else {
      editState.cropAreaTouchHandler!.updateTouch(editState.currentTouchPosition!);
    }

    state.update();
  }

  Future<void> rotateImage() async {
    final image = editState.editOptions.image;
    ui.Image newImage;
    var pixel = 0;
    var attempts = 0;

    do {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      canvas.rotate(pi / 2.0);
      canvas.translate(0.0, -image.height.toDouble());
      canvas.drawImage(image, Offset.zero, Paint());

      final picture = recorder.endRecording();
      newImage = await picture.toImage(image.height, image.width);
      picture.dispose();

      final newByteData = await newImage.toByteData();
      try {
        pixel = newByteData!.getUint8(newByteData.lengthInBytes - 1);
      }
      catch (e) {
        Logger.L.logToScreen(e.toString());
        pixel = -1;
      }

      attempts++;
    } while (pixel == 0 && attempts < 4);

    editState.editOptions.image = newImage;
    state.update();
  }

  Future<ui.Image> cropImage() async {
    final yOffset = (editState.editorSize!.height - editState.fittedImageSize!.destination.height) / 2.0;
    final xOffset = (editState.editorSize!.width - editState.fittedImageSize!.destination.width) / 2.0;

    final fittedCropRect = Rect.fromCenter(
      center: Offset(
        editState.cropArea!.cropRect!.center.dx - xOffset,
        editState.cropArea!.cropRect!.center.dy - yOffset,
      ),
      width: editState.cropArea!.cropRect!.width,
      height: editState.cropArea!.cropRect!.height,
    );

    final scale = editState.imageSize!.width / editState.fittedImageSize!.destination.width;
    final imageCropRect = Rect.fromLTRB(
        fittedCropRect.left * scale,
        fittedCropRect.top * scale,
        fittedCropRect.right * scale,
        fittedCropRect.bottom * scale);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawImage(editState.editOptions.image, Offset(-imageCropRect.left, -imageCropRect.top), Paint(),);

    final picture = recorder.endRecording();
    final croppedImage = await picture.toImage(imageCropRect.width.toInt(), imageCropRect.height.toInt(),);

    picture.dispose();

    return croppedImage;
  }

  static Future<ui.Image> bytesToImage(Uint8List imgBytes) async{
    ui.Codec codec = await ui.instantiateImageCodec(imgBytes);
    ui.FrameInfo frame = await codec.getNextFrame();
    return frame.image;
  }
}