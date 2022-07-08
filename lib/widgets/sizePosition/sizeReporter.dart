import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef OnWidgetSizeChange = void Function(Size size);

class _SizeReportRenderObject extends RenderProxyBox {
  final OnWidgetSizeChange onSizeChange;
  Size? currentSize;

  _SizeReportRenderObject(this.onSizeChange);

  @override
  void performLayout() {
    super.performLayout();

    try {
      Size? newSize = child?.size;

      if (newSize != null && currentSize != newSize) {
        currentSize = newSize;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          onSizeChange(newSize);
        });
      }
    } catch (e) {
      //rint(e);
    }
  }
}
///============================================================================================
class SizeReporter extends SingleChildRenderObjectWidget {

  final OnWidgetSizeChange onSizeChange;

  const SizeReporter({
    Key? key,
    required this.onSizeChange,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _SizeReportRenderObject(onSizeChange);
  }
}
///===========================================================================================
class MeasureWidget extends SingleChildRenderObjectWidget {
  final OnWidgetSizeChange onChange;
  final bool onlyOnce;

  const MeasureWidget({
    Key? key,
    required this.onChange,
    this.onlyOnce = false,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _MeasureSizeRenderObject(onChange, onlyOnce);
  }
}

class _MeasureSizeRenderObject extends RenderProxyBox {
  double? oldSizeH;
  double? oldSizeW;
  late bool onlyOnce;
  bool detected = false;
  late final OnWidgetSizeChange onChangeSize;

  _MeasureSizeRenderObject(this.onChangeSize, this.onlyOnce);

  @override
  void performLayout() {
    super.performLayout();

    Size newSize = child!.paintBounds.size;

    if (oldSizeH == newSize.height && oldSizeW == newSize.width) {
      return;
    }

    oldSizeH = newSize.height;
    oldSizeW = newSize.width;

    if (onlyOnce && detected) {
      return;
    }

    detected = true;

    WidgetsBinding.instance.addPostFrameCallback((timestamp) {
      onChangeSize(newSize);
    });
  }
}


/*
 usage:
 MeasureWidget(
        onlyOnce: false,
        onChange: (Size size){
          pr-int('size.width ${size.width}');
          state.maxWidth = size.width;
          state.update();
        },
        child: Text('${state.user.userName}',
          maxLines: 1,),
      ),
 */
