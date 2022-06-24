import 'package:flutter/material.dart';

typedef RadioOnChanged<T> = void Function(T value);
///============================================================================================
class RadioRow extends StatefulWidget {
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final dynamic value;
  final dynamic groupValue;
  final RadioOnChanged onChanged;
  final Widget description;
  final Radio? radio;
  final EdgeInsets? padding;
  final Color? color;

  RadioRow({
    Key? key,
    required this.description,
    required this.groupValue,
    required this.value,
    required this.onChanged,
    this.radio,
    this.color,
    this.padding,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
  })
  : super(key: key);

  @override
  State createState() {
    return RadioRawState();
  }
}
///============================================================================================
class RadioRawState<S> extends State<RadioRow> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: (){
        widget.onChanged.call(widget.value);
      },
      child: Padding(
        padding: widget.padding?? EdgeInsets.all(0),
        child: IgnorePointer(
          child: Row(
            mainAxisAlignment: widget.mainAxisAlignment,
            mainAxisSize: widget.mainAxisSize,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if(widget.radio != null)
                widget.radio!,

              if(widget.radio == null)
                Radio<S>(
                  toggleable: false, //false: can not unSelect
                  groupValue: widget.groupValue,
                  value: widget.value,
                  onChanged: widget.onChanged,
                  fillColor: MaterialStateProperty.all(
                      widget.color??
                          theme.radioTheme.fillColor?.resolve({MaterialState.pressed, MaterialState.selected})),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.comfortable,
                ),

              Flexible(
                  child: widget.description,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}