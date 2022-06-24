import 'package:flutter/material.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';

///========================================================================================
class HorizontalPicker extends StatefulWidget {
  final double minValue, maxValue;
  final HorizontalPickerController? controller;
  final double interval;
  final int subStepsCount;
  final double height;
  final double cellWidth;
  final double cursorWidth;
  final num cursorValue;
  final Function(num) onChanged;
  final bool showCursor;
  final bool useIntOnly;
  final Color? backgroundColor;
  final Color? itemBackgroundColor;
  final Color? cursorColor;
  final String? suffix;
  final List<double>? subSteps;
  final TextStyle? itemStyle;
  final TextStyle? selectedStyle;

  HorizontalPicker(
      {Key? key, required this.minValue,
        required this.maxValue,
        required this.onChanged,
        required this.cursorValue,
        this.controller,
        this.interval = 1.0,
        this.subStepsCount = 0,
        this.subSteps,
        this.height = 100,
        this.cellWidth = 60.0,
        this.cursorWidth = 2,
        this.showCursor = true,
        this.useIntOnly = false,
        this.itemStyle,
        this.selectedStyle,
        this.backgroundColor,
        this.itemBackgroundColor,
        this.cursorColor,
        this.suffix
      })
      : assert(minValue < maxValue), super(key: key);

  @override
  _HorizontalPickerState createState(){
    return _HorizontalPickerState();
  }
}
///========================================================================================
class _HorizontalPickerState extends State<HorizontalPicker> {
  late FixedExtentScrollController _scrollController;
  List<double> valueList = [];
  List<Map<String, dynamic>> valueMap = [];
  late int curItem;
  late Color backgroundColor;
  late Color itemBackgroundColor;
  late TextStyle baseStyle;
  late TextStyle selectedStyle;

  @override
  void initState() {
    super.initState();

    if(widget.controller != null) {
      widget.controller!._horizontalPicker = this;
    }

    double divs = 0;

    if(widget.subStepsCount > 0) {
      divs = (widget.interval / (widget.subStepsCount + 1));
      divs = fixPrecisionRound(divs, 2);
    }

    for (var i = widget.minValue; i < widget.maxValue; i += widget.interval) {
      valueMap.add({
        'value': widget.useIntOnly? i.toInt() : i,
      });

      if(widget.subSteps != null){
        for(int t = 0; t < widget.subSteps!.length; t++) {
          var x = (i + widget.subSteps![t]);

          valueMap.add({
            'value': widget.useIntOnly? x.toInt() : x,
          });
        }
      }
      else if(widget.subStepsCount > 0){
        for(int t = 0; t < widget.subStepsCount; t++) {
          var x = i + (divs * (t+1));

          valueMap.add({
            'value': widget.useIntOnly? x.toInt() : x,
          });
        }
      }
    }

    valueMap.add({
      'value': widget.useIntOnly? widget.maxValue.toInt() : widget.maxValue,
    });

    int initNumber = valueMap.indexWhere((element){
      bool isOk = element['value']! == widget.cursorValue;

      if(isOk){
        valueMap.elementAt(valueMap.indexOf(element))['isSelected'] = true;
        return true;
      }

      return false;
    });

    if(initNumber < 0) {
      valueMap.elementAt(0)['isSelected'] = true;
      initNumber = 0;
    }

    _scrollController = FixedExtentScrollController(initialItem: initNumber);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    baseStyle = widget.itemStyle?? theme.textTheme.bodyText2!;
    selectedStyle = widget.selectedStyle?? theme.textTheme.bodyText2!.copyWith(color: theme.primaryColor);
    backgroundColor = widget.backgroundColor?? Colors.grey[600]!;
    itemBackgroundColor = widget.itemBackgroundColor?? Colors.grey[300]!;

    // _scrollController.jumpToItem(curItem);
    return Container(
      padding: EdgeInsets.zero,
      height: widget.height,
      alignment: Alignment.center,
      child: ColoredBox(
        color: backgroundColor,
        child: Stack(
          children: <Widget>[
            RotatedBox(
              quarterTurns: 3,
              child: ListWheelScrollView(
                controller: _scrollController,
                itemExtent: widget.cellWidth,
                onSelectedItemChanged: (item) {
                  curItem = item;

                  for (var i = 0; i < valueMap.length; i++) {
                    if (i == item) {
                      valueMap[item]['isSelected'] = true;
                    }
                    else {
                      valueMap[i]['isSelected'] = false;
                    }
                  }

                  setState(() {});

                  widget.onChanged(valueMap[item]['value']);
                },
                children: getChildren(this),
              ),
            ),

            Visibility(
              visible: widget.showCursor,
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: MathHelper.minDouble(5, widget.height/10)),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: widget.cursorColor?? theme.primaryColor.withAlpha(150)),
                  width: widget.cursorWidth,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  static double fixPrecisionRound(double d, int n) {
    return double.parse(d.toStringAsFixed(n));
  }
}
///========================================================================================
List<Widget> getChildren(_HorizontalPickerState state){
  bool isSelected = false;
  Color color;
  double fs;

  return state.valueMap.map((Map<String, dynamic> curValue) {
    isSelected = curValue['isSelected']?? false;
    color = isSelected? state.selectedStyle.color!: state.baseStyle.color!;
    fs = isSelected? state.selectedStyle.fontSize!: state.baseStyle.fontSize!;

    return ItemWidget(
      textColor: color,
      height: state.widget.height,
      child: Text('${curValue['value']}',
          style: TextStyle(
            fontSize: fs,
            color: color,
            fontWeight: isSelected? FontWeight.w800: state.baseStyle.fontWeight,
          )
      ),
      suffixWidget: Text('${state.widget.suffix}',
        style: TextStyle(
          color: color,
          fontSize: fs,
          fontWeight: isSelected? FontWeight.w800: state.baseStyle.fontWeight,
        ),
      ),
      backgroundColor: state.itemBackgroundColor,
    );
  }).toList();
}
///========================================================================================
class ItemWidget extends StatefulWidget {
  final Widget child;
  final Widget suffixWidget;
  final Color backgroundColor;
  final Color textColor;
  final double height;
  final BorderRadius _borderRadius;

  ItemWidget({Key? key,
    required this.child,
    required this.height,
    required this.suffixWidget,
    required this.backgroundColor,
    required this.textColor,
    BorderRadius? borderRadius
  }): _borderRadius = borderRadius?? BorderRadius.circular(8), super(key: key);

  @override
  _ItemWidgetState createState() => _ItemWidgetState();
}
///========================================================================================
class _ItemWidgetState extends State<ItemWidget> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double fSiz = MathHelper.minDouble(10, widget.height/10);
    fSiz = MathHelper.maxDouble(fSiz, 4);

    double gapSiz = MathHelper.minDouble(6, widget.height/10-1);
    gapSiz = MathHelper.maxDouble(fSiz, 2);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 0),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: widget._borderRadius,
        ),
        child: RotatedBox(
          quarterTurns: 1,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '|',
                style: TextStyle(fontSize: fSiz, color: widget.textColor),
              ),
              SizedBox(
                height: gapSiz,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  widget.child,
                  widget.suffixWidget,
                ],
              ),

