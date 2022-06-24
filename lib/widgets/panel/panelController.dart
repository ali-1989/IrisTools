import 'package:flutter/material.dart';

class PanelController extends ValueNotifier<bool> {

  PanelController() : super(false);

  void show() => value = true;

  void hide() => value = false;

  bool get isOpened => value;
}
