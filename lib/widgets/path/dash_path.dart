import 'dart:ui';

Path dashPath(
  Path source, {
  required CircularIntervalList<double> dashArray,
  DashOffset? dashOffset,
    }) {

  dashOffset = dashOffset ?? const DashOffset.absolute(0.0);
  // TO-DO: Is there some way to determine how much of a path would be visible today?

  final Path dest = Path();
  for (final PathMetric metric in source.computeMetrics()) {
    double distance = dashOffset._calculate(metric.length);
    bool draw = true;
    while (distance < metric.length) {
      final double len = dashArray.next;
      if (draw) {
        dest.addPath(metric.extractPath(distance, distance + len), Offset.zero);
      }
      distance += len;
      draw = !draw;
    }
  }

  return dest;
}

enum _DashOffsetType { Absolute, Percentage }

///=================================================================================================
class DashOffset {

  DashOffset.percentage(double percentage): _rawVal = percentage.clamp(0.0, 1.0),
        _dashOffsetType = _DashOffsetType.Percentage;

  const DashOffset.absolute(double start) : _rawVal = start,
        _dashOffsetType = _DashOffsetType.Absolute;

  final double _rawVal;
  final _DashOffsetType _dashOffsetType;

  double _calculate(double length) {
    return _dashOffsetType == _DashOffsetType.Absolute
        ? _rawVal
        : length * _rawVal;
  }
}
///=================================================================================================
class CircularIntervalList<T> {
  CircularIntervalList(this._vals);

  final List<T> _vals;
  int _idx = 0;

  T get next {
    if (_idx >= _vals.length) {
      _idx = 0;
    }
    return _vals[_idx++];
  }
}
