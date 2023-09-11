//library flutter_bounce;
import 'package:flutter/material.dart';

class BounceContainer extends StatefulWidget {
	final VoidCallback? onPressed;
	final Widget child;
	final Duration duration;

	BounceContainer({
		Key? key,
		required this.child,
		this.duration = const Duration(milliseconds: 200),
		this.onPressed
	}) : super(key: key);

	@override
	State createState() => BounceContainerState();
}
///=============================================================================================
class BounceContainerState extends State<BounceContainer> with SingleTickerProviderStateMixin {
	final GlobalKey _childKey = GlobalKey();
	late double _scale;
	late AnimationController _animController;

	VoidCallback? get onPressed => widget.onPressed;

	Duration get duration => widget.duration;

	@override
	void initState() {
		_animController = AnimationController(
				vsync: this,
				duration: duration,
				lowerBound: 0.0,
				upperBound: 0.1)
			..addListener(() {
				setState(() {});
			});

		super.initState();
	}

	@override
	void dispose() {
		_animController.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		_scale = 1 - _animController.value;

		return GestureDetector(
				onTap: _onTap,
				child: Transform.scale(
					key: _childKey,
					scale: _scale,
					child: widget.child,
				));
	}

	void _onTap() {
		_animController.forward();

		Future.delayed(duration, () =>_animController.reverse());
		Future.delayed(Duration(milliseconds: 50), () {
			if (onPressed != null) {
			  onPressed!.call();
			}
		});
	}
}