import 'package:flutter/material.dart';

class TextFieldHelper {
  TextFieldHelper._();

  static void fullSelectText(TextEditingController ctr){
    ctr.selection = TextSelection(baseOffset: 0, extentOffset: ctr.text.length);
  }

  static void cursorToEnd(TextEditingController ctr){
    ctr.selection = TextSelection.collapsed(offset: ctr.text.length);
  }

  static void cursorToStart(TextEditingController ctr){
    ctr.selection = TextSelection.collapsed(offset: 0);
  }

  static TextEditingValue genTextEditingValue(String text){
    return TextEditingValue(
      text: text,
      selection: TextSelection(baseOffset: text.length, extentOffset: text.length),
    );
  }
}