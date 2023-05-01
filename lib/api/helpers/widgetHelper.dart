import 'package:flutter/material.dart';
import 'package:iris_tools/api/helpers/fileHelper.dart';

class WidgetHelper {
  WidgetHelper._();

  static bool isMounted(BuildContext context) {
    return (context as Element).mounted;
  }

  static void rebuildWidget(BuildContext context) {
    (context as Element).markNeedsBuild();
  }

  static void rebuildAllChildren(BuildContext context) {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }

  // return false for break continue.
  static void touchChildren(BuildContext context, bool Function(Element elem) onChild) {
    final e = context as Element;
    //var hash = context.hashCode;

    void fn(element) {
      //hash = element.hashCode;
      if(!onChild(element)) {
        return;
      }

      element.visitChildren(fn);
    }

    //  visitChildElements() throw exception
    e.visitChildren(fn);
  }

  // a page ... FocusScope > PageStorage > Offstage ... [root]
  // return false for break
  static void touchAncestorsToRoot(BuildContext context, bool Function(Element elem) onParent) {
    final e = context as Element;

    e.visitAncestorElements((element) {
      return onParent(element);
      //return true;
    });
  }

  static Widget? findChildWidget(BuildContext ctx, TypeFinder type) {
    Widget? res;

    void checkR1(Element element) {
      if (res == null && type.check(element.widget)) {
        res = element.widget;
      }
    }

    void checkDeep(Element element) {
      checkR1(element);

      if (res == null) {
        element.visitChildElements(checkDeep);
      }
    }

    /// see child in any widget and see children (level 1) in list widgets
    ctx.visitChildElements(checkR1);

    /// see string of children in all widgets (simple or list)
    if (res == null) {
      ctx.visitChildElements(checkDeep);
    }

    return res;
  }

  static T? findChildState<T extends State>(BuildContext ctx) {
    T? res;

    void checkR1(element) {
      if (element is StatefulElement) {
        final statefulChild = element;

        //if(statefulChild.state is T && statefulChild.state.runtimeType == type) {
        if (res == null && statefulChild.state is T) {
          res = statefulChild.state as T;
        }
      }
    }

    void checkDeep(element) {
      checkR1(element);

      if (res == null) {
        element.visitChildElements(checkDeep);
      }
    }

    ctx.visitChildElements(checkR1);

    if (res == null) {
      ctx.visitChildElements(checkDeep);
    }

    return res;
  }

  static void saveChildrenToFile(BuildContext context, String saveFile) async {
    final tab = ' ';
    var buf = '';
    FileHelper.createNewFileSync('/storage/emulated/0/FamilyBank/$saveFile');
    var firstDeap = 0;
    final lines = <String>[];

    void func(BuildContext ctx) {
      ctx.visitChildElements((Element element) {
        try {
          final s = '${element.widget.runtimeType.toString()}_${element.depth}\n';

          for(var i=0; i<element.depth - firstDeap; i++){
            buf += tab;
          }
          buf += s;
        }
        catch (e){}

        lines.add(buf);
        buf = '';

        func(element);
      });
    }

    firstDeap = (context as Element).depth;
    func(context);

    for(var x in lines) {
      FileHelper.appendStringSync('/storage/emulated/0/FamilyBank/$saveFile', x);
    }
  }

  static Future<List<Widget>> getAllChildren(BuildContext context) async {
    final res = <Widget>[];

    void func(BuildContext ctx) {
      final el = ctx as Element;

      el.visitChildren((element) {
        try {
          res.add(element.widget);
        }
        catch (e){}

        func(element);
      });

      /* throw: Unhandled Exception: visitChildElements() called during build.
      ctx.visitChildElements((Element element) {
        try {
          res.add(element.widget);
        }
        catch (e){}

        func(element);
      }); */
    }

    func(context);

    return res;
  }

  static BuildContext getLastRouteContext(BuildContext context){
    final list = _getAllPages(context);
    return list.last;
  }

  static BuildContext findEndChildContext(BuildContext context){
    //var hash = context.hashCode;
    var last = context;
    var maxDepth = -1;

    void fn(Element element) {
      //hash = element.hashCode;
      if(element.depth > maxDepth) {
        last = element;
        maxDepth = element.depth;
      }

      element.visitChildElements(fn);
    }

    context.visitChildElements(fn);

    return last;
  }

  static FocusManager? findFocusManager({BuildContext? base}) {
    if(base != null) {
      return base.owner?.focusManager;
    }

    return FocusManager.instance;
  }

  static Element getElement(BuildContext context) {
    return context as Element;
  }

  static StatefulElement getStatefulElement(BuildContext context) {
    return context as StatefulElement;
  }

  static ComponentElement getComponentElement(BuildContext context) {
    return context as ComponentElement;
  }

  /// must call after finish build
  static Size? getElementSize(BuildContext context) {
    return getElement(context).size;
  }

  static Size getSizeAfterRender(BuildContext context) {
    return (context.findRenderObject() as RenderBox).size;
  }

