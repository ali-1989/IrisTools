import 'package:flutter/material.dart';
import 'package:iris_tools/api/helpers/widgetHelper.dart';

class OverflowTouchable extends StatefulWidget {
  final Widget child;
  final Offset? offset;
  final ScrollController? scrollController;
  final GlobalKey? scrollWidgetKey;

  OverflowTouchable({
    super.key,
    required this.child,
    this.offset,
    this.scrollController,
    this.scrollWidgetKey,
  }) : assert((){
    if(scrollController == null){
      return true;
    }
    else {
      if(scrollWidgetKey == null){
        return false;
      }

      return true;
    }
  }());

  @override
  State createState() => _OverflowTouchableState();
}
///=============================================================================
class _OverflowTouchableState extends State<OverflowTouchable> {
  final overlayController = OverlayPortalController();
  final link = LayerLink();
  double top = 0;
  late BuildContext childContext;

  @override
  void initState() {
    super.initState();

    overlayController.show();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.scrollController != null) {
        widget.scrollController!.addListener(onScroll);
      }
    });
  }

  @override
  void dispose() {
    if (widget.scrollController != null) {
      widget.scrollController!.removeListener(onScroll);
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: link,
      child: OverlayPortal(
        controller: overlayController,
        overlayChildBuilder: (ctx1) {
          return CompositedTransformFollower(
            link: link,
            offset: widget.offset ?? Offset.zero,
            showWhenUnlinked: false,
            targetAnchor: Alignment.center,
            followerAnchor: Alignment.center,
            child: UnconstrainedBox(
              child: Builder(
                  builder: (ctx2) {
                    childContext = ctx2;
                    if (widget.scrollController == null) {
                      return widget.child;
                    }

                    return ClipRect(
                      clipBehavior: Clip.antiAlias,
                      clipper: SomeClipper(
                        top: top,
                      ),
                      child: Builder(
                        builder: (ctx3) {
                          childContext = ctx3;
                          return widget.child;
                        }
                      ),
                    );
                  }
              ),
            ),
          );
        },
        child: const SizedBox(
          width: 5,
          height: 5,
        ),
      ),
    );
  }

  void onScroll() {
    //widget.scrollController!.offset == position.pixels == position.extentBefore
    // axisDirection
    final myOffset = WidgetHelper.getPositionAfterRender(childContext);
    //final myConstrain = WidgetHelper.getBoxConstraints(childContext);

    final scrollOffset = WidgetHelper.getPositionAfterRender(widget.scrollWidgetKey!.currentContext!);
    //final scrollConstrain = WidgetHelper.getBoxConstraints(widget.scrollWidgetKey!.currentContext!);

    //final myPaint = WidgetHelper.getPaintBounds(childContext);

    /*Rect scrollRect = Rect.fromLTWH(
        scrollOffset.dx,
        scrollOffset.dy,
        scrollOffset.dx + scrollConstrain.maxWidth,
        scrollOffset.dy + scrollConstrain.maxHeight,
    );*/

    //bool isIn = scrollRect.contains(myOffset);
    //isIn = isIn && scrollRect.contains(Offset(myOffset.dx + myConstrain.maxWidth, myOffset.dy + myConstrain.maxHeight));

    top = scrollOffset.dy - myOffset.dy;

    if(top < 0){
      top = 0;
    }

    setState(() {});
    //if(!isIn) {}
  }
}
///=============================================================================
class SomeClipper extends CustomClipper<Rect> {
  double top;
  double left;
  double? right;
  double? bottom;

  SomeClipper({this.left = 0, this.top = 0, this.right, this.bottom});
  
  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(left, top, right?? size.width, bottom?? size.height);
  }

  @override
  bool shouldReclip(SomeClipper oldClipper) => true;
}