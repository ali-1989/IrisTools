library multi_select;

import 'package:flutter/material.dart';
import 'multiSelectBody.dart';
import 'multiSelectButton.dart';

/// src: https://pub.dev/packages/group_button

typedef BuildChoice = Widget Function(BuildContext context, MultiSelectButton button, int index, String value);
///==============================================================================================
class MultiSelect extends StatelessWidget {
  final List<String> buttons;
  final List<int>? selectedButtons;
  final int? selectedButton;
  final Function(int index, String value, bool isSelected) onChangeState;
  final BuildChoice? buildChoice;

  /// if the [isRadio] = true, only one button can be selected
  /// if the [isRadio] = false, you can select several at once
  final bool isRadio;
  final bool useWrap;
  final bool isDisable;
  final Axis? wrapDirection;
  final double spacing;
  final double runSpacing;
  final TextStyle? selectedTextStyle;
  final TextStyle? unselectedTextStyle;
  final Color selectedColor;
  final Color unselectedColor;
  final Color selectedBorderColor;
  final Color unselectedBorderColor;
  final BorderRadius? borderRadius;
  final List<BoxShadow> selectedShadow;
  final List<BoxShadow> unselectedShadow;
  final double? buttonHeight;
  final double? buttonWidth;
  final Widget? selectedIcon;
  final Widget? unSelectedIcon;
  final EdgeInsets? padding;

  //static const _kDefaultSelectedTextStyle = TextStyle(fontSize: 14, color: Colors.white);
  //static const _kDefaultUnselectedTextStyle = TextStyle(fontSize: 14, color: Colors.black);
  static const _kDefaultSelectedColor = Colors.green;
  static const _kDefaultUnselectedColor = Colors.white;
  static const _kDefaultShadow = <BoxShadow>[
    BoxShadow(
      color: Color.fromARGB(18, 18, 18, 20),
      blurRadius: 25.0,
      spreadRadius: 1.0,
      offset: Offset(0.0, 2.0,),
    )
  ];

  const MultiSelect({
    Key? key,
    required this.buttons,
    required this.onChangeState,
    this.selectedButtons,
    this.buildChoice,
    this.isRadio = true,
    this.useWrap = true,
    this.isDisable = false,
    this.wrapDirection,
    this.spacing = 2,
    this.runSpacing = 2,
    this.selectedIcon,
    this.unSelectedIcon,
    this.padding,
    this.selectedTextStyle, // = _kDefaultSelectedTextStyle
    this.unselectedTextStyle,
    this.selectedColor = _kDefaultSelectedColor,
    this.unselectedColor = _kDefaultUnselectedColor,
    this.selectedBorderColor = Colors.transparent,
    this.unselectedBorderColor = Colors.transparent,
    this.borderRadius,
    this.selectedShadow = _kDefaultShadow,
    this.unselectedShadow = _kDefaultShadow,
    this.buttonHeight,
    this.buttonWidth,
    this.selectedButton,
  })  : assert(
  (isRadio && selectedButtons == null) ||
      (!isRadio && selectedButton == null),
  'You can use selectedButton field for isRadio [true] and selectedButtons field with isRadio [false]'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiSelectBody(
      buttons: buttons,
      selectedButtons: selectedButtons,
      selectedButton: selectedButton,
      onSelected: onChangeState,
      isRadio: isRadio,
      wrapDirection: wrapDirection,
      spacing: spacing,
      runSpacing: runSpacing,
      useWrap: useWrap,
      isDisable: isDisable,
      selectedTextStyle: selectedTextStyle,
      unselectedTextStyle: unselectedTextStyle,
      selectedColor: selectedColor,
      unselectedColor: unselectedColor,
      selectedBorderColor: selectedBorderColor,
      unselectedBorderColor: unselectedBorderColor,
      borderRadius: borderRadius,
      selectedShadow: selectedShadow,
      unselectedShadow: unselectedShadow,
      buttonWidth: buttonWidth,
      buttonHeight: buttonHeight,
      selectedIcon: selectedIcon,
      unSelectedIcon: unSelectedIcon,
      padding: padding,
    );
  }
}
