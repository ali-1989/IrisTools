import 'package:flutter/material.dart';


typedef RadioOnChanged<T> = void Function(T value);
///============================================================================================
class CheckBoxRow extends StatefulWidget {
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final bool? value;
  final bool treeState;
  final RadioOnChanged onChanged;
  final Widget description;
  final Checkbox? checkbox;
  final EdgeInsets? padding;
  final Color? fillColor;
  final Color? tickColor;
  final OutlinedBorder? shape;
  final BorderSide? borderSide;

  CheckBoxRow({
    Key? key,
    required this.value,
    required this.description,
    required this.onChanged,
    this.checkbox,
    this.treeState = false,
    this.padding,
    this.fillColor,
    this.tickColor,
    this.shape,
    this.borderSide,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.min,
  })
  : super(key: key);

  @override
  State createState() {
    return RadioRawState();
  }
}
///============================================================================================
class RadioRawState<S> extends State<CheckBoxRow> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //final theme = Theme.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: (){
        widget.onChanged.call(widget.value == null? widget.value: !(widget.value!));
      },
      child: Padding(
        padding: widget.padding?? EdgeInsets.all(0),
        child: Row(
          mainAxisAlignment: widget.mainAxisAlignment,
          mainAxisSize: widget.mainAxisSize,
          //crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if(widget.checkbox != null)
              widget.checkbox!,

            if(widget.checkbox == null)
              IgnorePointer(
                child: Checkbox(
                  value: (!widget.treeState && widget.value == null)? false: widget.value,
                  onChanged: widget.onChanged,
                  tristate: widget.treeState,
                  shape: widget.shape,
                  side: widget.borderSide,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.comfortable,
                  checkColor: widget.tickColor,
                  fillColor: widget.fillColor != null? MaterialStateProperty.all(widget.fillColor) : null,
                ),
              ),

            Flexible(
                child: widget.description,
            ),
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