import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class OrientationManager {
  OrientationManager._();

  static Orientation getCurrentOrientation(BuildContext context){
    return MediaQuery.of(context).orientation;
  }

  static bool isPortrait(BuildContext context){
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  static bool isLandscape(BuildContext context){
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  static void fixPortraitModeOnly({Function? onThen, dynamic funArg}) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]).then((_) {

      if(funArg != null)
        onThen?.call(funArg);
      else
        onThen?.call();
    });
  }

  static void fixLandscapeModeOnly({Function? onThen, dynamic funArg}) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]).then((_) {
      if(funArg != null)
        onThen?.call(funArg);
      else
        onThen?.call();
    });
  }

  static void enableFullRotation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  static void setAppRotation(Orientation? state) {
    if(state == null) {
      enableFullRotation();
      return;
    }

    //if(state.toLowerCase() == 'portrait'){
    if(state == Orientation.portrait){
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      return;
    }

    if(state == Orientation.landscape){
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);

      return;
    }

    enableFullRotation();
  }
}
//--------------------------------------------------------------------------------------------------
mixin PortraitStatelessMixin on StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if(!OrientationManager.isPortrait(context))
      OrientationManager.fixPortraitModeOnly();

    return super.build(context);
  }
}
//--------------------------------------------------------------------------------------------------
mixin PortraitStatefulMixin<T extends StatefulWidget> on State<T> {
  @override
  Widget build(BuildContext context) {
    if(!OrientationManager.isPortrait(context))
      OrientationManager.fixPortraitModeOnly();

    return super.build(context);
  }

  @override
  // ignore: must_call_super
  void dispose() {
    OrientationManager.enableFullRotation();
    super.dispose();
  }
}
//--------------------------------------------------------------------------------------------------



