//library bouncing_widget;
import 'package:flutter/material.dart';

class Bouncing extends StatefulWidget {
	final VoidCallback? onPressed;
	final Widget child;
	final double scaleFactor;
	final Duration duration;

	const Bouncing({
		Key? key,
		required this.child,
		this.onPressed,
		this.scaleFactor = 1,
		this.duration = const Duration(milliseconds: 200),
	}) : super(key: key);

	@override
	_BouncingState createState() =>  _BouncingState();
}
///========================================================================================
class _BouncingState extends State<Bouncing> with SingleTickerProviderStateMixin {
	final GlobalKey _childKey = GlobalKey();
	late AnimationController _controller;
	late double _scale;
	bool _isOutside = false;

	Widget get child => widget.child;
	VoidCallback? get onPressed => widget.onPressed;
	double get scaleFactor => widget.scaleFactor;
	Duration get duration => widget.duration;

	@override
	void initState() {
		_controller = AnimationController(
			vsync: this,
			duration: duration,
			lowerBound: 0.0,
			upperBound: 0.1,)
			..addListener(() {
			setState(() {});
		});

		super.initState();
	}

	@override
	void dispose() {
		_controller.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		_scale = 1 - (_controller.value * scaleFactor);

		return GestureDetector(
			onTapDown: _onTapDown,
			onTapUp: _onTapUp,
			onLongPressEnd: (details) => _onLongPressEnd(details, context),
			onHorizontalDragEnd: _onDragEnd,
			onVerticalDragEnd: _onDragEnd,
			onHorizontalDragUpdate: (details) => _onDragUpdate(details, context),
			onVerticalDragUpdate: (details) => _onDragUpdate(details, context),

			child: Transform.scale(
				key: _childKey,
				scale: _scale,
				child: child,
			),
		);
	}

	_triggerOnPressed() {
		if (onPressed != null) {
			onPressed!.call();
		}
	}

	_onTapDown(TapDownDetails details) {
		_controller.forward();
	}

	_onTapUp(TapUpDetails details) {
		Future.delayed(duration, () => _controller.reverse());
		Future.delayed(duration, () => _triggerOnPressed());
	}

	_onDragUpdate(DragUpdateDetails details, BuildContext context) {
		final Offset touchPosition = details.globalPosition;
		_isOutside = _isOutsideChildBox(touchPosition);
	}

	_onLongPressEnd(LongPressEndDetails details, BuildContext context) {
		final Offset touchPosition = details.globalPosition;

		if (!_isOutsideChildBox(touchPosition)) {
			Future.delayed(duration, () => _triggerOnPressed());
		}

		_controller.reverse();
	}

	_onDragEnd(DragEndDetails details) {
		if (!_isOutside) {
			Future.delayed(duration, () => _triggerOnPressed());
		}

		_controller.reverse();
	}

	bool _isOutsideChildBox(Offset touchPosition) {
		final RenderBox childRenderBox = _childKey.currentContext!.findRenderObject() as RenderBox;
		final Size childSize = childRenderBox.size;
		final Offset childPosition = childRenderBox.localToGlobal(Offset.zero);

		return (touchPosition.dx < childPosition.dx ||
				touchPosition.dx > childPosition.dx + childSize.width ||
				touchPosition.dy < childPosition.dy ||
				touchPosition.dy > childPosition.dy + childSize.height);
	}
}