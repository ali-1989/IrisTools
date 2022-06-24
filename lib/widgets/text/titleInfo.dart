import 'package:flutter/material.dart';

enum BoldOption {
  title,
  info
}
///=================================================================================================
class TitleInfo extends StatefulWidget{
  final String title;
  final String info;
  final TextAlign textAlign;
  final StrutStyle? strutStyle;
  final TextStyle? titleStyle;
  final TextStyle? infoStyle;
  final TextDirection? textDirection;
  final TextOverflow? textOverflow;
  final int maxLines;
  final BoldOption boldOption;

  TitleInfo({
    Key? key,
    required this.title,
    required this.info,
    this.textAlign = TextAlign.start,
    this.boldOption = BoldOption.title,
    this.strutStyle,
    this.textDirection,
    this.textOverflow,
    this.titleStyle,
    this.infoStyle,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TitleInfoState();
  }
}
///==========================================================================================================
class TitleInfoState extends State<TitleInfo> {
  late TextDirection direction;
  late TextStyle titleSty;
  late TextStyle infoSty;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    direction = widget.textDirection?? Directionality.of(context);
    final sys = Theme.of(context).textTheme.bodyText2?? DefaultTextStyle.of(context).style;
    infoSty = widget.infoStyle?? sys;
    titleSty = widget.titleStyle?? sys;

    if(widget.boldOption == BoldOption.title) {
      titleSty = titleSty.copyWith(fontWeight: FontWeight.w900);
    }
    else {
      infoSty = infoSty.copyWith(fontWeight: FontWeight.w900);
    }

    return RichText(
        textDirection: direction,
        strutStyle: widget.strutStyle,
        textAlign: widget.textAlign,
        maxLines: widget.maxLines,
        softWrap: false,
        overflow: widget.textOverflow ?? TextOverflow.visible,
        text: TextSpan(
            children: [
              TextSpan(text: widget.title, style: titleSty,),
              TextSpan(text: widget.info, style: infoSty,)
            ])
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}