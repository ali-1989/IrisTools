import 'package:flutter/material.dart';

class GlowAnimation extends StatefulWidget {
  final Widget child;
  final double endRadius;
  final BoxShape shape;
  final Duration duration;
  final bool repeat;
  final bool animate;
  final Duration repeatPauseDuration;
  final Curve curve;
  final bool showTwoGlows;
  final Color glowColor;
  final Duration? startDelay;

  const GlowAnimation({
    Key? key,
    required this.child,
    required this.endRadius,
    this.shape = BoxShape.circle,
    this.duration = const Duration(milliseconds: 2000),
    this.showTwoGlows = true,
    this.repeat = true,
    this.animate = true,
    this.repeatPauseDuration = const Duration(milliseconds: 300),
    this.curve = Curves.fastOutSlowIn,
    this.glowColor = Colors.lightBlue,
    this.startDelay,
  }) : super(key: key);

  @override
  State createState() => GlowAnimationState();
}
///======================================================================================
class GlowAnimationState extends State<GlowAnimation> with SingleTickerProviderStateMixin {
  double w = 0;
  double h = 0;

  late final _controller = AnimationController(
    duration: widget.duration,
    vsync: this,
  );

  late final _curve = CurvedAnimation(
    parent: _controller,
    curve: widget.curve,
  );

  late Animation _smallAnimationW = Tween(
    begin: 0.0,
    end: 0.0,
  ).animate(_curve);

  late Animation _smallAnimationH = Tween(
    begin: 0.0,
    end: 0.0,
  ).animate(_curve);
  late Animation _bigAnimationW = Tween(
    begin: 0.0,
    end: 0.0,
  ).animate(_curve);
  late Animation _bigAnimationH = Tween(
    begin: 0.0,
    end: 0.0,
  ).animate(_curve);

  late final _alphaAnimation = Tween(
    begin: 0.60,
    end: 0.0,
  ).animate(_controller);

  Future<void> _statusListener(AnimationStatus status) async {
    if (_controller.status == AnimationStatus.completed) {
      await Future.delayed(widget.repeatPauseDuration);

      if (mounted && widget.repeat && widget.animate) {
        _controller.reset();
        _controller.forward();
      }
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      if(mounted){
        final render = context.findRenderObject()! as RenderBox;

        w = render.size.width + widget.endRadius;
        h = render.size.height + widget.endRadius;

        if (widget.animate) {
          _startAnimation();
        }
      }
    });
  }

  @override
  void didUpdateWidget(GlowAnimation oldWidget) {
    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
        _startAnimation();
      }
      else {
        _stopAnimation();
      }
    }

    super.didUpdateWidget(oldWidget);
  }

  Future<void> _startAnimation() async {
    _controller.addStatusListener(_statusListener);

    if (widget.startDelay != null) {
      await Future.delayed(widget.startDelay!);
    }

    _smallAnimationW = Tween(
      /*begin: (widget.endRadius * 2) / 7,
      end: (widget.endRadius * 2) * (3 / 4),*/
      begin: w / 7,
      end: w * (3 / 4),
    ).animate(_curve);

    _smallAnimationH = Tween(
      begin: h / 7,
      end: h * (3 / 4),
    ).animate(_curve);

    _bigAnimationW = Tween(
      begin: 0.0,
      end: w,
      //end: widget.endRadius * 2,
    ).animate(_curve);

    _bigAnimationH = Tween(
      begin: 0.0,
      end: h,
    ).animate(_curve);

    if (mounted) {
      _controller.reset();
      _controller.forward();
    }
  }

  Future<void> _stopAnimation() async {
    _controller.removeStatusListener(_statusListener);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _alphaAnimation,
      child: widget.child,
      builder: (ctx, widgetChild) {

        final decoration = BoxDecoration(
          shape: widget.shape,
          // If the user picks a curve that goes below 0 or above 1
          // this opacity will have unexpected effects without clamping
          color: widget.glowColor.withOpacity(
            _alphaAnimation.value.clamp(0.0, 1.0),
          ),
        );

        return SizedBox(
          height: h > 0? h:null,
          width: w > 0? w:null,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Visibility(
                visible: widget.animate,
                child: AnimatedBuilder(
                  animation: _bigAnimationW,
                  builder: (_, __) {
                    final _w = _bigAnimationW.value.clamp(0.0, double.infinity);
                    final _h = _bigAnimationH.value.clamp(0.0, double.infinity);

                    return Container(
                      width: _w,
                      height: _h,
                      decoration: decoration,
                    );
                  },
                ),
              ),

              Visibility(
                visible: widget.animate && widget.showTwoGlows,
                child: AnimatedBuilder(
                  animation: _smallAnimationW,
                  builder: (_, __) {
                    final _w = _smallAnimationW.value.clamp(0.0, double.infinity);
                    final _h = _smallAnimationH.value.clamp(0.0, double.infinity);

                    return Container(
                      width: _w,
                      height: _h,
                      decoration: decoration,
                    );
                  },
                ),
              ),

              widgetChild!,
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}