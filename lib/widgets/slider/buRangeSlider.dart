import 'package:flutter/material.dart';

class BuRangeSlider extends StatefulWidget {
  final SliderThemeData? sliderTheme;
  final BoxDecoration? backgroundDecoration;
  final double sliderHeight;
  final ValueChanged<RangeValues>? onChangeStart;
  final ValueChanged<RangeValues>? onChanged;
  final ValueChanged<RangeValues>? onChangeEnd;
  final num min;
  final num max;
  final RangeValues values;
  final RangeLabels? labels;
  final bool fullWidth;

  BuRangeSlider({Key? key,
    required this.values,
    required this.onChanged,
    this.sliderTheme,
    this.onChangeStart,
    this.onChangeEnd,
    this.sliderHeight = 48,
    this.max = 50,
    this.min = 0,
    this.fullWidth = false,
    this.backgroundDecoration,
    this.labels,
  }) : super(key: key);

  @override
  _BuRangeSliderState createState() => _BuRangeSliderState();
}
///------------------------------------------------------------------------------------------------------------
class _BuRangeSliderState extends State<BuRangeSlider> {
  late ThemeData theme;
  late BoxDecoration backgroundDecor;
  late RangeValues _values;
  late RangeLabels _labels;
  late Color _textColor;
  late SliderThemeData _sliderThemeData;
  var valueInjector = ValueInjector();

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    _sliderThemeData = widget.sliderTheme?? theme.sliderTheme.copyWith(
        showValueIndicator: ShowValueIndicator.always,
        inactiveTrackColor: Colors.grey,
        activeTickMarkColor: theme.backgroundColor,
        rangeThumbShape: CustomSliderThumbCircle(
          valueInjector: valueInjector,
          thumbRadius: widget.sliderHeight * .3,
          min: double.tryParse(widget.min.toString())!,
          max: double.tryParse(widget.max.toString())!,
        ),
    );
    _textColor = _sliderThemeData.valueIndicatorTextStyle?.color?? _sliderThemeData.activeTrackColor!;
    double paddingFactor = .2;
    _values = widget.values;
    _labels = widget.labels?? RangeLabels('${_values.start}', '${_values.end}');
    valueInjector.value1 = _values.start;
    valueInjector.value2 = _values.end;

