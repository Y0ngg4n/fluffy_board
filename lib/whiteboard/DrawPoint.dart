import 'dart:typed_data';
import 'dart:ui';

import 'package:fluffy_board/whiteboard/WhiteboardView.dart';

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

  toJSONEncodable() {
    Map<String, dynamic> m = new Map();

    m['uuid'] = uuid;
    m['selected_figure_type_toolbar'] = selectedFigureTypeToolbar.index;
    m['stroke_width'] = strokeWidth;
    m['stroke_cap'] = strokeCap.index;
    m['color'] = color.toHex();
    m['points'] = points.map((e) => e.toJson());
    m['painting_style'] = paintingStyle;
    m['left_extremity'] = leftExtremity;
    m['right_extremity'] = rightExtremity;
    m['top_extremity'] = topExtremity;
    m['bottom_extremity'] = bottomExtremity;

    return m;
  }

  Scribble.fromJson(Map<String, dynamic> json)
      : uuid = json['uuid'],
        selectedFigureTypeToolbar = SelectedFigureTypeToolbar
            .values[json['selected_figure_type_toolbar']],
        strokeWidth = json['stroke_width'],
        strokeCap = StrokeCap.values[json['stroke_cap']],
        color = HexColor.fromHex(json['color']),
        points = json['points'],
        paintingStyle = PaintingStyle.values[json['painting_style']],
        leftExtremity = json['left_extremity'],
        rightExtremity = json['right_extremity'],
        topExtremity = json['top_extremity'],
        bottomExtremity = json['bottom_extremity'];

  Scribble(this.uuid, this.strokeWidth, this.strokeCap, this.color, this.points,
      this.selectedFigureTypeToolbar, this.paintingStyle);
}

class DrawPoint extends Offset {
  bool empty = false;

  DrawPoint(double dx, double dy) : super(dx, dy);

  DrawPoint.empty() : super(0, 0) {
    this.empty = true;
  }

  DrawPoint.of(Offset offset) : super(offset.dx, offset.dy);

  DrawPoint.fromJson(Map<String, dynamic> json) : super(json['dx'], json['dy']);

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

class Upload {
  String uuid;
  UploadType uploadType;
  Offset offset;

  Uint8List uint8List;
  Image? image;

  Upload(this.uuid, this.uploadType, this.uint8List, this.offset, this.image);
}

class TextItem {
  String uuid;
  bool editing;
  double strokeWidth;
  int maxWidth;
  int maxHeight;
  Color color;
  String text;
  Offset offset;

  TextItem(this.uuid, this.editing, this.strokeWidth, this.maxWidth,
      this.maxHeight, this.color, this.text, this.offset);
}
