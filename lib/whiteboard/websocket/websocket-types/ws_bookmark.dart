import 'package:fluffy_board/whiteboard/websocket/websocket-types/websocket_types.dart';
import 'package:uuid/uuid.dart';

class WSBookmarkAdd implements JsonWebSocketType {
  String uuid;
  String name;
  double offsetDx;
  double offsetDy;
  double scale;

  WSBookmarkAdd.fromJson(Map<String, dynamic> json)
      : uuid = json['uuid'] ?? Uuid().v4(),
        name = json['name'] ?? "Import Error",
        offsetDx = (json['offset_dx'] ?? 0).toDouble(),
        offsetDy = (json['offset_dy'] ?? 0).toDouble(),
        scale = (json['scale'] ?? 1).toDouble();

  Map toJson() {
    return {
      'uuid': uuid,
      'name': name,
      'offset_dx': offsetDx,
      'offset_dy': offsetDy,
      'scale': scale,
    };
  }

  WSBookmarkAdd(
      this.uuid, this.name, this.offsetDx, this.offsetDy, this.scale);
}

class WSBookmarkUpdate implements JsonWebSocketType {
  String uuid;
  String name;
  double offsetDx;
  double offsetDy;
  double scale;

  WSBookmarkUpdate.fromJson(Map<String, dynamic> json)
      : uuid = json['uuid'] ?? Uuid().v4(),
        name = json['name'] ?? "Import Error",
        offsetDx = (json['offset_dx'] ?? 0).toDouble(),
        offsetDy = (json['offset_dy'] ?? 0).toDouble(),
        scale = (json['scale'] ?? 1).toDouble();

  Map toJson() {
    return {
      'uuid': uuid,
      'name': name,
      'offset_dx': offsetDx,
      'offset_dy': offsetDy,
      'scale': scale,
    };
  }

  WSBookmarkUpdate(
      this.uuid, this.name, this.offsetDx, this.offsetDy, this.scale);
}

class WSBookmarkDelete implements JsonWebSocketType{
  String uuid;

  WSBookmarkDelete.fromJson(Map<String, dynamic> json) : uuid = json['uuid'] ?? Uuid().v4();

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
  double offsetDx;
  double offsetDy;
  double scale;

  DecodeGetBookmark.fromJson(Map<String, dynamic> json)
      : uuid = json['id'] ?? Uuid().v4(),
        name = json['name'] ?? "Import Error",
        offsetDx = (json['offset_dx'] ?? 0).toDouble(),
        offsetDy = (json['offset_dy'] ?? 0).toDouble(),
        scale = (json['scale'] ?? 1).toDouble();
}

