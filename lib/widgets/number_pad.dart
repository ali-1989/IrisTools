import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';


typedef OnWidgetSizeChange = void Function(Size size);
///=============================================================================
class NumberPad extends StatefulWidget {
  /// Callback after all pins input
  final void Function(String pin, PinCodeState state) onConfirm;

  /// Callback onChange
  final void Function(String pin) onChangedPin;

  /// Callback onChange length
  final void Function(int length)? onChangedPinLength;

  /// Event for clear pin
  final Stream<bool>? clearSignal;

  /// Min pins to use
  final int minPinLength;

  /// Max pins to use
  final int maxPinLength;

  /// Any widgets on the empty place, usually - 'forgot?'
  final Widget? bottomWidget;

  /// numbers styling
  final TextStyle numbersStyle;
  final TextStyle keyStyle;

  /// buttons border styling
  final BorderSide borderSide;

  /// buttons color
  final Color buttonColor;

  /// filled pins color
  final Color filledIndicatorColor;

  /// delete icon label (accessibility)
  final String deleteButtonLabel;

  /// delete icon label (accessibility)
  final String enterButtonLabel;

  /// icon color
  final Color otherButtonIconColor;

  /// delete icon color
  final Color otherButtonColor;

  /// color appears when press pin button
  final Color onPressColor;

  final EdgeInsets padding;

  final bool useSplash;
  final bool showEnteredKeys;
  final bool showEnteredKeyAsStar;

  final bool showDefaultDeleteButton;
  final bool showDefaultConfirmButton;
  final Widget? deleteButton;
  final Widget? confirmButton;

