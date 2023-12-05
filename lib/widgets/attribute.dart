import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef ChildBuilder = Widget Function(BuildContext context, AttributeController att, Widget? child);
///========================================================================================================
class Attribute extends StatefulWidget {
  final AttributeController? controller;
  final ChildBuilder? childBuilder;
  final Widget? child;

  Attribute(
      {Key? key,
        this.controller,
        this.child,
        this.childBuilder
      })
      : assert(child != null || childBuilder != null), super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AttributeState();
  }
}
///========================================================================================================
class AttributeState extends State<Attribute> {
  late AttributeController myController;
  late ChildBuilder _childBuilder;

  @override
  void initState() {
    super.initState();

    _childBuilder = widget.childBuilder?? (context, att, child){
      return widget.child?? SizedBox();
    };

    myController = widget.controller?? AttributeController();
    myController._setState(this);
  }

  @override
  Widget build(BuildContext context) {
    return _childBuilder(context, myController, widget.child);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void update(){
    setState(() {});
  }
}
///=============================================================================
class AttributeController {
  AttributeController();

  late AttributeState _state;

  void _setState(AttributeState s){
    //if(!isSet)
      _state = s;
  }

  Size? getSize(){
    return _state.context.size;
  }

  double? getWidth(){
    return _state.context.size?.width;
  }

  double? getHeight(){
    return _state.context.size?.height; // <=> longestSide
  }

  bool? isFinite(){
    return _state.context.size?.isFinite;
  }

  BuildContext getContext(){
    return _state.context;
  }

  BuildOwner? getBuildOwner(){
    return _state.context.owner;
  }

  /// The widget must first be rendered to access the findRenderObject() else it is null.
  RenderBox? getRenderBox(){
    try {
      return _state.context.findRenderObject() as RenderBox;
    }
    catch (e){}

    return null;
  }

  Offset? getPosition(){
    try {
      return getRenderBox()?.localToGlobal(Offset.zero);
    }
    catch (e){}

    return null;
  }

  TextDirection getDirection(){
    return Directionality.of(getContext());
  }

  MediaQueryData getMediaQuery(){
    return MediaQuery.of(getContext());
  }

  double? getPositionX(){
    if(getDirection() == TextDirection.ltr) {
      return getPosition()?.dx;
    }

    return getMediaQuery().size.width - getPosition()!.dx - getWidth()!;
  }

  double? getPositionY(){
    return getPosition()?.dy;
  }

  PipelineOwner? getPipelineOwner(){
    return getRenderBox()?.owner;
  }

  Size? getRenderBoxSize(){
    return getRenderBox()?.size;
  }

  BoxConstraints? getBoxConstraints(){
    return getRenderBox()?.constraints;
  }

  int? getDepth(){
    return getRenderBox()?.depth;
  }

  Widget? getAttributeChild(){
    return _state.widget.child;
  }

  void visitRenderChildren(void Function(RenderObject child) fn){
    getRenderBox()?.visitChildren(fn);
  }

  void visitChildren(void Function(Element child) fn){
    (_state.context as Element).visitChildren(fn);
  }

  T? findChild<T extends Widget>(){
    T? w;

    find(Element e){
      if(e.widget is T){
        w ??= e.widget as T;
      }

      if(w == null) {
        e.visitChildren(find);
      }
    }

    visitChildren(find);

    return w;
  }

  ParentData? getParentData(){
    return getRenderBox()?.parentData;
  }

  Rect? getPaintBounds(){
    return getRenderBox()?.paintBounds;
  }

  bool? isRepaintBoundary(){
    return getRenderBox()?.isRepaintBoundary;
  }

  bool hasSize(){
    return getRenderBox()?.hasSize?? false;
  }

  void update(){
    _state.update();
  }

  OverlayEntry addOverlaySticky(Widget Function(BuildContext context) builder){
    OverlayEntry stickyEntry = OverlayEntry(
      builder: (context) => builder(context),
    );

    getOverlayState()?.insert(stickyEntry);

    return stickyEntry;
  }

  OverlayState? getOverlayState(){
    return Overlay.of(_state.context);
  }
}

/*
  usage:

Align(
    alignment: Alignment.topCenter,
    child: Attribute(
        controller: childAttribute,
        childBuilder: (ctx, att, child){
          return Column();
          }
        )
    )
--------------------------------------------------------------
SingleChildScrollView(
      child: Attribute(
          controller: childAtt,
          childBuilder: (context, att, child){
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              child: IntrinsicHeight(
                child: Column();
                }
              )
           )
       )
-----------------------------------------------------------------
WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      double screenH = viewPortAtt.getHeight()!;
      double childH = childAtt.getHeight()!;

      chartHeight += screenH - childH;

      update();
    });
 */