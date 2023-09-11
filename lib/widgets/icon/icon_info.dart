import 'package:flutter/widgets.dart';

class IconInfo extends StatefulWidget{
  final Widget icon;
  final String info;
  final TextAlign textAlign;
  final StrutStyle? strutStyle;
  final TextStyle? iconStyle;
  final TextStyle? infoStyle;
  final TextDirection? textDirection;
  final int maxLines;
  final PlaceholderAlignment iconAlignment;

  IconInfo({
    Key? key,
    required this.icon,
    required this.info,
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
    return IconInfoState();
  }
}
///==========================================================================================================
class IconInfoState extends State<IconInfo> {
  late TextDirection direction;
  late TextStyle iconSty;
  late TextStyle infoSty;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    direction = widget.textDirection?? Directionality.of(context);
    TextStyle sys = DefaultTextStyle.of(context).style;
    infoSty = widget.infoStyle?? sys;
    iconSty = widget.iconStyle?? sys.copyWith(fontWeight: FontWeight.w800);

    return RichText(
        textDirection: direction,
        strutStyle: widget.strutStyle,
        textAlign: widget.textAlign,
        maxLines: widget.maxLines,
        overflow: TextOverflow.clip,
        text: TextSpan(
            children: [
              WidgetSpan(child: widget.icon, style: iconSty, alignment: widget.iconAlignment),
              TextSpan(text: widget.info, style: infoSty,)
            ])
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}