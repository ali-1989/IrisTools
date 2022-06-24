import 'package:flutter/material.dart';

class OptionRow extends StatefulWidget {
  final Widget trailing;
  final String title;
  final TextStyle? titleStyle;
  final Color? backgroundColor;

  OptionRow({
    Key? key,
    required this.trailing,
    required this.title,
    this.titleStyle,
    this.backgroundColor,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return OptionRowState();
  }
}
///====================================================================================================
class OptionRowState extends State<OptionRow>{

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: ColoredBox(
        color: widget.backgroundColor?? Colors.transparent,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            widget.trailing,
            Text(widget.title, style: widget.titleStyle,)
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}