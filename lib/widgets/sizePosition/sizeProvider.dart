import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


class SizeProviderWidget extends StatefulWidget {
  late final Widget child;
  late final Widget Function(Size) onSizeDetected;

  SizeProviderWidget({Key? key, required this.onSizeDetected, required this.child}) : super(key: key);

  @override
  _SizeProviderWidgetState createState() => _SizeProviderWidgetState();
}

class _SizeProviderWidgetState extends State<SizeProviderWidget> {
  Widget _overlayChild = SizedBox();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _overlayChild = widget.onSizeDetected(context.size!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        _overlayChild
      ],
    );
  }
}