              SizedBox(
                height: gapSiz,
              ),
              Text(
                '|',
                style: TextStyle(fontSize: fSiz, color: widget.textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
///========================================================================================
class HorizontalPickerController {
  late _HorizontalPickerState _horizontalPicker;

  HorizontalPickerController();

  int _step(){
    //double min = _horizontalPicker.widget.maxValue;
    //double max = _horizontalPicker.widget.maxValue;
    int count = _horizontalPicker.valueMap.length;

    count = MathHelper.maxInt(3, count ~/ 10);
    return MathHelper.minInt(16, count);
  }

  void forward(){
    int count = _horizontalPicker.valueMap.length;
    int current = _horizontalPicker._scrollController.selectedItem;

    int des = current + _step();
    des = MathHelper.minInt(des, count);

    animateTo(des);
  }

  void back(){
    int current = _horizontalPicker._scrollController.selectedItem;
    int des = current - _step();

    des = MathHelper.maxInt(des, 0);

    animateTo(des);
  }

  void jumpTo(int index){
    if(!_horizontalPicker.mounted) {
      return;
    }

    _horizontalPicker._scrollController.jumpToItem(index);
  }

  void animateTo(int index){
    if(!_horizontalPicker.mounted) {
      return;
    }
    _horizontalPicker._scrollController.animateToItem(index,
        duration: Duration(milliseconds: 200),
        curve: Curves.fastOutSlowIn
    );
  }

  void jumpToValue(double value){
    if(!_horizontalPicker.mounted) {
      return;
    }

    int index = _horizontalPicker.valueMap.indexWhere((element){
      return element['value']! == value;
    });

    if(index >= 0) {
      jumpTo(index);
    }
  }

  void animateToValue(double value){
    if(!_horizontalPicker.mounted) {
      return;
    }

    int index = _horizontalPicker.valueMap.indexWhere((element){
      return element['value']! == value;
    });

    if(index >= 0) {
      animateTo(index);
    }
  }
}
///========================================================================================
