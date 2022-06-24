import 'package:flutter/material.dart';

class AvatarChip extends StatefulWidget {
  final Widget? avatar;
  final Widget label;
  final EdgeInsets padding;
  final ShapeBorder? shape;
  final double space;
  final Color? backgroundColor;
  final Clip clipBehavior;

  AvatarChip({
    Key? key,
    this.avatar,
    required this.label,
    this.padding = const EdgeInsets.all(2),
    this.space = 4.0,
    this.backgroundColor,
    this.clipBehavior = Clip.antiAlias,
    this.shape,}): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AvatarChipState();
  }
}
///--------------------------------------------------------------------------------------------
class _AvatarChipState extends State<AvatarChip>{
  late ShapeBorder shape;

  @override
  void initState(){
    super.initState();

    shape = widget.shape?? StadiumBorder();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    //final ButtonThemeData buttonTheme = ButtonTheme.of(context);

    Widget w = DecoratedBox(
      decoration: ShapeDecoration(
        shape: shape,
        color: widget.backgroundColor ?? theme.primaryColor,
      ),
      child: Padding(
        padding: widget.padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,

          children: <Widget>[
            widget.avatar ??
                CircleAvatar(
                  minRadius: 10,
                ),
            SizedBox(width: widget.space,),
            Flexible(child: widget.label,),
            SizedBox(width: 4,)
          ],
        ),
      ),
    );

    if(widget.clipBehavior == Clip.none) {
      return w;
    }

    return ClipPath(
      clipBehavior: widget.clipBehavior,
      clipper: ShapeBorderClipper(shape: shape, textDirection: Directionality.of(context)),
      child: w,
    );
  }

}