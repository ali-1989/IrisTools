import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:iris_tools/widgets/panel/panelController.dart';

// src: https://pub.dev/packages/we_slide

class Panel extends StatefulWidget {
  final Widget? footer;
  final Widget? header;
  final Widget body;
  final Widget panel;
  final double panelMinSize;
  final double panelMaxSize;
  final double panelBorderRadiusBegin;
  final double panelBorderRadiusEnd;
  final double bodyBorderRadiusBegin;
  final double bodyBorderRadiusEnd;
  final double parallaxOffset;
  final double footerHeight;
  final double overlayOpacity;
  final double blurSigma;
  final double transformScaleBegin;
  final double transformScaleEnd;
  final Color overlayColor;
  final Color blurColor;
  final Color backgroundColor;
  final bool hideFooter;
  final bool hideHeader;
  final bool parallax;
  final bool transformScale;
  final bool overlay;
  final bool blur;
  final List<TweenSequenceItem<double>> fadeSequence;
  final Duration animateDuration;
  final PanelController? controller;
  final Function? onOpening;
  final Function? onClosed;

  Panel({
    Key? key,
    required this.body,
    required this.panel,
    this.header,
    this.footer,
    this.panelMinSize = 0.0,
    this.panelMaxSize = 300.0,
    this.panelBorderRadiusBegin = 0.0,
    this.panelBorderRadiusEnd = 0.0,
    this.bodyBorderRadiusBegin = 0.0,
    this.bodyBorderRadiusEnd = 0.0,
    this.transformScaleBegin = 1.0,
    this.transformScaleEnd = 0.85,
    this.parallaxOffset = 0.1,
    this.overlayOpacity = 0.0,
    this.blurSigma = 5.0,
    this.overlayColor = Colors.black,
    this.blurColor = Colors.black,
    this.backgroundColor = Colors.black,
    this.footerHeight = 60.0,
    this.hideFooter = true,
    this.hideHeader = true,
    this.parallax = false,
    this.transformScale = false,
    this.overlay = false,
    this.blur = false,
    this.onOpening,
    this.onClosed,
    List<TweenSequenceItem<double>>? fadeSequence,
    this.animateDuration = const Duration(milliseconds: 300),
    this.controller,
  })  :
        assert(panelMinSize >= 0.0, 'panelMinSize cannot be negative'),
        assert(footerHeight >= 0.0, 'footerHeight cannot be negative'),
        assert(panelMaxSize >= panelMinSize, 'panelMaxSize cannot be less than panelMinSize'),
        fadeSequence = fadeSequence ??
            [
              TweenSequenceItem<double>(weight: 1.0, tween: Tween(begin: 1, end: 0)),
              TweenSequenceItem<double>(weight: 8.0, tween: Tween(begin: 0, end: 0)),
            ],
        super(key: key) ;

  @override
  _PanelState createState() => _PanelState();
}
///=============================================================================================
class _PanelState extends State<Panel> with SingleTickerProviderStateMixin {
  late AnimationController _animCtr;
  late Animation<double> _panelBorderRadius;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late PanelController _controller;

  bool get _isPanelVisible =>
      _animCtr.status == AnimationStatus.completed || _animCtr.status == AnimationStatus.forward;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller?? PanelController();
    _controller.addListener(_animatedPanel);

    _animCtr = AnimationController(vsync: this, duration: widget.animateDuration);

    _panelBorderRadius = Tween<double>(
        begin: widget.panelBorderRadiusBegin, end: widget.panelBorderRadiusEnd)
        .animate(_animCtr);

    _scaleAnimation = Tween<double>(
        begin: widget.transformScaleBegin, end: widget.transformScaleEnd)
        .animate(_animCtr);

