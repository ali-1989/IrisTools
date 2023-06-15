import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iris_tools/modules/irisDialog/irisDialog.dart';


class IrisDialogWidget extends StatefulWidget {
  final IrisDialogDecoration? decoration;
  final String? title;
  final String? descriptionText;
  final Widget? descriptionWidget;
  final String? positiveButtonText;
  final String? negativeButtonText;
  final String? threeButtonText;
  final TextDirection? direction;
  final Widget? icon;
  final OnButtonCallback? positivePress;
  final OnButtonCallback? negativePress;
  final OnButtonCallback? threePress;
  final OnAnyButtonCallback? anyButtonPress;
  final bool canDismissible;

  IrisDialogWidget({
    Key? key,
    this.decoration,
    this.title,
    this.descriptionText,
    this.descriptionWidget,
    this.positiveButtonText,
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
  late EdgeInsets padding;

  @override
  void initState() {
    super.initState();

    decoration = widget.decoration?? IrisDialogDecoration();
    padding = decoration.padding?? EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 10.0);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _prepare();
    descriptionView = widget.descriptionWidget?? Text(widget.descriptionText!, style: decoration.descriptionStyle);

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

                          Builder(
                            builder: (_) {
                              if(_hasButtons()) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(height: decoration.messageToButtonsSpace),

                                    ButtonBar(
                                      alignment: decoration.buttonsAxisAlignment,
                                      mainAxisSize: decoration.buttonsAxisSize,
                                      children: [
                                        if(widget.positiveButtonText != null)
                                          ElevatedButton(
                                            style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all(decoration.positiveButtonBackColor),
                                            ),
                                            child: Text(widget.positiveButtonText!, style: decoration.positiveStyle,),
                                            onPressed: () {
                                              final res = widget.positivePress?.call(context);

                                              if (res is Future) {
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
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(width: widget.decoration?.buttonsSpace?? 0),

                                              ElevatedButton(
                                                style: ButtonStyle(
                                                  backgroundColor: MaterialStateProperty.all(decoration.negativeButtonBackColor),
                                                ),
                                                child: Text(widget.negativeButtonText!, style: decoration.negativeStyle,),
                                                onPressed: () {
                                                  final res = widget.negativePress?.call(context);

                                                  if (res is Future) {
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

                                        if(widget.threeButtonText != null)
                                          ElevatedButton(
                                            style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all(decoration.negativeButtonBackColor),
                                            ),
                                            child: Text(widget.threeButtonText!, style: decoration.negativeStyle,),
                                            onPressed: () {
                                              final res = widget.threePress?.call(context);

                                              if (res is Future) {
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
                                );
                              }

                              return SizedBox();
                            }
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

  bool _hasButtons(){
    return widget.positiveButtonText != null
        || widget.negativeButtonText != null
        || widget.threeButtonText != null;
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
    decoration.positiveStyle ??= decoration.themeData!.textTheme.labelLarge;
    decoration.negativeStyle ??= decoration.positiveStyle;
    decoration.shape ??= decoration.themeData!.dialogTheme.shape;

    direction = widget.direction?? Directionality.of(context);

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