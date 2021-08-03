import 'package:fluffy_board/whiteboard/Websocket/websocket-types/websocket_types.dart';

class WSTextItemAdd implements JsonWebSocketType{
  String uuid;
  double strokeWidth;
  int maxWidth;
  int maxHeight;
  String color;
  String contentText;
  double offsetDx;
  double offsetDy;
  double rotation;

  WSTextItemAdd.fromJson(Map<String, dynamic> json)
      : uuid = json['uuid'],
        strokeWidth = json['stroke_width'].toDouble(),
        maxWidth = json['max_width'],
        maxHeight = json['max_height'],
        color = json['color'],
        contentText = json['content_text'],
        offsetDx = json['offset_dx'].toDouble(),
        offsetDy = json['offset_dy'].toDouble(),
        rotation = json['rotation'].toDouble();

  Map toJson() {
    return {
      'uuid': uuid,
      'stroke_width': strokeWidth,
      'max_width': maxWidth,
      'max_height': maxHeight,
      'color': color,
      'content_text': contentText,
      'offset_dx': offsetDx,
      'offset_dy': offsetDy,
      'rotation': rotation
    };
  }

  WSTextItemAdd(
      this.uuid,
      this.strokeWidth,
      this.maxWidth,
      this.maxHeight,
      this.color,
      this.contentText,
      this.offsetDx,
      this.offsetDy,
      this.rotation);
}

class WSTextItemUpdate implements JsonWebSocketType{
  String uuid;
  double strokeWidth;
  int maxWidth;
  int maxHeight;
  String color;
  String contentText;
  double offsetDx;
  double offsetDy;
  double rotation;

  WSTextItemUpdate.fromJson(Map<String, dynamic> json)
      : uuid = json['uuid'],
        strokeWidth = json['stroke_width'].toDouble(),
        maxWidth = json['max_width'],
        maxHeight = json['max_height'],
        color = json['color'],
        contentText = json['content_text'],
        offsetDx = json['offset_dx'].toDouble(),
        offsetDy = json['offset_dy'].toDouble(),
        rotation = json['rotation'].toDouble();

  Map toJson() {
    return {
      'uuid': uuid,
      'stroke_width': strokeWidth,
      'max_width': maxWidth,
      'max_height': maxHeight,
      'color': color,
      'content_text': contentText,
      'offset_dx': offsetDx,
      'offset_dy': offsetDy,
      'rotation': rotation
    };
  }

  WSTextItemUpdate(
      this.uuid,
      this.strokeWidth,
      this.maxWidth,
      this.maxHeight,
      this.color,
      this.contentText,
      this.offsetDx,
      this.offsetDy,
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
  double offsetDx;
  double offsetDy;
  double rotation;

  DecodeGetTextItem.fromJson(Map<String, dynamic> json)
      : uuid = json['id'],
        strokeWidth = json['stroke_width'].toDouble(),
        maxHeight = json['max_height'],
        maxWidth = json['max_width'],
        color = json['color'],
        contentText = json['content_text'],
        offsetDx = json['offset_dx'].toDouble(),
        offsetDy = json['offset_dy'].toDouble(),
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
