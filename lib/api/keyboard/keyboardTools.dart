import 'package:flutter/widgets.dart';

// https://stackoverflow.com/questions/56931108/make-only-one-widget-float-above-the-keyboard-in-flutter/56932251

///================================================================================================
class KeyboardSize {
	KeyboardSize._();

	static bool _isInit = false;
	static double _initSize = 0;

	static _init(BuildContext context){
		if(!_isInit){
			_initSize = EdgeInsets.fromWindowPadding(WidgetsBinding.instance.window.viewInsets, WidgetsBinding.instance.window.devicePixelRatio).bottom;
			_isInit = true;
		}
	}

	static double getKeyboardSize(BuildContext context){
		_init(context);

		//double s = MediaQuery.of(context).viewInsets.bottom;
		double s = EdgeInsets.fromWindowPadding(
				WidgetsBinding.instance.window.viewInsets,
				WidgetsBinding.instance.window.devicePixelRatio
		).bottom;

		return s;
	}

	static bool isKeyboardOpen(BuildContext context){
		return getKeyboardSize(context) > 0;
	}
}
///================================================================================================
class ScreenHeight extends ChangeNotifier {
	double keyboardHeight = 0;
	double initialHeight;
	bool get isOpen => keyboardHeight > 1;
	double get screenHeight => initialHeight;

	ScreenHeight({this.initialHeight = 0});

	void change(double a) {
		keyboardHeight = a;
		notifyListeners();
	}
}
///================================================================================================
class KeyboardDismissOnTap extends StatelessWidget {
	final Widget child;

	const KeyboardDismissOnTap({
		Key? key,
		required this.child,
	}) : super(key: key);


	void _hideKeyboard(BuildContext context) {
		//final currentFocus = FocusScope.of(context);

		//if (!currentFocus.hasPrimaryFocus && currentFocus.hasFocus) {
		FocusManager.instance.primaryFocus?.unfocus();
	}

	@override
	Widget build(BuildContext context) {
		return GestureDetector(
			child: child,
			onTap: () {
				_hideKeyboard(context);
			},
		);
	}
}



/*
//=======================================================================

Transform.translate(
    offset: Offset(0.0, -1 * MediaQuery.of(context).viewInsets.bottom),
    child: BottomPlayerBar(),
    );

 =======================================================================
*/