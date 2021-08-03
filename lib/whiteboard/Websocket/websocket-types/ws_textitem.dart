import 'package:fluffy_board/whiteboard/Websocket/websocket-types/websocket_types.dart';

class WSTextItemAdd implements JsonWebSocketType{
  String uuid;
  double strokeWidth;
  int maxWidth;
  int maxHeight;
  String color;
  String content_text;
  double offset_dx;
  double offset_dy;
  double rotation;

  WSTextItemAdd.fromJson(Map<String, dynamic> json)
      : uuid = json['uuid'],
        strokeWidth = json['stroke_width'].toDouble(),
        maxWidth = json['max_width'],
        maxHeight = json['max_height'],
        color = json['color'],
        content_text = json['content_text'],
        offset_dx = json['offset_dx'].toDouble(),
        offset_dy = json['offset_dy'].toDouble(),
        rotation = json['rotation'].toDouble();

  Map toJson() {
    return {
      'uuid': uuid,
      'stroke_width': strokeWidth,
      'max_width': maxWidth,
      'max_height': maxHeight,
      'color': color,
      'content_text': content_text,
      'offset_dx': offset_dx,
      'offset_dy': offset_dy,
      'rotation': rotation
    };
  }

  WSTextItemAdd(
      this.uuid,
      this.strokeWidth,
      this.maxWidth,
      this.maxHeight,
      this.color,
      this.content_text,
      this.offset_dx,
      this.offset_dy,
      this.rotation);
}

class WSTextItemUpdate implements JsonWebSocketType{
  String uuid;
  double strokeWidth;
  int maxWidth;
  int maxHeight;
  String color;
  String content_text;
  double offset_dx;
  double offset_dy;
  double rotation;

  WSTextItemUpdate.fromJson(Map<String, dynamic> json)
      : uuid = json['uuid'],
        strokeWidth = json['stroke_width'].toDouble(),
        maxWidth = json['max_width'],
        maxHeight = json['max_height'],
        color = json['color'],
        content_text = json['content_text'],
        offset_dx = json['offset_dx'].toDouble(),
        offset_dy = json['offset_dy'].toDouble(),
        rotation = json['rotation'].toDouble();

  Map toJson() {
    return {
      'uuid': uuid,
      'stroke_width': strokeWidth,
      'max_width': maxWidth,
      'max_height': maxHeight,
      'color': color,
      'content_text': content_text,
      'offset_dx': offset_dx,
      'offset_dy': offset_dy,
      'rotation': rotation
    };
  }

  WSTextItemUpdate(
      this.uuid,
      this.strokeWidth,
      this.maxWidth,
      this.maxHeight,
      this.color,
      this.content_text,
      this.offset_dx,
      this.offset_dy,
      this.rotation);
}

class WSTextItemDelete implements JsonWebSocketType {
  String uuid;

  WSTextItemDelete.fromJson(Map<String, dynamic> json) : uuid = json['uuid'];

  Map toJson() {
    return {
      'uuid': uuid,
    };
  }

  WSTextItemDelete(this.uuid);
}

class DecodeGetTextItem implements DecodeGetJsonWebSocketType{
  String uuid;
  double strokeWidth;
  int maxHeight;
  int maxWidth;
  String color;
  String contentText;
  double offset_dx;
  double offset_dy;
  double rotation;

  DecodeGetTextItem.fromJson(Map<String, dynamic> json)
      : uuid = json['id'],
        strokeWidth = json['stroke_width'].toDouble(),
        maxHeight = json['max_height'],
        maxWidth = json['max_width'],
        color = json['color'],
        contentText = json['content_text'],
        offset_dx = json['offset_dx'].toDouble(),
        offset_dy = json['offset_dy'].toDouble(),
        rotation = json['rotation'].toDouble();
}

class DecodeGetTextItemList implements DecodeGetJsonWebSocketTypeList{
  static List<DecodeGetTextItem> fromJsonList(List<dynamic> jsonList) {
    List<DecodeGetTextItem> points = new List.empty(growable: true);
    for (Map<String, dynamic> json in jsonList) {
      points.add(new DecodeGetTextItem.fromJson(json));
    }
    return points;
  }
}
