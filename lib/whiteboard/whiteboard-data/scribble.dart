import 'dart:ui' as ui;
import 'package:fluffy_board/whiteboard/whiteboard_view.dart';
import '../overlays/toolbar/figure_toolbar.dart';
import 'draw_point.dart';
import 'json_encodable.dart';
import 'package:uuid/uuid.dart';


class Scribbles implements JsonEncodable{
  List<Scribble> list = [];

  toJSONEncodable() {
    return list.map((item) {
      return item.toJSONEncodable();
    }).toList();
  }

  Scribbles.fromJson(List<dynamic> json) {
    for (dynamic entry in json) {
      list.add(Scribble.fromJson(entry));
    }
  }

  Scribbles(this.list);
}

class Scribble implements JsonEncodable{
  String uuid;
  SelectedFigureTypeToolbar selectedFigureTypeToolbar;
  double strokeWidth;
  ui.StrokeCap strokeCap;
  ui.Color color;
  List<DrawPoint> points;
  ui.PaintingStyle paintingStyle;
  double leftExtremity = 0,
      topExtremity = 0,
      rightExtremity = 0,
      bottomExtremity = 0;
  ui.Image? backedScribble;

  toJSONEncodable() {
    Map<String, dynamic> m = new Map();
    m['uuid'] = uuid;
    m['selected_figure_type_toolbar'] = selectedFigureTypeToolbar.index;
    m['stroke_width'] = strokeWidth;
    m['stroke_cap'] = strokeCap.index;
    m['color'] = color.toHex();
    m['points'] = new DrawPoints(points).toJSONEncodable();
    m['painting_style'] = paintingStyle.index;
    m['left_extremity'] = leftExtremity;
    m['right_extremity'] = rightExtremity;
    m['top_extremity'] = topExtremity;
    m['bottom_extremity'] = bottomExtremity;

    return m;
  }

  Scribble.fromJson(Map<String, dynamic> json)
      : uuid = json['uuid'] ?? Uuid().v4(),
        selectedFigureTypeToolbar = SelectedFigureTypeToolbar
            .values[json['selected_figure_type_toolbar'] ?? 0],
        strokeWidth = json['stroke_width'] ?? 1,
        strokeCap = ui.StrokeCap.values[json['stroke_cap'] ?? 0],
        color = HexColor.fromHex(json['color'] ?? "#000000"),
        points = DrawPoints.fromJson(json['points'] ?? []).list,
        paintingStyle = ui.PaintingStyle.values[json['painting_style'] ?? 0],
        leftExtremity = json['left_extremity'] ?? 0,
        rightExtremity = json['right_extremity'] ?? 0,
        topExtremity = json['top_extremity'] ?? 0,
        bottomExtremity = json['bottom_extremity'] ?? 0;

  Scribble(this.uuid, this.strokeWidth, this.strokeCap, this.color, this.points,
      this.selectedFigureTypeToolbar, this.paintingStyle);
}