import 'dart:ui' as ui;
import 'package:uuid/uuid.dart';

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
      : uuid = json['uuid'] ?? Uuid().v4(),
        name = json['name'] ?? "Import Error",
        offset = new ui.Offset((json['offset_dx'] ?? 0).toDouble(), (json['offset_dy'] ?? 0).toDouble()),
        scale = (json['scale'] ?? 1).toDouble();

  Bookmark(this.uuid, this.name, this.offset, this.scale);

}

