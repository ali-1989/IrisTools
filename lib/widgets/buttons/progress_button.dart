import 'package:flutter/material.dart';

/// src: https://github.com/jiangyang5157/flutter_progress_button/blob/master/lib/src/widgets/progress_button.dart

enum ProgressState {
  Idle,
  Preparing,
  Processing,
  Success,
  Fail,
}
///============================================================================================================
enum ProgressButtonType {
  Elevated,
  Text,
  Outline,
  none,
}
///============================================================================================================
typedef OnPressed = void Function(BuildContext ctx, ProgressButtonController controller);
typedef OnBuild = Widget? Function(BuildContext ctx, ProgressButtonController controller);
///============================================================================================================
class ProgressButton extends StatefulWidget {
  final Widget defaultWidget;
  final OnPressed onPressed;
  final OnBuild onBuild;
  final ProgressButtonController? progressButtonController;
  final ProgressButtonType type;
  final Color color;
  final double borderRadius;

  ProgressButton({
    Key? key,
    this.progressButtonController,
    required this.onBuild,
    required this.defaultWidget,
    required this.onPressed,
    this.type = ProgressButtonType.none,
    required this.color,
    this.borderRadius = 2.0,
  }) : super(key: key);
  //old: }) : progressButtonController = buttonController?? ProgressButtonController(), super(key: key);

  @override
  _ProgressButtonState createState() {
    return _ProgressButtonState();
  }
}
///============================================================================================================
class _ProgressButtonState extends State<ProgressButton> with TickerProviderStateMixin {
  late ProgressButtonController _controller;
  //Animation _anim;
  AnimationController? _animController;
  final Duration _duration = const Duration(milliseconds: 250);
  late double _borderRadius;
  bool animate = false;

  @override
  void initState() {
    super.initState();

    _controller = widget.progressButtonController?? ProgressButtonController();
    _controller._progressButtonState = this;
    _borderRadius = widget.borderRadius;
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void didUpdateWidget(ProgressButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if(oldWidget.progressButtonController != _controller){
      oldWidget.progressButtonController?.dispose();
    }
    //_controller = oldWidget.progressButtonController;
    //_controller._progressButtonState = this;
  }

  @override
  Widget build(BuildContext context) {
    return PhysicalModel(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(_borderRadius),
      child: _buildChild(context),
    );
  }

  @override
  dispose() {
    _animController?.dispose();
    super.dispose();
  }

  Widget _buildChild(BuildContext context) {
    var padding = const EdgeInsets.all(0.0);
    var btnBackColor = widget.color;
    var shape = RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_borderRadius)
    );

    switch (widget.type) {
      case ProgressButtonType.Elevated:
        return ElevatedButton(
          style: ButtonStyle(
            padding: MaterialStateProperty.all(padding),
            shape: MaterialStateProperty.all(shape),
            backgroundColor: MaterialStateProperty.all(btnBackColor),
          ),
          child: _buildChildren(context),
          onPressed: _getButtonPressed(),
        );
      case ProgressButtonType.Text:
        return TextButton(
          style: ButtonStyle(
            padding: MaterialStateProperty.all(padding),
            shape: MaterialStateProperty.all(shape),
            backgroundColor: MaterialStateProperty.all(btnBackColor),
          ),
          child: _buildChildren(context),
          onPressed: _getButtonPressed(),
        );
      case ProgressButtonType.Outline:
        return OutlinedButton(
          style: ButtonStyle(
            padding: MaterialStateProperty.all(padding),
            shape: MaterialStateProperty.all(shape),
            backgroundColor: MaterialStateProperty.all(btnBackColor),
          ),
          child: _buildChildren(context),
          onPressed: _getButtonPressed(),
        );
      case ProgressButtonType.none:
        return GestureDetector(
          child: _buildChildren(context),
          onTap: _getButtonPressed(),
        );
      default:
        return SizedBox();
    }
  }

  Widget _buildChildren(BuildContext context) {
    Widget? ret = widget.onBuild(context, _controller);
    ret ??= widget.defaultWidget;

    if(!animate || ret == widget) {
      return ret;
    }

    return AnimatedCrossFade(
      duration: _duration,
      crossFadeState: CrossFadeState.showSecond,
      alignment: Alignment.center,
      firstChild: widget,
      secondChild: ret,
    );
  }

  /*void _runAnimation() {
    if (animate) {
      double initialWidth = context.size.width; //_globalKey.currentContext.size.width;
      double initialBorderRadius = widget.borderRadius;
      double targetWidth = _height;
      double targetBorderRadius = _height / 2;

      _animController = AnimationController(duration: _duration, vsync: this);
      _anim = Tween(begin: 0.0, end: 1.0).animate(_animController)
        ..addListener(() {
          setState(() {
            _width = initialWidth - ((initialWidth - targetWidth) * _anim.value);
            _borderRadius = initialBorderRadius - ((initialBorderRadius - targetBorderRadius) * _anim.value);
          });
        });

      _animController.forward();
    }
  }*/

  VoidCallback _getButtonPressed() {
    return () async {
      widget.onPressed(context, _controller);
      };
  }

  void _update() {
    if (mounted) {
      setState(() {});
    }
  }
}
///=======================================================================================================
class ProgressButtonController {
  late ProgressState _buttonState;
  late _ProgressButtonState? _progressButtonState;
  bool _isInChangeProcess = false;

  ProgressButtonController(){
    _buttonState = ProgressState.Idle;
  }

  void update({bool animate = false}) {
    if(_isInChangeProcess) {
      return;
    }

    _isInChangeProcess = true;
    _progressButtonState?.animate = animate;
    _progressButtonState?._update();
    _isInChangeProcess = false;
  }

  void changeStateAndUpdate(ProgressState state, {bool animate = false}) {
    changeState(state);
    update(animate: animate);
  }

  void changeState(ProgressState state){
    _buttonState = state;
  }

  ProgressState get state => _buttonState;

  bool get isStartProcessing => _buttonState == ProgressState.Preparing || _buttonState == ProgressState.Processing;
  bool get isPreparing => _buttonState == ProgressState.Preparing;
  bool get isProcessing => _buttonState == ProgressState.Processing;
  bool get isFailed => _buttonState == ProgressState.Fail;

  void dispose(){
    _progressButtonState = null;
  }
}