  static BoxConstraints getBoxConstraints(BuildContext context) {
    return (context.findRenderObject() as RenderBox).constraints;
  }

  /// for shadow,...
  static Rect getPaintBounds(BuildContext context) {
    return (context.findRenderObject() as RenderBox).paintBounds;
  }

  static Offset getPositionAfterRender(BuildContext context) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    return box.localToGlobal(Offset.zero); // Global is SafeArea box
  }

  static int getDeep(BuildContext context) {
    return getElement(context).depth;
  }

  static Widget getWidget(BuildContext context) {
    return getElement(context).widget;
  }

  static Future updateWidget(BuildContext context, Widget newWidget) async {
    try {
      getElement(context).update(newWidget);
    } catch (e) {
      await Future.delayed(Duration(milliseconds: 500), () {});
      getElement(context).markNeedsBuild();
    }

    return Future.value();
  }

  static RenderObject? getRenderObject(BuildContext context) {
    return getElement(context).renderObject;
  }

  static RenderBox? getRenderBox(BuildContext context) {
    return getElement(context).renderObject as RenderBox;
  }

  static Element? getParentElement(BuildContext context) {
    Element? parent;

    /// go up until arrive to first of current Page, can not visit previous page's elements
    getElement(context).visitAncestorElements((element) {
      if (parent == null) {
        parent = element;
        return false;
      }

      // continue
      return true;
    });

    return parent;
  }

  static List<BuildContext> _getAllPages(BuildContext context) {
    final nav = Navigator.of(context);
    final List children = nav.focusScopeNode.children.toList();
    final res = <BuildContext>[];

    for (FocusNode f in children) {
      res.add(f.context!);
    }

    return res;
  }

  static Element? getPreviousPageElement(BuildContext context) {
    final pages = _getAllPages(context);

    for (var p in pages.reversed) {
      if (!ModalRoute.of(p)!.isCurrent) {
        return p as Element;
      }
    }

    return null;
  }

  static T? castParentWidgetAs<T extends Widget>(BuildContext context) {
    final parent = getParentElement(context);
    return parent?.widget as T;
  }

  //  MaterialApp s = findAncestorWidgetFor(context);
  static T? findAncestorWidgetFor<T extends Widget>(BuildContext context) {
    final w = context.findAncestorWidgetOfExactType();
    return w as T;
  }

  ///--------------- scaffold
  static Scaffold? getNearestChildScaffold(BuildContext context) {
    final Scaffold w = findChildWidget(context, TypeFinder<Scaffold>()) as Scaffold;
    return w;
  }

  static Scaffold? getNearestAncestorScaffold(BuildContext context) {
    final Scaffold w = context.findAncestorWidgetOfExactType() as Scaffold;
    return w;
  }

  static ScaffoldState? getScaffoldStateOf(BuildContext context) {
    return Scaffold.maybeOf(context);
  }
  ///-----------------------------------------------------------------------------
  static Size? getWHOfWidget(BuildContext ctx, Widget widget) {
    final key = GlobalKey();

    final overlayEntry = OverlayEntry(
      builder: (context) {
        return Opacity(
          key: key,
          opacity: 0.01,
          child: widget,
        );
      },
    );

    final parent = getPreviousPageElement(ctx);
    ModalRoute.of(parent!)?.navigator?.overlay?.insert(overlayEntry);
    //Overlay.of(parent).insert(overlayEntry);
    final s = key.currentContext?.size;

    overlayEntry.remove();

    return s;
  }
  ///======================================================================================================
  /*static Size getSizeOfWidget(Widget myWidget) {
    //todo : not work, search in net
    final Widget w = Directionality(
      child: myWidget,
      textDirection: TextDirection.ltr,
    );
    final RenderProxyBox render = RenderProxyBox();
    final PipelineOwner pipelineOwner =
        PipelineOwner(); // allows us to manage a separate render tree
    final BuildOwner buildOwner =
        BuildOwner(); // allows us to manage a separate element tree
    Size logicalSize = ui.window.physicalSize / ui.window.devicePixelRatio;

    final RenderView renderView = RenderView(
      window: null, // pass null since we don't want it to paint onscreen
      configuration: ViewConfiguration(
          size: logicalSize,
          devicePixelRatio: 1.0 *//* or ui.window.devicePixelRatio*//*),
      child: RenderPositionedBox(alignment: Alignment.center, child: render),
    );

    pipelineOwner.rootNode =
        renderView; // attach renderView as the root node. A root node is a unique object without a parent.
    renderView.prepareInitialFrame();

    final RenderObjectToWidgetElement<RenderBox> rootElement =
        RenderObjectToWidgetAdapter<RenderBox>(
      container: renderView,
      child: w,
    ).attachToRenderTree(buildOwner);

    buildOwner.buildScope(
        rootElement); // Creates a scope for updating the widget tree and call the given callback
    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();

    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    /// same: render.size
    return rootElement.size;
  }*/
}

///======================================================================================================
class TypeFinder<T> {
  const TypeFinder();

  bool check(dynamic object) => object is T;
}
