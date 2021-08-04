import 'package:fluffy_board/whiteboard/websocket/websocket-types/websocket_types.dart';
import 'package:uuid/uuid.dart';

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
      : uuid = json['uuid'] ?? Uuid().v4(),
        strokeWidth = (json['stroke_width'] ?? 1).toDouble(),
        maxWidth = json['max_width'] ?? 500,
        maxHeight = json['max_height'] ?? 200,
        color = json['color'] ?? "#000000",
        contentText = json['content_text'] ?? "Import Error",
        offsetDx = (json['offset_dx'] ?? 0).toDouble(),
        offsetDy = (json['offset_dy'] ?? 0).toDouble(),
        rotation = (json['rotation'] ?? 0).toDouble();

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
      : uuid = json['uuid'] ?? Uuid().v4(),
        strokeWidth = (json['stroke_width'] ?? 1).toDouble(),
        maxWidth = (json['max_width'] ?? 500),
        maxHeight = (json['max_height'] ?? 200),
        color = (json['color'] ?? "#000000"),
        contentText = (json['content_text'] ?? "Import Error"),
        offsetDx = (json['offset_dx'] ?? 0).toDouble(),
        offsetDy = (json['offset_dy'] ?? 0).toDouble(),
        rotation = (json['rotation'] ?? 0).toDouble();

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
      : uuid = json['id'] ?? Uuid().v4(),
        strokeWidth = (json['stroke_width'] ?? 1).toDouble(),
        maxHeight = (json['max_height'] ?? 500),
        maxWidth = (json['max_width'] ?? 200),
        color = (json['color'] ?? "#000000"),
        contentText = (json['content_text'] ?? "Import Error"),
        offsetDx = (json['offset_dx'] ?? 0).toDouble(),
        offsetDy = (json['offset_dy'] ?? 0).toDouble(),
        rotation = (json['rotation'] ?? 0).toDouble();
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
