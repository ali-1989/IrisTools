import 'package:flutter/material.dart';

class CustomRich extends StatelessWidget {
  final List children;
  final PlaceholderAlignment alignment;
  final TextStyle? textStyle;
  final TextAlign? textAlign;
  final int? maxLine;
  final TextOverflow? textOverflow;
  final bool? softWrap;

  const CustomRich({
    Key? key,
    required this.children,
    this.alignment = PlaceholderAlignment.bottom,
    this.textStyle,
    this.textAlign,
    this.maxLine,
    this.textOverflow,
    this.softWrap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      style: textStyle,
        textAlign: textAlign,
        maxLines: maxLine,
        overflow: textOverflow,
        softWrap: softWrap,
        TextSpan(
            children: children.map<InlineSpan>(map).toList()
        )
    );
  }

  InlineSpan map(dynamic w){
    if(w is InlineSpan){
      return w;
    }

    if(w is Text){
      return TextSpan(text: w.data, style: w.style, locale: w.locale);
    }

    return WidgetSpan(child: w, alignment: alignment);
  }
}