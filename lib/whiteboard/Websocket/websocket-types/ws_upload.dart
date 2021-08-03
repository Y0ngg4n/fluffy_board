import 'package:fluffy_board/whiteboard/Websocket/websocket-types/websocket_types.dart';

class WSUploadAdd implements JsonWebSocketType{
  String uuid;
  int uploadType;
  double offset_dx;
  double offset_dy;
  List<int> imageData;

  WSUploadAdd.fromJson(Map<String, dynamic> json)
      : uuid = json['uuid'],
        uploadType = json['upload_type'],
        offset_dx = json['offset_dx'].toDouble(),
        offset_dy = json['offset_dy'].toDouble(),
        imageData = json['image_data'].cast<int>();

  Map toJson() {
    return {
      'uuid': uuid,
      'upload_type': uploadType,
      'offset_dx': offset_dx,
      'offset_dy': offset_dy,
      'image_data': imageData,
    };
  }

  WSUploadAdd(this.uuid, this.uploadType, this.offset_dx, this.offset_dy,
      this.imageData);
}

class WSUploadUpdate implements JsonWebSocketType{
  String uuid;
  double offset_dx;
  double offset_dy;

  WSUploadUpdate.fromJson(Map<String, dynamic> json)
      : uuid = json['uuid'],
        offset_dx = json['offset_dx'].toDouble(),
        offset_dy = json['offset_dy'].toDouble();

  Map toJson() {
    return {
      'uuid': uuid,
      'offset_dx': offset_dx,
      'offset_dy': offset_dy,
    };
  }

  WSUploadUpdate(this.uuid, this.offset_dx, this.offset_dy);
}

class WSUploadImageDataUpdate implements JsonWebSocketType{
  String uuid;
  List<int> imageData;

  WSUploadImageDataUpdate.fromJson(Map<String, dynamic> json)
      : uuid = json['uuid'],
        imageData = json['image_data'].cast<int>();

  Map toJson() {
    return {
      'uuid': uuid,
      'image_data': imageData,
    };
  }

  WSUploadImageDataUpdate(this.uuid, this.imageData);
}

class WSUploadDelete implements JsonWebSocketType{
  String uuid;

  WSUploadDelete.fromJson(Map<String, dynamic> json) : uuid = json['uuid'];

  Map toJson() {
    return {
      'uuid': uuid,
    };
  }

  WSUploadDelete(this.uuid);
}

class DecodeGetUpload implements DecodeGetJsonWebSocketType{
  String uuid;
  int uploadType;
  double offset_dx;
  double offset_dy;

  List<int> imageData;

  DecodeGetUpload.fromJson(Map<String, dynamic> json)
      : uuid = json['id'],
        uploadType = json['upload_type'],
        offset_dx = json['offset_dx'].toDouble(),
        offset_dy = json['offset_dy'].toDouble(),
        imageData = json['image_data'].cast<int>();
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
