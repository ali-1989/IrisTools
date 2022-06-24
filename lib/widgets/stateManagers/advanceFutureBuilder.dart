import 'package:flutter/material.dart';

typedef ReCallFuture = bool Function();
typedef WidgetBuilder = Widget Function(BuildContext context, dynamic futureValue);
///===============================================================================================
class AdvanceFutureBuilder extends StatefulWidget {
  final Future<dynamic> future;
  final WidgetBuilder builder;
  final VoidCallback? callAfterFuture;
  final ReCallFuture? reCallFuture;

  AdvanceFutureBuilder({
    required this.future,
    required this.builder,
    this.callAfterFuture,
    this.reCallFuture,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AdvanceFutureBuilderState();
  }
}
///===============================================================================================
class AdvanceFutureBuilderState extends State<AdvanceFutureBuilder> {
  dynamic futureResult;

  AdvanceFutureBuilderState();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (futureResult == null || (widget.reCallFuture != null && widget.reCallFuture!.call())) {
      _callFuture();
    }

    return widget.builder(context, futureResult);
  }

  @override
  void dispose(){
    super.dispose();
  }

  void _callFuture() {
    widget.future.then((value){
      //if(value is Widget){
      if(value != null){
        futureResult = value;

        if(mounted) {
          setState(() {});
          widget.callAfterFuture?.call();
        }
      }
    });
  }
}