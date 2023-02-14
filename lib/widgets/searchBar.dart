import 'package:flutter/material.dart';

typedef ShareTextEditingController = void Function(TextEditingController tController);
typedef OnSearch = void Function(String text);
///=========================================================================================================
class SearchBar extends StatefulWidget {
  final bool maxWith;
  final TextDirection? textDirection;
  final BoxDecoration? decoration;
  final EdgeInsets? padding;
  final Widget? searchIcon;
  final Widget? inputWidget;
  final Widget? clearWidget;
  final OnSearch? searchEvent; //ValueChanged
  final VoidCallback? onClearEvent;
  final ValueChanged<String>? onChangeEvent;
  final GestureTapCallback? onTapEvent;
  final ShareTextEditingController? shareTextController;
  final bool insertDefaultClearIcon;
  final Color? iconColor;
  final String? hint;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;

  SearchBar({
    Key? key,
    this.searchIcon,
    this.searchEvent,
    this.shareTextController,
    this.onChangeEvent,
    this.onTapEvent,
    this.onClearEvent,
    this.inputWidget,
    this.clearWidget,
    this.hint,
    this.iconColor,
    this.maxWith = true,
    this.insertDefaultClearIcon = true,
    this.textDirection,
    this.decoration,
    this.padding,
    this.hintStyle,
    this.textStyle,
    }) :super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SearchBarState();
  }
}
///=================================================================================================
class SearchBarState extends State<SearchBar> {
  late TextEditingController controller;
  late Color _iconColor;

  @override
  void initState() {
    super.initState();

    controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    widget.shareTextController?.call(controller);

    ThemeData theme = Theme.of(context);
    TextDirection direction = widget.textDirection?? Directionality.of(context);
    Color borderColor = theme.textTheme.bodyMedium!.color?? Colors.black;
    borderColor = borderColor.withAlpha(150);
    _iconColor = widget.iconColor?? theme.primaryColor;

    BoxDecoration decoration = BoxDecoration(
      color: Colors.transparent ,//theme.colorScheme.background,
      borderRadius: BorderRadius.all(Radius.circular(8)),
      border: Border.symmetric(
          horizontal: BorderSide(color: borderColor, width: 0.7, style: BorderStyle.solid),
          vertical: BorderSide(color: borderColor, width: 0.7, style: BorderStyle.solid),
      ),
    );

    TextStyle hintStyle = widget.hintStyle ?? theme.textTheme.bodySmall!.copyWith(
      color: borderColor,
    );

    Widget searchIcon = widget.searchIcon??
        IconButton(
            splashColor: Colors.transparent,
            icon: Icon(
              Icons.search,
              color: _iconColor,
            ),
            padding: EdgeInsets.zero,
            onPressed: (){
              widget.searchEvent?.call(controller.text);
            }
        );

    Widget input = widget.inputWidget??
        TextField(
          textDirection: direction,
          onChanged: widget.onChangeEvent,
          onTap: widget.onTapEvent,
          onSubmitted: widget.searchEvent,
          controller: controller,
          expands: false,
          style: widget.textStyle,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.zero,
            border: InputBorder.none,
            disabledBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            hintText: widget.hint,
            hintStyle: hintStyle,
          ),
        );

     Widget? clear = widget.insertDefaultClearIcon?
     IconButton(
         icon: Icon(
           Icons.clear,
           color: _iconColor, //borderColor
           size: 17,
         ),
         padding: EdgeInsets.zero,
         onPressed: (){
           controller.clear();
           widget.onClearEvent?.call();
         }
     ) : widget.clearWidget;

    return DecoratedBox(
      decoration: widget.decoration?? decoration,
      child: Padding(
        padding: widget.padding?? EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        child: Row(
          mainAxisSize: widget.maxWith? MainAxisSize.max: MainAxisSize.min,
          textDirection: direction,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Material(
              color: Colors.transparent,
              type: MaterialType.circle,
              clipBehavior: Clip.antiAlias,
              borderOnForeground: true,
              elevation: 0,
              child: searchIcon,
            ),
            Expanded(
              child: input,
            ),
            if(clear != null)
              Material(
                color: Colors.transparent,
                type: MaterialType.circle,
                clipBehavior: Clip.antiAlias,
                borderOnForeground: true,
                elevation: 0,
                child: clear,
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }
}