    backgroundDecor = widget.backgroundDecoration?? BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular((widget.sliderHeight * .3)),),
      color: _textColor.withAlpha(60),
    );

    if (widget.fullWidth) {
      paddingFactor = .3;
    }

    return Container(
      width: widget.fullWidth ? double.infinity : (widget.sliderHeight) * 5.5,
      height: widget.sliderHeight,
      decoration: backgroundDecor,
      child: Padding(
        padding: EdgeInsets.fromLTRB(widget.sliderHeight * paddingFactor, 1, widget.sliderHeight * paddingFactor, 1),

        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '${widget.min}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: widget.sliderHeight * .3,
                fontWeight: FontWeight.w700,
                color: _textColor,
              ),
            ),
            /*SizedBox(
              width: 0,//this.widget.sliderHeight * .1
            ),*/
            Expanded(
              child: Center(
                child: SliderTheme(
                  data: _sliderThemeData,
                  child: RangeSlider(
                    values: _values,
                    min: double.tryParse(widget.min.toString())!,
                    max: double.tryParse(widget.max.toString())!,
                    labels: _labels,
                    //divisions: 1,
                    onChanged: widget.onChanged,
                    onChangeStart: widget.onChangeStart,
                    onChangeEnd: widget.onChangeEnd,
                  ),
                ),
              ),
            ),

            Text(
              '${widget.max}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: widget.sliderHeight * .3,
                fontWeight: FontWeight.w700,
                color: _textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
///==================================================================================================================
class ValueInjector {
  dynamic value1 = 0;
  dynamic value2 = 0;

  dynamic get(int index){
    if(index == 0) {
      return value1;
    }

    return value2;
  }
}
///==================================================================================================================
class CustomSliderThumbRect extends SliderComponentShape {
  final double thumbRadius;
  final int thumbHeight;
  final int min;
  final int max;

  CustomSliderThumbRect({this.thumbRadius = 0.0, required this.thumbHeight, required this.min, required this.max,});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(PaintingContext context, Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {

    final Canvas canvas = context.canvas;
    final rRect = RRect.fromRectAndRadius(Rect.fromCenter(
        center: center, width: thumbHeight * 1.2, height: thumbHeight * .6), Radius.circular(thumbRadius * .4),
    );

    final paint = Paint()
      ..color = sliderTheme.activeTrackColor! //Thumb Background Color
      ..style = PaintingStyle.fill;

    TextSpan span = TextSpan(
        style: TextStyle(
            fontSize: thumbHeight * .3,
            fontWeight: FontWeight.w700,
            color: sliderTheme.thumbColor,
            height: 1),
        text: getValue(value));

    canvas.drawRRect(rRect, paint);

    TextPainter tp = TextPainter(text: span, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
    tp.layout();
    Offset textCenter = Offset(center.dx - (tp.width / 2), center.dy - (tp.height / 2));
    tp.paint(canvas, textCenter);
  }

  String getValue(double value) {
    return (min+(max-min)*value).round().toString();
  }
}
///==================================================================================================================
class CustomSliderThumbCircle extends RangeSliderThumbShape {
  final double thumbRadius;
  final double min;
  final double max;
  final ValueInjector valueInjector;

  const CustomSliderThumbCircle({
    this.thumbRadius = 0.0,
    required this.valueInjector,
    this.min = 0,
    this.max = 10,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
        bool isDiscrete = false,
        bool isEnabled = false,
        bool? isOnTop,
        required SliderThemeData sliderTheme,
        TextDirection? textDirection,
        Thumb? thumb,
        bool? isPressed,
  }) {

    final Canvas canvas = context.canvas;
    final paint = Paint()
      ..color = sliderTheme.activeTrackColor?? Colors.blueGrey
      ..style = PaintingStyle.fill;

    TextSpan span = TextSpan(
      style: TextStyle(
        fontSize: thumbRadius * .7,
        fontWeight: FontWeight.w700,
        color: sliderTheme.activeTickMarkColor, //sliderTheme.thumbColor,
      ),
      //text: '${valueInjector.get(thumb?.index?? 0)}',
      text: getValue(valueInjector.get(thumb?.index?? 0)),
    );

    canvas.drawCircle(center, thumbRadius * .9, paint);

    TextPainter tp = TextPainter(text: span, textAlign: TextAlign.center, textDirection: TextDirection.ltr);
    tp.layout();
    Offset textCenter = Offset(center.dx - (tp.width / 2), center.dy - (tp.height / 2));
    tp.paint(canvas, textCenter);
  }

  String getValue(num value) {
    return (value).round().toString();
  }
}
///==================================================================================================================
class RoundThumbShape extends SliderComponentShape {
  final double enabledThumbRadius;
  final double? disabledThumbRadius;

  const RoundThumbShape({
    this.enabledThumbRadius = 10.0,
    this.disabledThumbRadius,
  });

  double get _disabledThumbRadius =>  disabledThumbRadius ?? enabledThumbRadius;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(isEnabled == true ? enabledThumbRadius : _disabledThumbRadius);
  }

  @override
  void paint(PaintingContext context, Offset center, {
    required  Animation<double> activationAnimation
    , required Animation<double> enableAnimation
    , required bool isDiscrete
    , required TextPainter labelPainter
    , required RenderBox parentBox
    , required SliderThemeData sliderTheme
    , required TextDirection textDirection
    , required double value
    , required double textScaleFactor
    , required Size sizeWithOverflow}) {

    assert(sliderTheme.disabledThumbColor != null);
    assert(sliderTheme.thumbColor != null);

    final Canvas canvas = context.canvas;
    final Tween<double> radiusTween = Tween<double>(begin: _disabledThumbRadius, end: enabledThumbRadius,);
    final ColorTween colorTween = ColorTween(begin: sliderTheme.disabledThumbColor, end: sliderTheme.thumbColor,);
    canvas.drawCircle(center, radiusTween.evaluate(enableAnimation),
      Paint()..color = colorTween.evaluate(enableAnimation)!,
    );
  }
}
///===================================================================================================
class BuTickMarkShape extends SliderTickMarkShape {
  final double tickWidth;
  final double tickHeight;
  final int smallTickEvery;
  final int bigTickEvery;
  final int? mainTickEvery;

  const BuTickMarkShape({
    this.tickWidth = 2,
    this.tickHeight = 10,
    this.smallTickEvery = 10,
    this.bigTickEvery = 50,
    this.mainTickEvery = 100
  });

  @override
  Size getPreferredSize({required SliderThemeData sliderTheme, bool isEnabled = false})
  => Size(tickWidth, tickHeight);

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required Animation<double> enableAnimation,
        required Offset thumbCenter,
        required bool isEnabled,
        required TextDirection textDirection,
        int index = 0,
      }) {

    if (index % smallTickEvery == 0) {
      Rect rect;

      final paint = Paint()
        ..color = sliderTheme.activeTickMarkColor!
        ..style = PaintingStyle.fill;

      if (index % bigTickEvery == 0) {
        rect = Rect.fromCenter(center: center, width: tickWidth, height: tickHeight);
      } else {
        rect = Rect.fromCenter(center: center, width: tickWidth / 2, height: tickHeight / 2);
      }

      if (mainTickEvery != null && index % mainTickEvery! == 0) {
        paint.color = sliderTheme.activeTrackColor!;
      }

      context.canvas.drawRect(rect, paint);
    }
  }
}
///===================================================================================================