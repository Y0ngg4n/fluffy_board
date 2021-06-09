import 'dart:ui';

class Scribble {
  double strokeWidth;
  StrokeCap strokeCap;
  Color color;
  List<DrawPoint> points;

  Scribble(this.strokeWidth, this.strokeCap, this.color, this.points);
}

class DrawPoint extends Offset {
  bool empty = false;

  DrawPoint(double dx, double dy) : super(dx, dy);

  DrawPoint.empty() : super(0, 0) {
    this.empty = true;
  }

  DrawPoint.of(Offset offset): super(offset.dx, offset.dy);
}
