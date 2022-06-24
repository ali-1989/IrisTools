import 'package:flutter/material.dart';
import 'multiSelect.dart';
import 'multiSelectButton.dart';

class MultiSelectBody extends StatefulWidget {
  final List<String> buttons;
  final List<int>? selectedButtons;
  final int? selectedButton;
  final Function(int, String, bool) onSelected;
  final bool isRadio;
  final bool useWrap;
  final bool isDisable;
  final Axis? wrapDirection;
  final double spacing;
  final double runSpacing;
  final TextStyle? selectedTextStyle;
  final TextStyle? unselectedTextStyle;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color selectedBorderColor;
  final Color unselectedBorderColor;
  final BuildChoice? buildChoice;
  final BorderRadius? borderRadius;
  final List<BoxShadow> selectedShadow;
  final List<BoxShadow> unselectedShadow;
  final double? buttonWidth;
  final double? buttonHeight;
  final Widget? selectedIcon;
  final Widget? unSelectedIcon;
  final EdgeInsets? padding;

  const MultiSelectBody({
    Key? key,
    required this.buttons,
    required this.selectedBorderColor,
    required this.unselectedBorderColor,
    required this.onSelected,
    this.selectedIcon,
    this.unSelectedIcon,
    this.selectedButtons,
    this.selectedButton,
    this.buildChoice,
    this.isRadio = false,
    this.useWrap = true,
    this.isDisable = false,
    this.wrapDirection,
    this.spacing = 2,
    this.runSpacing = 2,
    this.selectedTextStyle,
    this.unselectedTextStyle,
    this.selectedColor,
    this.unselectedColor,
    this.padding,
    this.borderRadius,
    this.selectedShadow = const [],
    this.unselectedShadow = const [],
    this.buttonWidth,
    this.buttonHeight,
  }) : super(key: key);

  @override
  _MultiSelectBodyState createState() => _MultiSelectBodyState();
}
///=========================================================================================
class _MultiSelectBodyState extends State<MultiSelectBody> {
  var _selectedIndex = 0;
  final Map<int, bool> _selectedIndexes = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _selectedIndexes.clear();

    if (widget.selectedButtons != null) {
      for (var e in widget.selectedButtons!) {
        _selectedIndexes[e] = true;
      }
    }

    if (widget.selectedButton != null) {
      _selectedIndex = widget.selectedButton!;
    }

    return IgnorePointer(
      ignoring: widget.isDisable,
      child: Builder(
          builder: (ctx){
            if(!widget.useWrap){
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _buildButtonsList(widget.buttons),
                ),
              );
            }

            return Wrap(
              direction: widget.wrapDirection ?? Axis.horizontal,
              spacing: widget.spacing,
              runSpacing: widget.runSpacing,
              crossAxisAlignment: WrapCrossAlignment.start,
              alignment: WrapAlignment.start,
              runAlignment: WrapAlignment.start,
              //verticalDirection: VerticalDirection.down,
              children: _buildButtonsList(widget.buttons),
            );
          }),
    );
  }

  List<Widget> _buildButtonsList(List<String> buttons) {
    ThemeData theme = Theme.of(context);
    TextStyle selected = theme.textTheme.headline5!;
    TextStyle unSelected = theme.textTheme.headline5!;
    final result = <Widget>[];

    for (var i = 0; i < buttons.length; i++) {
      final btn = MultiSelectButton(
        text: buttons[i],
        onPressed: () {
          _onSelectButton(i);
          widget.onSelected(i, buttons[i], _isSelected(i),);
        },
        selectedIcon: widget.selectedIcon,
        unSelectedIcon: widget.unSelectedIcon,
        isSelected: _isSelected(i),
        selectedTextStyle: widget.selectedTextStyle?? selected,
        unselectedTextStyle: widget.unselectedTextStyle?? unSelected,
        selectedColor: widget.selectedColor,
        unselectedColor: widget.unselectedColor,
        selectedBorderColor: widget.selectedBorderColor,
        unselectedBorderColor: widget.unselectedBorderColor,
        borderRadius: widget.borderRadius,
        selectedShadow: widget.selectedShadow,
        unselectedShadow: widget.unselectedShadow,
        height: widget.buttonHeight,
        width: widget.buttonWidth,
        padding: widget.padding,
      );

      Widget view = btn;

      if(widget.buildChoice != null){
        view = widget.buildChoice!.call(context, btn, i, buttons[i]);
      }

      result.add(view);

      if(!widget.useWrap && i+1 < buttons.length){
        result.add(SizedBox(width: widget.spacing,));
      }
    }

    return result;
  }

  void _onSelectButton(int i) {
    if (widget.isRadio) {
      setState(() => _selectedIndex = i);
    }
    else {
      if (_selectedIndexes.containsKey(i)) {
        setState(() => _selectedIndexes[i] = !_selectedIndexes[i]!);
      }
      else {
        setState(() => _selectedIndexes[i] = true);
      }
    }
  }

  bool _isSelected(int i) {
    return widget.isRadio
        ? i == _selectedIndex
        : _selectedIndexes.containsKey(i) && _selectedIndexes[i] == true;
  }
}
