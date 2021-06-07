import 'dart:ui';

class Scribble {
  List<DrawPoint> points;

  Scribble(this.points);
}

class DrawPoint extends Offset {
  bool empty = false;

  DrawPoint(double dx, double dy) : super(dx, dy);

  DrawPoint.empty() : super(0, 0) {
    this.empty = true;
  }
}
