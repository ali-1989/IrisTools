import 'package:flutter/widgets.dart';

class IrisDialogNav {
  IrisDialogNav._();

  static NavigatorState? getRootNavigator(){
    var ctx = FocusManager.instance.rootScope.context;

    if(ctx == null){
      final children = FocusManager.instance.rootScope.children;
      var dep = 100;

      for (var element in children) {
        final context = element.context;

        if(context != null){
          final elm = context as Element;

          if(elm.depth < dep){
            dep = elm.depth;
            ctx = context;
          }
        }
      }
    }

    late BuildContext navigatorCtx;

    touchChildren(ctx!, (elem) {
      if(elem.widget is Navigator){
        navigatorCtx = elem;
        return false;
      }

      return true;
    });

    return Navigator.maybeOf(navigatorCtx, rootNavigator: false);
  }

  static NavigatorState? getRootNavigatorBy(BuildContext context) {
    /// no need use: context.dirty

    try {
      /// for avoid: ErrorSummary("Looking up a deactivated widget's ancestor is unsafe.") in framework.dart
      if (context is StatefulElement) {
        if (!context.state.mounted) {
          return null;
        }
      }

      if (context is StatelessElement) {
        if (!(context.renderObject?.attached ?? false)) {
          return null;
        }
      }
    }
    catch (e){
      return null;
    }

    return Navigator.maybeOf(context, rootNavigator: true); // rootNavigator[true]: continue until root /
  }

  static BuildContext getStableContext(BuildContext context) {
    final m = findRouteByName(getAllModalRoutes(context: context), '/');

    return m!.subtreeContext!;
  }

  static ModalRoute? getModalRouteOfOld(BuildContext context){
    if (context is StatefulElement) {
      if (!context.state.mounted || context.dirty) {
        return null;
      }
    }

    if (context is StatelessElement) {
      if (!(context.renderObject?.attached ?? false) || context.dirty) {
        return null;
      }
    }

    return ModalRoute.of(context);
  }

  static ModalRoute? getModalRouteOf(BuildContext context){
    final element = context as Element;
    final runType = element.widget.runtimeType.toString();

    if(runType == '_ModalScopeStatus'){
      final dynamic d = element.widget;

      return d.route as ModalRoute;
    }

    ModalRoute? result;

    touchAncestorsToRoot(context, (elem){
      final runType = elem.widget.runtimeType.toString();

      if(runType == '_ModalScopeStatus'){
        final dynamic d = elem.widget;

        result = d.route as ModalRoute;
        return false;
      }

      return true;
    });

    return result;
  }

  /// *** it is work else in initState, is best
  static List<ModalRoute> getAllModalRoutesByFocusScope({BuildContext? context, bool onlyActives = true}) {
    final nav = getRootNavigator();
    final res = <ModalRoute>[];

    if(nav == null) {
      return res;
    }

    //List children = nav.focusScopeNode.descendants.toList();    << exist repeat node
    //dep final List children = nav.focusScopeNode.children.toList();
    final List children = nav.focusNode.children.toList();

    for(FocusNode f in children) {
      final m = getModalRouteOf(f.context!);

      if(m == null) {
        continue;
      }

      if (onlyActives){
        if (m.isActive) {
          res.add(m);
        }
      }
      else {
        res.add(m);
      }
    }

    return res;
  }

