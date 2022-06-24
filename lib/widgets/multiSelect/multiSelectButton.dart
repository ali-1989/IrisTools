import 'package:flutter/material.dart';

class MultiSelectButton extends StatelessWidget {
  final String text;
  final void Function() onPressed;
  final bool isSelected;
  final Widget? selectedIcon;
  final Widget? unSelectedIcon;
  final TextStyle? selectedTextStyle;
  final TextStyle? unselectedTextStyle;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color selectedBorderColor;
  final Color unselectedBorderColor;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? selectedShadow;
  final List<BoxShadow>? unselectedShadow;
  final double? height;
  final double? width;
  final EdgeInsets? padding;

  const MultiSelectButton({
    Key? key,
    required this.onPressed,
    required this.text,
    required this.isSelected,
    required this.selectedBorderColor,
    required this.unselectedBorderColor,
    this.selectedIcon,
    this.unSelectedIcon,
    this.selectedTextStyle,
    this.unselectedTextStyle,
    this.selectedColor,
    this.unselectedColor,
    this.borderRadius,
    this.selectedShadow,
    this.unselectedShadow,
    this.height,
    this.width,
    this.padding,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      height: height,
      width: width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          //minimumSize: MaterialStateProperty.all(Size(5,5)),
          padding: MaterialStateProperty.all(padding?? EdgeInsets.symmetric(horizontal: 6, vertical: 4)),
          elevation: MaterialStateProperty.all<double>(0.0),
          backgroundColor: isSelected
              ? MaterialStateProperty.all<Color?>(selectedColor)
              : MaterialStateProperty.all<Color?>(unselectedColor),
          shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(30),
              side: BorderSide(
                color: isSelected ? selectedBorderColor : unselectedBorderColor,
              ),
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if(isSelected && selectedIcon != null)
              selectedIcon!,

            if(!isSelected && unSelectedIcon != null)
              unSelectedIcon!,

            Text(text,
              style: isSelected ? selectedTextStyle : unselectedTextStyle,
            ),
          ],
        ),
      ),
    );
  }
}
