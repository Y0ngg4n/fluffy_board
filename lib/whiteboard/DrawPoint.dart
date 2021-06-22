import 'dart:typed_data';
import 'dart:ui';

import 'overlays/Toolbar/FigureToolbar.dart';
import 'package:uuid/uuid.dart';

class Scribble {
  String uuid;
  SelectedFigureTypeToolbar selectedFigureTypeToolbar;
  double strokeWidth;
  StrokeCap strokeCap;
  Color color;
  List<DrawPoint> points;
  PaintingStyle paintingStyle;
  double leftExtremity = 0,
      topExtremity = 0,
      rightExtremity = 0,
      bottomExtremity = 0;

  Scribble(this.uuid, this.strokeWidth, this.strokeCap, this.color, this.points, this.selectedFigureTypeToolbar, this.paintingStyle);
}

class DrawPoint extends Offset {
  bool empty = false;

  DrawPoint(double dx, double dy) : super(dx, dy);

  DrawPoint.empty() : super(0, 0) {
    this.empty = true;
  }

  DrawPoint.of(Offset offset) : super(offset.dx, offset.dy);

  DrawPoint.fromJson(Map<String, dynamic> json): super(json['dx'], json['dy']);

  Map toJson() {
    return {
      'dx': dx,
      'dy': dy,
    };
  }
}

enum UploadType {
  Image,
  PDF,
}

class Upload{
  UploadType uploadType;
  Offset offset;

  Uint8List uint8List;
  Image? image;

  Upload(this.uploadType, this.uint8List, this.offset, this.image);
}

class TextItem{
  bool editing;
  double strokeWidth;
  Color color;
  String text;
  Offset offset;

  TextItem(this.editing, this.strokeWidth, this.color, this.text, this.offset);
}