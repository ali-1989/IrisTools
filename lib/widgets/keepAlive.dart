import 'package:flutter/widgets.dart';

class KeepAlive extends StatefulWidget {

  late final Widget child;

  KeepAlive({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  _KeepAliveState createState() => _KeepAliveState();
}
///===============================================================================================
class _KeepAliveState extends State<KeepAlive> with AutomaticKeepAliveClientMixin<KeepAlive> {

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}