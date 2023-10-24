import 'package:flutter/material.dart';

typedef TextFieldMessageBuilder = Widget? Function(BuildContext context, TextEditingController controller);
typedef TextFieldBuilder = Widget Function(BuildContext context, TextEditingController controller, String? error);

class TextFieldWrapper extends StatefulWidget {
  final TextFieldBuilder builder;
  final TextEditingController controller;
  final TextFieldMessageBuilder messageBuilder;

  // ignore: prefer_const_constructors_in_immutables
  TextFieldWrapper({super.key, required this.builder, required this.controller, required this.messageBuilder});

  @override
  State<StatefulWidget> createState() {
    return TextFieldWrapperState();
  }
}
///=============================================================================
class TextFieldWrapperState extends State<TextFieldWrapper> {

  @override
  Widget build(BuildContext context) {
    final message = genMessage();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.builder(context, widget.controller, genError(message)),
        message?? SizedBox(),
      ],
    );
  }

  Widget? genMessage(){
    return widget.messageBuilder.call(context, widget.controller);
  }

  String? genError(dynamic message){
    return message == null? null : '';
  }
}