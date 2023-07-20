import 'package:flutter/services.dart';
import 'dart:math';
import 'package:intl/intl.dart';

class InputFormatter {
  InputFormatter._();

  /// (RegExp(r'[/\\]') >>  deny /,\
  static TextInputFormatter filterInputFormatterDeny(RegExp pattern){
    return FilteringTextInputFormatter.deny(pattern);
  }

  static TextInputFormatter filterInputFormatterAllow(RegExp pattern){
    return FilteringTextInputFormatter.allow(pattern);
  }

  static TextInputFormatter inputFormatterDigitsOnly(){
    return FilteringTextInputFormatter.digitsOnly;
  }

  static TextInputFormatter inputFormatterMobileNumber(){
    return FilteringTextInputFormatter.allow(RegExp('[0-9+-]'));
  }

  static TextInputFormatter inputFormatterMaxLen(int len){
    return LengthLimitingTextInputFormatter(len);
  }

  static TextEditingValue genTextEditingValue(String text){
    return TextEditingValue(
      text: text,
      selection: TextSelection(baseOffset: text.length, extentOffset: text.length),
    );
  }
}
///==============================================================================================
class MaxSizeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue();
  }
}
///==============================================================================================
class CurrencyTextInputFormatter extends TextInputFormatter {

  CurrencyTextInputFormatter({
    this.locale,
    this.name,
    this.symbol,
    this.decimalDigits,
    this.customPattern,
    this.turnOffGrouping = false,
  });

  final String? locale;
  final String? name;
  final String? symbol;
  final int? decimalDigits;
  final String? customPattern;
  final bool turnOffGrouping;
  num _newNum = 0;
  String _newString = '';

  void _formatter(String newText, bool isNegative) {
    final NumberFormat format = NumberFormat.currency(
      locale: locale,
      name: name,
      symbol: symbol,
      decimalDigits: decimalDigits,
      customPattern: customPattern,
    );

    if (turnOffGrouping) {
      format.turnOffGrouping();
    }

    _newNum = num.tryParse(newText) ?? 0;

    if (format.decimalDigits! > 0) {
      _newNum /= pow(10, format.decimalDigits!);
    }

    _newString = (isNegative ? '-' : '') + format.format(_newNum).trim();
  }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue,) {

    final bool isRemovedCharacter = oldValue.text.length - 1 == newValue.text.length &&
            oldValue.text.startsWith(newValue.text);

    // if (!isInsertedCharacter && !isRemovedCharacter) {
    //   return oldValue;
    // }

    final bool isNegative = newValue.text.startsWith('-');
    String newText = newValue.text.replaceAll(RegExp('[^0-9]'), '');

    if (isRemovedCharacter && !_lastCharacterIsDigit(oldValue.text)) {
      final int length = newText.length - 1;
      newText = newText.substring(0, length > 0 ? length : 0);
    }

    _formatter(newText, isNegative);

    if (newText.trim() == '') {
      return newValue.copyWith(
        text: isNegative ? '-' : '',
        selection: TextSelection.collapsed(offset: isNegative ? 1 : 0),
      );
    }
    else if (newText == '00' || newText == '000') {
      return TextEditingValue(
        text: isNegative ? '-' : '',
        selection: TextSelection.collapsed(offset: isNegative ? 1 : 0),
      );
    }

    return TextEditingValue(
      text: _newString,
      selection: TextSelection.collapsed(offset: _newString.length),
    );
  }

  static bool _lastCharacterIsDigit(String text) {
    final String lastChar = text.substring(text.length - 1);
    return RegExp('[0-9]').hasMatch(lastChar);
  }

  String getFormattedValue() {
    return _newString;
  }

  num getUnformattedValue() {
    return _newNum;
  }

  String format(String value) {
    final bool isNegative = value.startsWith('-');
    final String newText = value.replaceAll(RegExp('[^0-9]'), '');
    _formatter(newText, isNegative);
    return _newString;
  }
}
///==============================================================================================