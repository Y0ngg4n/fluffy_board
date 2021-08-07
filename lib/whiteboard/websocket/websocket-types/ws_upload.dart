import 'package:fluffy_board/whiteboard/websocket/websocket-types/websocket_types.dart';
import 'package:uuid/uuid.dart';

class WSUploadAdd implements JsonWebSocketType {
  String uuid;
  int uploadType;
  double offsetDx;
  double offsetDy;
  double rotation;
  List<int> imageData;

  WSUploadAdd.fromJson(Map<String, dynamic> json)
      : uuid = (json['uuid'] ?? Uuid().v4()),
        uploadType = (json['upload_type'] ?? 0),
        offsetDx = (json['offset_dx'] ?? 0).toDouble(),
        offsetDy = (json['offset_dy'] ?? 0).toDouble(),
        rotation = (json['rotation'] ?? 0).toDouble(),
        imageData = (json['image_data'] ?? []).cast<int>();

  Map toJson() {
    return {
      'uuid': uuid,
      'upload_type': uploadType,
      'offset_dx': offsetDx,
      'offset_dy': offsetDy,
      'rotation': rotation,
      'image_data': imageData,
    };
  }

  WSUploadAdd(this.uuid, this.uploadType, this.offsetDx, this.offsetDy,
      this.rotation, this.imageData);
}

class WSUploadUpdate implements JsonWebSocketType {
  String uuid;
  double offsetDx;
  double offsetDy;
  double rotation;

  WSUploadUpdate.fromJson(Map<String, dynamic> json)
      : uuid = (json['uuid'] ?? Uuid().v4()),
        offsetDx = (json['offset_dx'] ?? 0).toDouble(),
        offsetDy = (json['offset_dy'] ?? 0).toDouble(),
        rotation = (json['rotation'] ?? 0).toDouble();

  Map toJson() {
    return {
      'uuid': uuid,
      'offset_dx': offsetDx,
      'offset_dy': offsetDy,
      'rotation': rotation
    };
  }

  WSUploadUpdate(this.uuid, this.offsetDx, this.offsetDy, this.rotation);
}

class WSUploadImageDataUpdate implements JsonWebSocketType {
  String uuid;
  List<int> imageData;

  WSUploadImageDataUpdate.fromJson(Map<String, dynamic> json)
      : uuid = (json['uuid'] ?? Uuid().v4()),
        imageData = (json['image_data'] ?? []).cast<int>();

  Map toJson() {
    return {
      'uuid': uuid,
      'image_data': imageData,
    };
  }

  WSUploadImageDataUpdate(this.uuid, this.imageData);
}

class WSUploadDelete implements JsonWebSocketType {
  String uuid;

  WSUploadDelete.fromJson(Map<String, dynamic> json)
      : uuid = (json['uuid'] ?? Uuid().v4());

  Map toJson() {
    return {
      'uuid': uuid,
    };
  }

  WSUploadDelete(this.uuid);
}

class DecodeGetUpload implements DecodeGetJsonWebSocketType {
  String uuid;
  int uploadType;
  double offsetDx;
  double offsetDy;
  double rotation;

  List<int> imageData;

  DecodeGetUpload.fromJson(Map<String, dynamic> json)
      : uuid = json['id'] ?? Uuid().v4(),
        uploadType = json['upload_type'] ?? 0,
        offsetDx = (json['offset_dx'] ?? 0).toDouble(),
        offsetDy = (json['offset_dy'] ?? 0).toDouble(),
        rotation = (json['rotation'] ?? 0).toDouble(),
        imageData = (json['image_data'] ?? []).cast<int>();
}

class DecodeGetUploadList implements DecodeGetJsonWebSocketTypeList {
  static List<DecodeGetUpload> fromJsonList(List<dynamic> jsonList) {
    List<DecodeGetUpload> points = new List.empty(growable: true);
    for (Map<String, dynamic> json in jsonList) {
      points.add(new DecodeGetUpload.fromJson(json));
    }
    return points;
  }
}
