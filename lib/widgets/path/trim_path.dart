import 'dart:ui';


enum PathTrimOrigin {
  begin, /// Specifies that trimming should start from the first point in a segment.
  end /// Specifies that trimming should start from the last point in a segment.
}
///=============================================================================
Path trimPath(
  Path source,
  double percentage, {
  bool firstOnly = true,
  PathTrimOrigin origin = PathTrimOrigin.begin,
}) {
  percentage = percentage.clamp(0.0, 1.0);

  if (percentage == 1.0) {
    return Path();
  }

  if (percentage == 0.0) {
    return Path.from(source);
  }

  if (origin == PathTrimOrigin.end) {
    percentage = 1.0 - percentage;
  }

  final Path dest = Path();

  for (final PathMetric metric in source.computeMetrics()) {
    switch (origin) {
      case PathTrimOrigin.end:
        dest.addPath(
          metric.extractPath(0.0, metric.length * percentage),
          Offset.zero,
        );
        break;
      case PathTrimOrigin.begin:
        dest.addPath(
          metric.extractPath(metric.length * percentage, metric.length),
          Offset.zero,
        );
        break;
    }

    if (firstOnly) {
      break;
    }
  }

  return dest;
}
