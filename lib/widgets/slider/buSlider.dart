import 'package:flutter/material.dart';

class BuSlider extends StatefulWidget {
  final SliderThemeData? sliderTheme;
  final BoxDecoration? backgroundDecoration;
  final double sliderHeight;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeEnd;
  final double min;
  final double max;
  final num value;
  final bool fullWidth;

  BuSlider({Key? key,
    required this.value,
    required this.onChanged,
    this.sliderTheme,
    this.onChangeStart,
    this.onChangeEnd,
    this.sliderHeight = 48,
    this.max = 20,
    this.min = 0,
    this.fullWidth = false,
    this.backgroundDecoration
  }) : super(key: key);

  @override
  _BuSliderState createState() => _BuSliderState();
}
///------------------------------------------------------------------------------------------------------------
class _BuSliderState extends State<BuSlider> {
  late ThemeData theme;
  late BoxDecoration backgroundDecor;
  late Color color1;
  late Color color2;
  late double _value;

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    SliderThemeData sliderTheme = widget.sliderTheme?? theme.sliderTheme;
    HSLColor hsl = HSLColor.fromColor(theme.primaryColor);
    color1 = hsl.withHue(hsl.hue + (hsl.hue < 130 ? 4: -4)).toColor();
    color2 = hsl.withHue(hsl.hue + (hsl.hue < 130 ? 12: -12)).toColor();
    double paddingFactor = .2;
    _value = widget.value.toDouble();

    backgroundDecor = widget.backgroundDecoration?? BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular((widget.sliderHeight * .3)),),
      gradient: LinearGradient(
          colors: [color1, color2,],
          begin: const FractionalOffset(0.0, 0.0),
          end: const FractionalOffset(1.0, 1.00),
          stops: [0.0, 1.0],
          tileMode: TileMode.clamp),
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
                fontWeight: FontWeight.bold,
                fontFamily: theme.textTheme.subtitle1!.fontFamily,
                color: sliderTheme.valueIndicatorTextStyle?.color?? sliderTheme.activeTrackColor,
              ),
            ),
            /*SizedBox(
              width: 0,//this.widget.sliderHeight * .1
            ),*/
            Expanded(
              child: Center(
                child: SliderTheme(
                  data: sliderTheme.copyWith(
                    showValueIndicator: ShowValueIndicator.always,
                    // valueIndicatorTextStyle: TextStyle(
                    //   fontSize: this.widget.sliderHeight * .3,
                    //   fontWeight: FontWeight.bold,
                    //   fontFamily: theme.textTheme.subtitle1!.fontFamily,
                    // ),
                    thumbShape: CustomSliderThumbCircle(
                      theme: theme,
                      thumbRadius: widget.sliderHeight * .4,
                      min: widget.min,
                      max: widget.max,
                    ),
                  ),
                  child: Slider(
                      value: _value,
                      min: widget.min,
                      max: widget.max,
                      label: '${_value.roundToDouble()}',
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
                fontWeight: FontWeight.bold,
                fontFamily: theme.textTheme.subtitle1!.fontFamily,
                color: sliderTheme.valueIndicatorTextStyle?.color?? sliderTheme.activeTrackColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
///======================================================================================================
class CustomSliderThumbRect extends SliderComponentShape {
  final double thumbRadius;
  int thumbHeight;
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
class CustomSliderThumbCircle extends SliderComponentShape {
  final ThemeData theme;
  final double thumbRadius;
  final double min;
  final double max;

  const CustomSliderThumbCircle({required this.theme, this.thumbRadius = 0.0, this.min = 0, this.max = 10,});

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
    final paint = Paint()
      ..color = sliderTheme.valueIndicatorTextStyle?.color?? Colors.blueGrey
      ..style = PaintingStyle.fill;

    TextSpan span = TextSpan(
      style: TextStyle(
        fontSize: thumbRadius * .8,
        fontWeight: FontWeight.bold,
        fontFamily: theme.textTheme.subtitle1!.fontFamily,
        color: sliderTheme.thumbColor,
      ),
      text: getValue(value),
    );

    canvas.drawCircle(center, thumbRadius * .9, paint);

    TextPainter tp = TextPainter(text: span, textAlign: TextAlign.center, textDirection: TextDirection.ltr);
    tp.layout();
    Offset textCenter = Offset(center.dx - (tp.width / 2), center.dy - (tp.height / 2));
    tp.paint(canvas, textCenter);
  }

  String getValue(double value) {
    return (min + (max-min) * value).round().toString();
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