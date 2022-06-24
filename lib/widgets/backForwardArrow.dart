import 'package:flutter/material.dart';
import 'package:iris_tools/widgets/icon/circularIcon.dart';


typedef ArrowClick = void Function(BuildContext context);
///============================================================================================
class BackForwardArrow extends StatefulWidget {
  final Widget descriptionView;
  final ArrowClick? onLeftClick;
  final ArrowClick? onRightClick;
  final Color? arrowsBackColor;
  final Color? iconColor;
  final double? space;
  final IconData? leftIcon;
  final IconData? rightIcon;
  final double? iconSize;

  BackForwardArrow({
    Key? key,
    required this.descriptionView,
    this.onLeftClick,
    this.onRightClick,
    this.arrowsBackColor,
    this.leftIcon,
    this.rightIcon,
    this.iconColor,
    this.space,
    this.iconSize,
  }): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BackForwardArrowState();
  }
}
///============================================================================================
class BackForwardArrowState extends State<BackForwardArrow> {

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    double iconSize = widget.iconSize ?? theme.iconTheme.size?? 26;
    Color backColor = widget.arrowsBackColor?? theme.primaryColor;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              widget.onLeftClick?.call(context);
            },
            child: CircularIcon(
              backColor: backColor,
              itemColor: widget.iconColor,
              icon: widget.leftIcon?? Icons.arrow_back,
              size: iconSize,
            ),
          ),

          SizedBox(width: widget.space?? 8,),
          widget.descriptionView,
          SizedBox(width: widget.space?? 8,),

          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              widget.onRightClick?.call(context);
            },
            child: RotatedBox(
              quarterTurns: 2,
              child: CircularIcon(
                backColor: backColor,
                itemColor: widget.iconColor,
                icon: widget.rightIcon?? Icons.arrow_back,
                size: iconSize,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
///============================================================================================
