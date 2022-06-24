import 'package:flutter/widgets.dart';

/// alternative: https://pub.dev/packages/flutter_keyboard_visibility  (use native)


typedef KeyboardBuilder = Widget Function(BuildContext context, Widget? child, bool isKeyboardOpen);
///====================================================================================================
class KeyboardStateListener extends StatefulWidget {
  final Widget? child;
  final KeyboardBuilder builder;

  const KeyboardStateListener({
    Key? key,
    this.child,
    required this.builder,
  }) : super(key: key);

  @override
  _KeyboardStateListenerState createState() => _KeyboardStateListenerState();
}
///====================================================================================================
class _KeyboardStateListenerState extends State<KeyboardStateListener> with WidgetsBindingObserver {
  var _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    var bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    _isKeyboardVisible = bottomInset > 10.0;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    bool newState = bottomInset > 10.0;

    if (newState != _isKeyboardVisible) {
      setState(() {
        _isKeyboardVisible = newState;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.child, _isKeyboardVisible);
  }
}