import 'package:fluffy_board/whiteboard/Websocket/websocket-types/websocket_types.dart';

class WSBookmarkAdd implements JsonWebSocketType {
  String uuid;
  String name;
  double offset_dx;
  double offset_dy;
  double scale;

  WSBookmarkAdd.fromJson(Map<String, dynamic> json)
      : uuid = json['uuid'],
        name = json['name'],
        offset_dx = json['offset_dx'].toDouble(),
        offset_dy = json['offset_dy'].toDouble(),
        scale = json['scale'].toDouble();

  Map toJson() {
    return {
      'uuid': uuid,
      'name': name,
      'offset_dx': offset_dx,
      'offset_dy': offset_dy,
      'scale': scale,
    };
  }

  WSBookmarkAdd(
      this.uuid, this.name, this.offset_dx, this.offset_dy, this.scale);
}

class WSBookmarkUpdate implements JsonWebSocketType {
  String uuid;
  String name;
  double offset_dx;
  double offset_dy;
  double scale;

  WSBookmarkUpdate.fromJson(Map<String, dynamic> json)
      : uuid = json['uuid'],
        name = json['name'],
        offset_dx = json['offset_dx'].toDouble(),
        offset_dy = json['offset_dy'].toDouble(),
        scale = json['scale'].toDouble();

  Map toJson() {
    return {
      'uuid': uuid,
      'name': name,
      'offset_dx': offset_dx,
      'offset_dy': offset_dy,
      'scale': scale,
    };
  }

  WSBookmarkUpdate(
      this.uuid, this.name, this.offset_dx, this.offset_dy, this.scale);
}

class WSBookmarkDelete  implements JsonWebSocketType{
  String uuid;

  WSBookmarkDelete.fromJson(Map<String, dynamic> json) : uuid = json['uuid'];

  Map toJson() {
    return {
      'uuid': uuid,
    };
  }

  WSBookmarkDelete(this.uuid);
}

class DecodeGetBookmarkList implements DecodeGetJsonWebSocketTypeList{
  static List<DecodeGetBookmark> fromJsonList(List<dynamic> jsonList) {
    List<DecodeGetBookmark> points = new List.empty(growable: true);
    for (Map<String, dynamic> json in jsonList) {
      points.add(new DecodeGetBookmark.fromJson(json));
    }
    return points;
  }
}

class DecodeGetBookmark implements DecodeGetJsonWebSocketType{
  String uuid;
  String name;
  double offset_dx;
  double offset_dy;
  double scale;

  DecodeGetBookmark.fromJson(Map<String, dynamic> json)
      : uuid = json['id'],
        name = json['name'],
        offset_dx = json['offset_dx'].toDouble(),
        offset_dy = json['offset_dy'].toDouble(),
        scale = json['scale'].toDouble();
}