  const NumberPad({
    Key? key,
    required this.onConfirm,
    this.minPinLength = 4,
    this.maxPinLength = 11,
    required this.onChangedPin,
    this.onChangedPinLength,
    this.clearSignal,
    this.bottomWidget,
    this.numbersStyle = const TextStyle(
        fontSize: 27.0, fontWeight: FontWeight.w600, color: Colors.black
    ),
    this.keyStyle = const TextStyle(
        fontSize: 14.0, color: Colors.black
    ),
    this.borderSide = const BorderSide(width: 1, color: Colors.grey),
    this.buttonColor = Colors.transparent,
    this.otherButtonColor = Colors.transparent,
    this.filledIndicatorColor = Colors.blueAccent,
    this.deleteButtonLabel = 'Delete',
    this.enterButtonLabel = 'Enter',
    this.otherButtonIconColor = Colors.black,
    this.onPressColor = Colors.blue,
    this.useSplash = true,
    this.showEnteredKeyAsStar = false,
    this.showEnteredKeys = true,
    this.showDefaultDeleteButton = true,
    this.showDefaultConfirmButton = true,
    this.deleteButton,
    this.confirmButton,
    this.padding = const EdgeInsets.only(left: 40, right: 40, bottom: 30),
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => PinCodeState();
}
///=============================================================================
class PinCodeState<T extends NumberPad> extends State<T> {
  final aspectDetectKey = GlobalKey();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController listController = ScrollController();
  late String pin;
  late double _aspectRatio;
  bool animate = false;
  late Widget deleteIconImage;
  late Widget enterIconImage;
  StreamSubscription? clearSignalListener;

  int currentPinLength() => pin.length;

  @override
  void initState() {
    super.initState();

    deleteIconImage = Icon(
      CupertinoIcons.delete_left,
      color: widget.otherButtonIconColor,
    );

    enterIconImage = Icon(
      CupertinoIcons.check_mark,
      color: widget.otherButtonIconColor,
    );

    pin = '';
    _aspectRatio = 0;

    if (widget.clearSignal != null) {
      clearSignalListener = widget.clearSignal!.listen((val) {
        if (val) {
          clear();
        }
      });
    }

    WidgetsBinding.instance.addPostFrameCallback(afterLayout);
  }

  @override
  void dispose(){
    clearSignalListener?.cancel();

    super.dispose();
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    key: scaffoldKey,
    body: buildBody(context),
    resizeToAvoidBottomInset: false,
  );

  Widget buildBody(BuildContext context) {
    return MeasureSize(
      onChange: (size) {
        calculateAspectRatio();
      },
      child: Padding(
        key: aspectDetectKey,
        padding: widget.padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Visibility(
              visible: widget.showEnteredKeys,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                child: SizedBox(
                  height: 20,
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: ListView(
                      controller: listController,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      shrinkWrap: true,
                      // physics: const NeverScrollableScrollPhysics(),
                      children: List.generate(pin.length, generateEnteredKys),
                    ),
                  ),
                ),
              ),
            ),

            //const Spacer(flex: 1),
            const SizedBox(height: 10),

            Flexible(
              flex: 7,
              child: Builder(
                  builder: (_){
                    if(_aspectRatio > 0){
                      return GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 3,
                    childAspectRatio: _aspectRatio + 0.18,
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(12,
                          (index) {
                        const double marginRight = 15;
                        const double marginLeft = 15;
                        const double marginBottom = 4;

                        if (index == 9) {
                          if(widget.deleteButton != null){
                            return widget.deleteButton!;
                          }

                          if(!widget.showDefaultDeleteButton){
                            return const SizedBox();
                          }

                          return Container(
                            margin: const EdgeInsets.only(left: marginLeft, right: marginRight),
                            child: MergeSemantics(
                              child: Semantics(
                                label: widget.deleteButtonLabel,
                                child: ElevatedButton(
                                  statesController: widget.useSplash? null: NoSplashState(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: widget.otherButtonColor,
                                    foregroundColor: widget.onPressColor,
                                    side: widget.borderSide,
                                    shadowColor: Colors.transparent,
                                    surfaceTintColor: Colors.transparent,
                                    disabledBackgroundColor: Colors.transparent,
                                    disabledForegroundColor: Colors.transparent,
                                    elevation: 0,
                                    splashFactory: NoSplash.splashFactory,
                                    shape: const CircleBorder(),
                                  ),
                                  onPressed: () => onRemove(),
                                  child: deleteIconImage,
                                ),
                              ),
                            ),
                          );
                        }

                        if (index == 11) {
                          if(widget.confirmButton != null){
                            return widget.confirmButton!;
                          }

                          if(!widget.showDefaultConfirmButton){
                            return const SizedBox();
                          }

                          return Container(
                            margin: const EdgeInsets.only(left: marginLeft, right: marginRight),
                            child: MergeSemantics(
                              child: Semantics(
                                label: widget.enterButtonLabel,
                                child: ElevatedButton(
                                  statesController: widget.useSplash? null: NoSplashState(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: widget.otherButtonColor,
                                    foregroundColor: widget.onPressColor,
                                    side: widget.borderSide,
                                    shadowColor: Colors.transparent,
                                    surfaceTintColor: Colors.transparent,
                                    disabledBackgroundColor: Colors.transparent,
                                    disabledForegroundColor: Colors.transparent,
                                    elevation: 0,
                                    splashFactory: NoSplash.splashFactory,
                                    shape: const CircleBorder(),
                                  ),
                                  onPressed: () {
                                    widget.onConfirm(pin, this);
                                    clear();
                                  },
                                  child: enterIconImage,
                                ),
                              ),
                            ),
                          );
                        }

                        if (index == 10) {
                          index = 0;
                        }
                        else {
                          index++;
                        }


                        return Padding(
                          padding: const EdgeInsets.only(left: marginLeft, right: marginRight, bottom: marginBottom),
                          child: ElevatedButton(
                            statesController: widget.useSplash? null: NoSplashState(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.buttonColor,
                              foregroundColor: widget.onPressColor,
                              shadowColor: Colors.transparent,
                              surfaceTintColor: Colors.transparent,
                              disabledBackgroundColor: Colors.transparent,
                              disabledForegroundColor: Colors.transparent,
                              side: widget.borderSide,
                              elevation: 0,
                                splashFactory: NoSplash.splashFactory,
                              shape: const CircleBorder(),
                            ),

                            onPressed: () => onNumberPressed(index),
                            child: Text('$index', style: widget.numbersStyle),
                          ),
                        );

                      },
                    ),
                  );
                    }

                    return const SizedBox();
              })
            ),

            Builder(
                builder: (_){
                  if(widget.bottomWidget != null){
                    return Flexible(
                      flex: 2,
                      child: Center(child: widget.bottomWidget!),
                    );
                  }

                  return const SizedBox();
                }
            ),
          ],
        ),
      ),
    );
  }

  void clear() {
    if (scaffoldKey.currentState?.mounted?? false) {
      setState(() => pin = '');
    }
  }

  void calculateAspectRatio() {
    final renderBox = aspectDetectKey.currentContext!.findRenderObject() as RenderBox;
    final cellWidth = renderBox.size.width / 3;
    final cellHeight = renderBox.size.height / 4;

    if (cellWidth > 0 && cellHeight > 0) {
      _aspectRatio = cellWidth / cellHeight;
    }

    setState(() {});
  }

  void popPage() {
    Navigator.of(scaffoldKey.currentContext!).pop();
  }

  void onNumberPressed(int num) async {
    if (currentPinLength() >= widget.maxPinLength) {
      await HapticFeedback.heavyImpact();
      return;
    }

    animate = false;

    pin += num.toString();
    widget.onChangedPin(pin);

    setState(() {});

    Future.delayed(const Duration(milliseconds: 60)).then((value) {
      setState(() {
        animate = true;
      });
    });

    if(widget.showEnteredKeys) {
      listController.jumpTo(listController.position.maxScrollExtent);
    }
  }

  void onRemove() {
    if (currentPinLength() == 0) {
      return;
    }

    pin = pin.substring(0, pin.length - 1);
    widget.onChangedPin(pin);
    setState((){});
  }

  void afterLayout(dynamic _) {
    calculateAspectRatio();
  }

  Widget generateEnteredKys(int index) {
    const size = 10.0;
    final key = pin[index];

    if (index == pin.length - 1) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
        child: AnimatedContainer(
          width: animate ? size : size + 10,
          height: !animate ? size : size + 10,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: widget.showEnteredKeyAsStar ?
          BoxDecoration(
            shape: BoxShape.circle,
            color: widget.filledIndicatorColor,
          )
              : null,
          child: widget.showEnteredKeyAsStar ?
            null
          : Text(key, style: widget.keyStyle),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
      child: Container(
        width: size,
        height: size,
        decoration: widget.showEnteredKeyAsStar ?
        BoxDecoration(
          shape: BoxShape.circle,
          color: widget.filledIndicatorColor,
        ) : null,
        child: widget.showEnteredKeyAsStar ?
        null
            : Text(key, style: widget.keyStyle),
      ),
    );
  }
}
///=============================================================================
class MeasureSize extends SingleChildRenderObjectWidget {
  const MeasureSize({
    Key? key,
    required this.onChange,
    required Widget child,
  }) : super(key: key, child: child);

  final OnWidgetSizeChange onChange;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _MeasureSizeRenderObject(onChange);
  }
}
///=============================================================================
class _MeasureSizeRenderObject extends RenderProxyBox {
  Size? oldSize;
  final OnWidgetSizeChange onChange;

  _MeasureSizeRenderObject(this.onChange);

  @override
  void performLayout() {
    super.performLayout();

    Size newSize = child!.size;

    if (oldSize == newSize) return;

    oldSize = newSize;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      onChange(newSize);
    });
  }
}

class NoSplashState extends MaterialStatesController {
  @override
  void update(MaterialState state, bool add) {
  }
}