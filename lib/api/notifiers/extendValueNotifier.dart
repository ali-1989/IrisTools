import 'package:flutter/material.dart';

class ExtendValueNotifier<T> extends ValueNotifier<T> {

  ExtendValueNotifier(T value) : super(value);

  @override
  bool get hasListeners {
    return super.hasListeners;
  }
}