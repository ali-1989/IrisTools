import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:iris_tools/api/keyboard/keyboardEvent.dart';
import 'package:iris_tools/modules/irisDialog/navHelper.dart';

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
  ShapeBorder? shape;
  EdgeInsets? padding;
  EdgeInsets titlePadding = EdgeInsets.all(10.0);
  double widthFactor = 0.8;
  double elevation = 4.0;
  double messageToButtonsSpace = 20;
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

class IrisDialog {
  IrisDialog._();

  static Future<T?> show<T>(
      BuildContext context,
      {
        Key? key,
        required String positiveButtonText,
        String? title,
        String? descriptionText,
        Widget? descriptionWidget,
        String? pageNavigatorName,
        String? negativeButtonText,
        String? threeButtonText,
        TextDirection? direction,
        Widget? icon,
        OnButtonPressed? positivePress,
        OnButtonPressed? negativePress,
        OnButtonPressed? threePress,
        bool canDismissible = false,
        bool dismissOnButtons = true,
        IrisDialogDecoration? decoration,
    })
  {
    assert(descriptionText != null || descriptionWidget != null, 'both descriptionText & descriptionWidget is null');

    decoration ??= IrisDialogDecoration();

    decoration.dimColor ??= Colors.black.withAlpha(120);
    final routeName = pageNavigatorName?? _generateId(10);

    //............................................
    final tween = Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeIn));

    animation(ctx, anim1, anim2, child) => ScaleTransition(
      child: child,
      scale: tween.animate(anim1),
    );
    //............................................
    final res = showGeneralDialog<T>(
      context: context,
      barrierColor: decoration.dimColor!,
      barrierDismissible: canDismissible,
      barrierLabel: routeName,
      routeSettings: RouteSettings(name: routeName),
      transitionDuration: decoration.animationDuration,
      transitionBuilder: decoration.transitionsBuilder?? animation,
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
/// if return true, pop
typedef OnButtonPressed = dynamic Function(BuildContext ctx);
typedef OnAnyButton = dynamic Function(dynamic result);
///=====================================================================================================
class IrisDialogWidget extends StatefulWidget {
  final IrisDialogDecoration? decoration;
  final String? title;
  final String? descriptionText;
  final Widget? descriptionWidget;
  final String positiveButtonText;
  final String? negativeButtonText;
  final String? threeButtonText;
  final TextDirection? direction;
  final Widget? icon;
  final OnButtonPressed? positivePress;
  final OnButtonPressed? negativePress;
  final OnButtonPressed? threePress;
  final OnAnyButton? anyButtonPress;
  final bool canDismissible;
  //final Lottie lottieAnimation;

  IrisDialogWidget({
    Key? key,
    this.decoration,
    this.title,
    this.descriptionText,
    this.descriptionWidget,
    required this.positiveButtonText,
    this.negativeButtonText,
    this.threeButtonText,
    this.direction,
    this.icon,
    this.positivePress,
    this.negativePress,
    this.threePress,
    this.anyButtonPress,
    this.canDismissible = true,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _IrisDialogWidgetState();
  }
}
///=====================================================================================================
class _IrisDialogWidgetState extends State<IrisDialogWidget> {
  late IrisDialogDecoration decoration;
  late Widget descriptionView;
  TextDirection? direction;
  //main padding, if not set is: EdgeInsets.fromLTRB(25.0, 7.0, 25.0, 5.0)
  EdgeInsets padding = EdgeInsets.zero;

  @override
  void initState() {
    super.initState();

    decoration = widget.decoration?? IrisDialogDecoration();
  }

  @override
  Widget build(BuildContext context) {
    _prepare();
    descriptionView = widget.descriptionWidget?? Text(widget.descriptionText!, style: decoration.descriptionStyle,);

    return WillPopScope(
      onWillPop: widget.canDismissible? null : willPopFn,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          FractionallySizedBox( //or IntrinsicWidth
            widthFactor: decoration.widthFactor,
            child: Card(
              color: decoration.backgroundColor,
              clipBehavior: Clip.antiAlias,
              shadowColor: decoration.shadowColor,
              elevation: decoration.elevation,
              shape: decoration.shape,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if(widget.icon != null)
                    Card(
                      elevation: 0,
                      borderOnForeground: false,
                      shape: Border.symmetric(),
                      margin: EdgeInsets.zero,
                      color: decoration.iconBackgroundColor?? Colors.blueGrey,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 16),
                          child: widget.icon,
                        ),
                      ),
                    ),

                  if(widget.title != null)
                    ColoredBox(
                      color: decoration.titleBackgroundColor?? Colors.transparent,
                      child: SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: decoration.titlePadding,
                          child: Center(
                            child: Text(widget.title!, style: decoration.titleStyle,),
                          ),
                        ),
                      ),
                    ),

                  Padding(
                    padding: padding,
                    child: Directionality(
                      textDirection: direction!,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        textDirection: direction,
                        children: <Widget>[
                          descriptionView,
                          SizedBox(height: decoration.messageToButtonsSpace,),

                          ButtonBar(
                            children: [
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(decoration.positiveButtonBackColor),
                                ),
                                child: Text(widget.positiveButtonText, style: decoration.positiveStyle,),
                                onPressed: (){
                                  //var close = widget.positivePress?.call(context)?? true;
                                  final res = widget.positivePress?.call(context);

                                  if(res is Future){
                                    res.then((value) {
                                      widget.anyButtonPress?.call(value);
                                    });
                                  }
                                  else {
                                    widget.anyButtonPress?.call(res);
                                  }
                                },
                              ),

                              if(widget.negativeButtonText != null)
                                ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(decoration.negativeButtonBackColor),
                                  ),
                                  child: Text(widget.negativeButtonText!, style: decoration.negativeStyle,),
                                  onPressed: (){
                                    final res = widget.negativePress?.call(context);

                                    if(res is Future){
                                      res.then((value) {
                                        widget.anyButtonPress?.call(value);
                                      });
                                    }
                                    else {
                                      widget.anyButtonPress?.call(res);
                                    }
                                    },
                              ),

                              if(widget.threeButtonText != null)
                                ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(decoration.negativeButtonBackColor),
                                  ),
                                  child: Text(widget.threeButtonText!, style: decoration.negativeStyle,),
                                  onPressed: () {
                                    final res = widget.threePress?.call(context);

                                    if(res is Future){
                                      res.then((value) {
                                        widget.anyButtonPress?.call(value);
                                      });
                                    }
                                    else {
                                      widget.anyButtonPress?.call(res);
                                    }
                                  },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _prepare(){
    decoration.themeData ??= Theme.of(context);
    decoration.backgroundColor ??= decoration.themeData!.dialogBackgroundColor;
    decoration.titleColor ??= decoration.themeData!.dialogTheme.titleTextStyle!.color;
    decoration.descriptionColor ??= decoration.themeData!.dialogTheme.contentTextStyle!.color;
    //positiveButtonTextColor = widget.positiveButtonTextColor?? themeData.buttonTheme.colorScheme.primary;
    decoration.positiveButtonBackColor ??= decoration.themeData!.elevatedButtonTheme.style!.backgroundColor!.resolve({MaterialState.focused});
    //negativeButtonTextColor = widget.negativeButtonTextColor?? themeData.buttonTheme.colorScheme.primary;
    decoration.negativeButtonBackColor ??= decoration.themeData!.buttonTheme.colorScheme!.background;
    decoration.shadowColor ??= decoration.themeData!.shadowColor;
    decoration.titleStyle ??= decoration.themeData!.dialogTheme.titleTextStyle;
    decoration.descriptionStyle ??= decoration.themeData!.dialogTheme.contentTextStyle?.copyWith(
      fontWeight: FontWeight.w600,
    );
    decoration.positiveStyle ??= decoration.themeData!.textTheme.button;
    decoration.negativeStyle ??= decoration.positiveStyle;
    decoration.shape ??= decoration.themeData!.dialogTheme.shape;

    direction = widget.direction?? Directionality.of(context);
    padding = EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 10.0);

    if(decoration.titleColor != null) {
      decoration.titleStyle = decoration.titleStyle!.copyWith(color: decoration.titleColor);
    }

    if(decoration.descriptionColor != null) {
      decoration.descriptionStyle = decoration.descriptionStyle!.copyWith(color: decoration.descriptionColor);
    }

    if(decoration.positiveButtonTextColor != null) {
      decoration.positiveStyle = decoration.positiveStyle!.copyWith(color: decoration.positiveButtonTextColor);
    }

    if(decoration.negativeButtonTextColor != null) {
      decoration.negativeStyle = decoration.negativeStyle!.copyWith(color: decoration.negativeButtonTextColor);
    }
  }

  Future<bool> willPopFn(){
    if(widget.canDismissible) {
      return Future.value(true);
    }

    return Future.value(false);
  }
}