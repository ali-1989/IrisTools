import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:iris_tools/api/keyboard/keyboardEvent.dart';
import 'package:iris_tools/modules/irisDialog/irisDialogWidget.dart';
import 'package:iris_tools/modules/irisDialog/navHelper.dart';

/// if return true, pop
typedef OnButtonCallback = FutureOr<bool>? Function(BuildContext ctx);
typedef OnAnyButtonCallback = dynamic Function(dynamic result);
///=====================================================================================================
class IrisDialogDecoration {
  ThemeData? themeData;
  Color? dimColor;
  Color? backgroundColor;
  Color? titleColor;
  Color? descriptionColor;
  Color? positiveButtonTextColor;
  Color? positiveButtonBackColor;
  Color? negativeButtonTextColor;
  Color? negativeButtonBackColor;
  Color? iconBackgroundColor;
  Color? titleBackgroundColor;
  Color? shadowColor;
  TextStyle? titleStyle;
  TextStyle? descriptionStyle;
  TextStyle? positiveStyle;
  TextStyle? negativeStyle;
  MainAxisSize? buttonsAxisSize;
  MainAxisAlignment? buttonsAxisAlignment;
  ShapeBorder? shape;
  EdgeInsets? padding;
  EdgeInsets titlePadding = EdgeInsets.all(10.0);
  double widthFactor = 0.8;
  double elevation = 4.0;
  double messageToButtonsSpace = 20;
  double buttonsSpace = 30;
  RouteTransitionsBuilder? transitionsBuilder;
  Duration animationDuration = Duration(milliseconds: 300);

  IrisDialogDecoration copy(){
    final res = IrisDialogDecoration();
    res.themeData = themeData;
    res.dimColor = dimColor;
    res.backgroundColor = backgroundColor;
    res.titleColor = titleColor;
    res.descriptionColor = descriptionColor;
    res.positiveButtonTextColor = positiveButtonTextColor;
    res.positiveButtonBackColor = positiveButtonBackColor;
    res.negativeButtonBackColor = negativeButtonBackColor;
    res.negativeButtonTextColor = negativeButtonTextColor;
    res.iconBackgroundColor = iconBackgroundColor;
    res.titleBackgroundColor = titleBackgroundColor;
    res.shadowColor = shadowColor;
    res.titleStyle = titleStyle;
    res.descriptionStyle = descriptionStyle;
    res.positiveStyle = positiveStyle;
    res.negativeStyle = negativeStyle;
    res.shape = shape;
    res.padding = padding;
    res.titlePadding = titlePadding;
    res.widthFactor = widthFactor;
    res.elevation = elevation;
    res.messageToButtonsSpace = messageToButtonsSpace;
    res.transitionsBuilder = transitionsBuilder;
    res.animationDuration = animationDuration;

    return res;
  }
}
///===============================================================================================
class IrisDialog {
  IrisDialog._();

  static Future<T?> show<T>(
      BuildContext context, {
        Key? key,
        String? title,
        String? descriptionText,
        Widget? descriptionWidget,
        String? pageRouteName,
        String? positiveButtonText,
        String? negativeButtonText,
        String? threeButtonText,
        TextDirection? direction,
        Widget? icon,
        OnButtonCallback? positivePress,
        OnButtonCallback? negativePress,
        OnButtonCallback? threePress,
        bool canDismissible = false,
        bool dismissOnButtons = true,
        IrisDialogDecoration? decoration,
    })
  {
    assert(descriptionText != null || descriptionWidget != null, 'both descriptionText & descriptionWidget is null');

    decoration ??= IrisDialogDecoration();
    decoration.dimColor ??= Colors.black.withAlpha(120);
    final routeName = pageRouteName?? _generateId(10);
    //............................................
    final tween = Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeIn));

    AnimatedWidget buildAnimation(ctx, anim1, anim2, child) => ScaleTransition(
      child: child,
      scale: tween.animate(anim1),
    );
    ///.......... show ..................................
    final res = showGeneralDialog<T>(
      context: context,
      barrierColor: decoration.dimColor!,
      barrierDismissible: canDismissible,
      barrierLabel: routeName,
      routeSettings: RouteSettings(name: routeName),
      transitionDuration: decoration.animationDuration,
      transitionBuilder: decoration.transitionsBuilder?? buildAnimation,
      pageBuilder: (ctx, anim1, anim2){
        void onAnyBtn(res){
          if(dismissOnButtons) {
            IrisDialogNav.popByRouteName(context, routeName, result: res);
          }
        }

        return KeyboardStateListener(
          builder: (context, child, isKeyboardOpen) {
            final mq = MediaQuery.of(context);

            return UnconstrainedBox(
              alignment: Alignment.topCenter,
              child: SizedBox(
                height: mq.size.height - mq.viewInsets.bottom,
                width: mq.size.width,
                child: Center(
                  child: SingleChildScrollView(
                    child: IrisDialogWidget(
                      key: key,
                      decoration: decoration,
                      canDismissible: canDismissible,
                      icon: icon,
                      descriptionText: descriptionText,
                      descriptionWidget: descriptionWidget,
                      direction: direction,
                      negativeButtonText: negativeButtonText,
                      negativePress: negativePress,
                      positiveButtonText: positiveButtonText,
                      positivePress: positivePress,
                      threeButtonText: threeButtonText,
                      threePress: threePress,
                      anyButtonPress: onAnyBtn,
                      title: title,
                    ),
                  ),
                ),
              ),
            );
          }
        );
      },
    );

    return res;
  }

  static String _generateId(int max){
    final s = 'abcdefghijklmnopqrstwxyz0123456789ABCEFGHIJKLMNOPQRSTUWXYZ';
    var res = '';
    final r = Random();

    for(var i=0; i<max; i++) {
      final j = r.nextInt(s.length);
      res += s[j];
    }

    return res;
  }
}
///=====================================================================================================
