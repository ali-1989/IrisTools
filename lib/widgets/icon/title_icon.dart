import 'package:flutter/material.dart';


class TitleIcon extends StatefulWidget{
  final String title;
  final Widget icon;
  final TextAlign textAlign;
  final StrutStyle? strutStyle;
  final TextStyle? iconStyle;
  final TextStyle? infoStyle;
  final TextDirection? textDirection;
  final int maxLines;
  final PlaceholderAlignment iconAlignment;

  TitleIcon({
    Key? key,
    required this.title,
    required this.icon,
    this.textAlign = TextAlign.start,
    this.strutStyle,
    this.textDirection,
    this.iconStyle,
    this.infoStyle,
    this.maxLines = 1,
    this.iconAlignment = PlaceholderAlignment.middle,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TitleIconState();
  }
}
///==========================================================================================================
class TitleIconState extends State<TitleIcon> {
  late TextDirection direction;
  late TextStyle iconSty;
  late TextStyle titleSty;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    direction = widget.textDirection?? Directionality.of(context);
    final sys = Theme.of(context).textTheme.bodyText2?? DefaultTextStyle.of(context).style;
    titleSty = widget.infoStyle?? sys;
    iconSty = widget.iconStyle?? sys;

    titleSty = titleSty.copyWith(fontWeight: FontWeight.w800);

    return RichText(
        textDirection: direction,
        strutStyle: widget.strutStyle,
        textAlign: widget.textAlign,
        maxLines: widget.maxLines,
        overflow: TextOverflow.clip,
        text: TextSpan(
            children: [
              TextSpan(text: widget.title, style: titleSty,),
              WidgetSpan(child: widget.icon, style: iconSty, alignment: widget.iconAlignment),
            ])
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}