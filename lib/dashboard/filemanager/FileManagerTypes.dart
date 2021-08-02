import 'dart:ui' as ui;

import 'package:fluffy_board/whiteboard/DrawPoint.dart';

class Directory {
  String id, owner, parent, filename;
  int created;

  Directory(this.id, this.owner, this.parent, this.filename, this.created);

  Map toJson() {
    return {
      'id': id,
      'owner': owner,
      'parent': parent,
      'filename': filename,
      'created': created,
    };
  }
}

class Directories {
  List<Directory> list = [];

  Directories(this.list);

  toJSONEncodable() {
    return list.map((item) {
      return item.toJson();
    }).toList();
  }

  Directories.fromJson(List<dynamic> json) {
    for (Map<String, dynamic> row in json) {
      list.add(new Directory(row['id'], row['owner'], row['parent'],
          row['filename'], row['created']));
    }
  }

  Directories.fromOfflineJson(List<dynamic> json) {
    for (Map<dynamic, dynamic> row in json) {
      list.add(new Directory(row['id'], row['owner'], row['parent'],
          row['filename'], row['created']));
    }
  }
}

class Whiteboard {
  late String id, owner, parent, name, view_id, edit_id;
  late int created;

  Whiteboard(this.id, this.owner, this.parent, this.name, this.created,
      this.view_id, this.edit_id);
}

class Whiteboards {
  List<Whiteboard> list = [];

  Whiteboards(this.list);

  Whiteboards.fromJson(List<dynamic> json) {
    for (Map<String, dynamic> row in json) {
      list.add(new Whiteboard(row['id'], row['owner'], row['directory'],
          row['name'], row['created'], row['view_id'], row['edit_id']));
    }
  }
}

class ExtWhiteboard {
  String id, account, directory, name, original, permissionId;
  bool edit;

  ExtWhiteboard(this.id, this.account, this.directory, this.name, this.original,
      this.edit, this.permissionId);
}

class ExtWhiteboards {
  List<ExtWhiteboard> list = [];

  ExtWhiteboards(this.list);

  ExtWhiteboards.fromJson(List<dynamic> json) {
    for (Map<String, dynamic> row in json) {
      list.add(new ExtWhiteboard(row['id'], row['account'], row['directory'],
          row['name'], row['original'], row['edit'], row['permission_id']));
    }
  }
}

class OfflineWhiteboard {
  String uuid;
  String directory;
  String name;
  Uploads uploads;
  TextItems texts;
  Scribbles scribbles;
  Bookmarks bookmarks;
  ui.Offset offset;
  double scale;

  toJSONEncodable() {
    Map<String, dynamic> m = new Map();
    m['uuid'] = uuid;
    m['directory'] = directory;
    m['name'] = name;
    m['uploads'] = uploads.toJSONEncodable();
    m['texts'] = texts.toJSONEncodable();
    m['scribbles'] = scribbles.toJSONEncodable();
    m['bookmarks'] = bookmarks.toJSONEncodable();
    m['offset_dx'] = offset.dx;
    m['offset_dy'] = offset.dy;
    m['scale'] = scale;
    return m;
  }

  static Future<OfflineWhiteboard> fromJson(Map<String, dynamic> json) async {
    return new OfflineWhiteboard(
        json['uuid'],
        json['directory'],
        json['name'],
        json['uploads'] != null
            ? await Uploads.fromJson(json['uploads'])
            : new Uploads([]),
        json['texts'] != null
            ? TextItems.fromJson(json['texts'])
            : new TextItems([]),
        json['scribbles'] != null
            ? Scribbles.fromJson(json['scribbles'])
            : new Scribbles([]),
        json['bookmarks'] != null
            ? Bookmarks.fromJson(json['bookmarks'])
            : new Bookmarks([]),
      new ui.Offset(json['offset_dx'].toDouble(), json['offset_dy'].toDouble()),
      json['scale'].toDouble(),
    );
  }

  OfflineWhiteboard(this.uuid, this.directory, this.name, this.uploads,
      this.texts, this.scribbles, this.bookmarks, this.offset, this.scale);
}

class OfflineWhiteboards {
  List<OfflineWhiteboard> list = [];

  static Future<OfflineWhiteboards> fromJson(List<dynamic> json) async {
    OfflineWhiteboards offlineWhiteboards = new OfflineWhiteboards([]);
    for (dynamic entry in json) {
      offlineWhiteboards.list.add(await OfflineWhiteboard.fromJson(entry));
    }
    return offlineWhiteboards;
  }

  toJSONEncodable() {
    return list.map((item) {
      return item.toJSONEncodable();
    }).toList();
  }

  OfflineWhiteboards(this.list);
}

class CreateWhiteboardResponse {
  String id;
  String directory;

  CreateWhiteboardResponse.fromJson(Map<String, dynamic> json)
      : this.id = json['id'],
        this.directory = json['directory'];
}
