import 'package:flutter/material.dart';

typedef TextFieldMessageBuilder = Widget? Function(BuildContext context, TextEditingController controller, TextField textField);

class TextFieldWrapper extends StatefulWidget {
  final TextField child;
  final TextEditingController controller;
  final TextFieldMessageBuilder messageBuilder;

  // ignore: prefer_const_constructors_in_immutables
  TextFieldWrapper({super.key, required this.child, required this.controller, required this.messageBuilder});

  @override
  State<StatefulWidget> createState() {
    return TextFieldWrapperState();
  }
}
///=============================================================================
class TextFieldWrapperState extends State<TextFieldWrapper> {

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.child,
        genMessage(),
      ],
    );
  }

  Widget genMessage(){
    final res = widget.messageBuilder.call(context, widget.controller, widget.child);

    return res ?? const SizedBox();
  }
}