  static List<ModalRoute> getAllModalRoutesByAncestor({BuildContext? context, bool onlyActives = true}) {
    final nav = getRootNavigator();
    final elements = <Element>[];
    final res = <ModalRoute>[];

    if(nav == null) {
      return res;
    }

    var beforeModalScopeStatus = false;

    void func(BuildContext ctx) {
      final elm = ctx as Element;

      elm.visitChildren((Element element) {
        try {
          final runType = element.widget.runtimeType.toString();

          if(runType == '_ModalScopeStatus') {// if add this: take error [Duplicate GlobalKeys]
            beforeModalScopeStatus = true;
          }
          else if(beforeModalScopeStatus && runType == 'Offstage') {
            elements.add(element);
          }
          else {
            beforeModalScopeStatus = false;
          }
        }
        catch (e){/**/}

        func(element);
      });
    }

    try {
      func(nav.context);
    }
    catch(e){
      rethrow;
    }

    for(var w in elements) {
      final m = getModalRouteOf(w);

      if(m == null) {
        continue;
      }

      if (onlyActives){
        if (m.isActive) {
          res.add(m);
        }
      }
      else {
        res.add(m);
      }
    }

    return res;
  }

  static List<ModalRoute> getAllModalRoutes({BuildContext? context, bool onlyActives = true}) {
    final nav = getRootNavigator();
    final res = <ModalRoute>[];

    if(nav == null) {
      return res;
    }

    void func(BuildContext ctx) {
      final elm = ctx as Element;

      elm.visitChildren((Element element) {
        try {
          final runType = element.widget.runtimeType.toString();

          if(runType == '_ModalScopeStatus') {// if add this: take error [Duplicate GlobalKeys]
            final dynamic d = element.widget;

            final m = d.route as ModalRoute?;

            if(m != null) {
              if (onlyActives){
                if (m.isActive) {
                  res.add(m);
                }
              }
              else {
                res.add(m);
              }
            }
          }
        }
        catch (e){
          //rint('$e');
        }

        func(element);
      });
    }

    func(nav.context);

    return res;
  }

  static ModalRoute? accessModalRouteByRouteName(BuildContext context, String name, {bool onlyActives = false}){
    final list = getAllModalRoutes(context: context, onlyActives: onlyActives);

    return findRouteByName(list, name);
  }

  static ModalRoute? findRouteByName(List<ModalRoute> list, String name) {
    ModalRoute? res;

    for(var m in list){
      if(m.settings.name == name) {
        res = m;
        break;
      }
    }

    return res;
  }

  static List<BuildContext> getAllModalRoutesContext(BuildContext context, {bool onlyActives = true}) {
    final list = getAllModalRoutes(context: context, onlyActives: onlyActives);
    final res = <BuildContext>[];

    for(var m in list){
      res.add(m.subtreeContext!);
    }

    return res;
  }

  static BuildContext findEndChildContext(BuildContext context){
    var last = context;
    var maxDepth = -1;

    void fn(Element element) {
      if(element.depth > maxDepth) {
        last = element;
        maxDepth = element.depth;
      }

      element.visitChildren(fn);
    }

    (context as Element).visitChildren(fn);

    return last;
  }

  static T? findAncestorWidgetOfExactType<T extends Widget>(BuildContext context, {bool onlyActives = true, bool onAllPages = true}){
    final list = getAllModalRoutesContext(context, onlyActives: onlyActives);
    BuildContext ctx;
    T? cas;

    if(onAllPages) {
      for (var i = list.length; i > 0; i--) {
        ctx = list[i - 1];
        ctx = findEndChildContext(ctx);
        cas = ctx.findAncestorWidgetOfExactType();

        if (cas != null) {
          break;
        }
      }
    }
    else {
      ctx = list.last;
      ctx = findEndChildContext(ctx);
      cas = ctx.findAncestorWidgetOfExactType();
    }

    return cas;
  }

  static bool popByRouteName(BuildContext context, String routeName, {dynamic result}){
    final route = accessModalRouteByRouteName(context, routeName);

    if(route == null) {
      return false;
    }

    if(route.isCurrent) {
      Navigator.of(context).pop(result);
    }
    else {
      Navigator.of(context).removeRoute(route);
    }

    return true;
  }

  static void touchAncestorsToRoot(BuildContext context, bool Function(Element elem) onParent) {
    final e = context as Element;

    e.visitAncestorElements((element) {
      return onParent(element);
      //return true;
    });
  }

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
}