    _fadeAnimation = TweenSequence(widget.fadeSequence).animate(_animCtr);
  }

  @override
  void didUpdateWidget(Panel oldWidget) {
    super.didUpdateWidget(oldWidget);
    //oldWidget.controller?.removeListener(_animatedPanel);
    //widget.controller?.addListener(_animatedPanel);
    if(widget.controller != null && !identical(_controller, widget.controller)) {
      _controller.removeListener(_animatedPanel);
      _controller = widget.controller!;
      _controller.addListener(_animatedPanel);
    }
  }

  void _animatedPanel() {
    if(_controller.value) {
      widget.onOpening?.call();
    }

    if (_controller.value != _isPanelVisible) {
      _animCtr.fling(velocity: _isPanelVisible ? -2.0 : 2.0);
    }

    if(!_controller.value) {
      widget.onClosed?.call();
    }
  }

  @override
  void dispose() {
    _animCtr.dispose();
    // take error _controller.dispose();

    super.dispose();
  }

  void _handleVerticalUpdate(DragUpdateDetails updateDetails) {
    var delta = updateDetails.primaryDelta!;
    var fractionDragged = delta / widget.panelMaxSize;
    _animCtr.value -= 1.5 * fractionDragged;
  }

  void _handleVerticalEnd(DragEndDetails endDetails) {
    var velocity = endDetails.primaryVelocity!;

    if (velocity > 0.0) {
      _animCtr.reverse().then((x) {
        _controller.value = false;
      });
    } else if (velocity < 0.0) {
      _animCtr.forward().then((x) {
        _controller.value = true;
      });
    } else if (_animCtr.value >= 0.5 && endDetails.primaryVelocity == 0.0) {
      _animCtr.forward().then((x) {
        _controller.value = true;
      });
    } else {
      _animCtr.reverse().then((x) {
        _controller.value = false;
      });
    }
  }

  Animation<Offset> _getAnimationOffSet({required double minSize, required double maxSize}) {
    final _closedPercentage = (widget.panelMaxSize - minSize) / widget.panelMaxSize;
    final _openPercentage = (widget.panelMaxSize - maxSize) / widget.panelMaxSize;

    return Tween<Offset>(
        begin: Offset(0.0, _closedPercentage), end: Offset(0.0, _openPercentage))
        .animate(_animCtr);
  }

  /*double _getPanelSize() {
    var _size = 0.0;

    if (!widget.hideFooter && widget.footer != null) {
      _size += widget.footerHeight;
    }

    return _size;
  }*/

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;

    return ColoredBox(
      color: widget.backgroundColor,
      child: Stack(
        clipBehavior: Clip.antiAlias,
        fit: StackFit.expand,
        alignment: Alignment.bottomCenter,
        children: <Widget>[

          /** Body widget **/
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animCtr,
              builder: (context, child) {
                return Transform.scale(
                  scale: widget.transformScale ? _scaleAnimation.value : 1.0,
                  alignment: Alignment.bottomCenter,
                  child: widget.body
                );
              },
            ),
          ),


          /** Enable Blur Effect **/
          if (widget.blur && !widget.overlay)
            AnimatedBuilder(
              animation: _animCtr,
              builder: (context, _) {
                return BackdropFilter(
                  filter: ImageFilter.blur(
                      sigmaX: widget.blurSigma * _animCtr.value,
                      sigmaY: widget.blurSigma * _animCtr.value),
                  child: ColoredBox(
                    color: widget.blurColor.withOpacity(0.1),
                  ),
                );
              },
            ),



          /** Enable Overlay Effect **/
          if (!widget.blur && widget.overlay)
            AnimatedBuilder(
              animation: _animCtr,
              builder: (context, _) {
                return ColoredBox(
                  color: _animCtr.value == 0.0
                      ? Colors.transparent
                      : widget.overlayColor.withOpacity(widget.overlayOpacity * _animCtr.value),
                );
              },
            ),


          /** Panel widget **/
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _animCtr,
              builder: (ctx, child) {
                return SlideTransition(
                  position: _getAnimationOffSet(maxSize: widget.panelMaxSize, minSize: widget.panelMinSize),
                  child: GestureDetector(
                    onVerticalDragUpdate: _handleVerticalUpdate,
                    onVerticalDragEnd: _handleVerticalEnd,
                    child: AnimatedContainer(
                      height: widget.panelMaxSize,
                      width: _width,
                      duration: Duration(milliseconds: 200),
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(_panelBorderRadius.value),
                          topRight: Radius.circular(_panelBorderRadius.value),
                        ),
                        child: child,
                      ),
                    ),
                  ),
                );
              },
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        widget.panel,

                        if(widget.footer != null && !widget.hideFooter)
                          SizedBox(height: widget.footerHeight,),
                      ],
                    ),
                  ),


                  if(widget.header != null && widget.hideHeader)
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: ValueListenableBuilder(
                          valueListenable: _controller,
                          builder: (ctx, __, ___) {
                            return IgnorePointer(
                              ignoring: _controller.value && widget.hideHeader,
                              child: widget.header,
                            );
                          },
                        ),
                      ),


                  if(widget.header != null && !widget.hideHeader)
                      widget.header!,
                ],
              ),
            ),
          ),

          /** Footer **/
          if(widget.footer != null)
               AnimatedBuilder(
                animation: _animCtr,
                builder: (context, child) {
                  return Positioned(
                    height: widget.footerHeight,
                    bottom: widget.hideFooter ? _animCtr.value * -widget.footerHeight : 0.0,
                    width: _width,
                    child: widget.footer!,
                  );
                },
              ),

        ],
      ),
    );
  }
}