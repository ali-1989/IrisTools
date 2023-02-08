import 'package:flutter/material.dart';

class TextFieldHelper {
  TextFieldHelper._();

  static void fullSelectText(TextEditingController ctr){
    ctr.selection = TextSelection(baseOffset: 0, extentOffset: ctr.text.length);
  }

  static TextEditingValue getTextEditingValue(String text){
    return TextEditingValue(
      text: text,
      selection: TextSelection(baseOffset: text.length, extentOffset: text.length),
    );
  }
}