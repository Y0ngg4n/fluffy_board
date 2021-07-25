import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:fluffy_board/whiteboard/WhiteboardView.dart';
import 'package:flutter/material.dart';

import 'overlays/Toolbar/FigureToolbar.dart';
import 'package:uuid/uuid.dart';

class Scribbles {
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

class Scribble {
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
      : uuid = json['uuid'],
        selectedFigureTypeToolbar = SelectedFigureTypeToolbar
            .values[json['selected_figure_type_toolbar']],
        strokeWidth = json['stroke_width'],
        strokeCap = ui.StrokeCap.values[json['stroke_cap']],
        color = HexColor.fromHex(json['color']),
        points = DrawPoints.fromJson(json['points']).list,
        paintingStyle = ui.PaintingStyle.values[json['painting_style']],
        leftExtremity = json['left_extremity'],
        rightExtremity = json['right_extremity'],
        topExtremity = json['top_extremity'],
        bottomExtremity = json['bottom_extremity'];

  Scribble(this.uuid, this.strokeWidth, this.strokeCap, this.color, this.points,
      this.selectedFigureTypeToolbar, this.paintingStyle);
}

class DrawPoints {
  List<DrawPoint> list = [];

  toJSONEncodable() {
    return list.map((item) {
      return item.toJson();
    }).toList();
  }

  DrawPoints.fromJson(List<dynamic> json) {
    for (dynamic entry in json) {
      list.add(DrawPoint.fromJson(entry.cast<String, dynamic>()));
    }
  }

  DrawPoints(this.list);
}

class DrawPoint extends ui.Offset {
  bool empty = false;

  DrawPoint(double dx, double dy) : super(dx, dy);

  DrawPoint.empty() : super(0, 0) {
    this.empty = true;
  }

  DrawPoint.of(ui.Offset offset) : super(offset.dx, offset.dy);

  DrawPoint.fromJson(Map<String, dynamic> json)
      : super(json['dx'].toDouble(), json['dy'].toDouble());

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

class Uploads {
  List<Upload> list = [];

  toJSONEncodable() {
    print(list.map((item) {
      return item.toJson();
    }).toList());
    return list.map((item) {
      return item.toJson();
    }).toList();
  }

  static Future<Uploads> fromJson(List<dynamic> json) async {
    Uploads uploads = new Uploads([]);
    for (dynamic entry in json) {
      Upload upload = Upload.fromJson(entry.cast<String, dynamic>());
      final ui.Codec codec = await PaintingBinding.instance!
          .instantiateImageCodec(upload.uint8List);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      upload.image = frameInfo.image;
      uploads.list.add(upload);
    }
    return uploads;
  }

  Uploads(this.list);
}

class Upload {
  String uuid;
  UploadType uploadType;
  ui.Offset offset;

  Uint8List uint8List;
  ui.Image? image;

  Upload.fromJson(Map<String, dynamic> json)
      : uuid = json['uuid'],
        uploadType = UploadType.values[json['upload_type']],
        offset = new ui.Offset(json['offset_dx'], json['offset_dy']),
        uint8List = Uint8List.fromList(json['uint8list'].cast<int>()),
        image = null;

  Map toJson() {
    List<int> list = uint8List.toList();
    return {
      'uuid': uuid,
      'upload_type': uploadType.index,
      'offset_dx': offset.dx,
      'offset_dy': offset.dy,
      'uint8list': list
    };
  }

  Upload(this.uuid, this.uploadType, this.uint8List, this.offset, this.image);
}

class TextItems {
  List<TextItem> list = [];

  toJSONEncodable() {
    return list.map((item) {
      return item.toJSONEncodable();
    }).toList();
  }

  TextItems.fromJson(List<dynamic> json) {
    for (dynamic entry in json) {
      list.add(TextItem.fromJson(entry));
    }
  }

  TextItems(this.list);
}

class TextItem {
  String uuid;
  bool editing;
  double strokeWidth;
  int maxWidth;
  int maxHeight;
  ui.Color color;
  String text;
  ui.Offset offset;
  double rotation;

  toJSONEncodable() {
    Map<String, dynamic> m = new Map();
    m['uuid'] = uuid;
    m['stroke_width'] = strokeWidth;
    m['max_width'] = maxWidth;
    m['max_height'] = maxHeight;
    m['color'] = color.toHex();
    m['text'] = text;
    m['offset_dx'] = offset.dx;
    m['offset_dy'] = offset.dy;
    m['rotation'] = rotation;

    return m;
  }

  TextItem.fromJson(Map<String, dynamic> json)
      : uuid = json['uuid'],
        editing = false,
        strokeWidth = json['stroke_width'],
        maxWidth = json['max_width'],
        maxHeight = json['max_height'],
        color = HexColor.fromHex(json['color']),
        text = json['text'],
        offset = new ui.Offset(json['offset_dx'], json['offset_dy']),
        rotation = json['rotation'];

  TextItem(this.uuid, this.editing, this.strokeWidth, this.maxWidth,
      this.maxHeight, this.color, this.text, this.offset, this.rotation);
}

class Bookmarks {
  List<Bookmark> list = [];

  toJSONEncodable() {
    return list.map((item) {
      return item.toJSONEncodable();
    }).toList();
  }

  Bookmarks.fromJson(List<dynamic> json) {
    for (dynamic entry in json) {
      list.add(Bookmark.fromJson(entry));
    }
  }

  Bookmarks(this.list);
}

class Bookmark {
  String uuid;
  String name;
  ui.Offset offset;
  double scale;

  toJSONEncodable() {
    Map<String, dynamic> m = new Map();
    m['uuid'] = uuid;
    m['name'] = name;
    m['offset_dx'] = offset.dx;
    m['offset_dy'] = offset.dy;
    m['scale'] = scale;

    return m;
  }

  Bookmark.fromJson(Map<String, dynamic> json)
      : uuid = json['uuid'],
        name = json['name'],
        offset = new ui.Offset(json['offset_dx'].toDouble(), json['offset_dy'].toDouble()),
        scale = json['scale'].toDouble();

  Bookmark(this.uuid, this.name, this.offset, this.scale);

}

