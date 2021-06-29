import 'dart:convert';
import 'dart:typed_data';

import 'package:fluffy_board/dashboard/filemanager/RenameFolder.dart';
import 'package:fluffy_board/dashboard/filemanager/RenameWhiteboard.dart';
import 'package:fluffy_board/dashboard/filemanager/ShareWhiteboard.dart';
import 'package:fluffy_board/whiteboard/DrawPoint.dart';
import 'package:fluffy_board/whiteboard/Websocket/WebsocketTypes.dart';
import 'package:fluffy_board/whiteboard/WhiteboardView.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar/FigureToolbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:localstorage/localstorage.dart';
import '../ActionButtons.dart';
import 'package:uuid/uuid.dart';

class Directory {
  late String id, owner, parent, filename;
  late int created;

  Directory(this.id, this.owner, this.parent, this.filename, this.created);
}

class Directories {
  List<Directory> list = [];

  Directories(this.list);

  Directories.fromJson(List<dynamic> json) {
    for (Map<String, dynamic> row in json) {
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
  String name;
  Uploads uploads;
  TextItems texts;
  Scribbles scribbles;

  toJSONEncodable() {
    Map<String, dynamic> m = new Map();

    m['uuid'] = uuid;
    m['name'] = name;
    m['uploads'] = uploads.toJSONEncodable();
    m['texts'] = texts.toJSONEncodable();
    m['scribbles'] = scribbles.toJSONEncodable();
    return m;
  }

  OfflineWhiteboard.fromJson(Map<String, dynamic> json)
      : uuid = json['uuid'],
        name = json['name'],
        uploads = json['uploads'] != null
            ? Uploads.fromJson(json['uploads'])
            : new Uploads([]),
        texts = json['texts'] != null
            ? TextItems.fromJson(json['texts'])
            : new TextItems([]),
        scribbles = json['scribbles'] != null
            ? Scribbles.fromJson(json['scribbles'])
            : new Scribbles([]);

  OfflineWhiteboard(
      this.uuid, this.name, this.uploads, this.texts, this.scribbles);
}

class OfflineWhiteboards {
  List<OfflineWhiteboard> list = [];

  OfflineWhiteboards.fromJson(List<dynamic> json) {
    for (dynamic entry in json) {
      list.add(OfflineWhiteboard.fromJson(entry));
    }
  }

  toJSONEncodable() {
    return list.map((item) {
      return item.toJSONEncodable();
    }).toList();
  }

  OfflineWhiteboards(this.list);
}

class FileManager extends StatefulWidget {
  String auth_token;
  String username;

  FileManager(this.auth_token, this.username);

  @override
  _FileManagerState createState() => _FileManagerState();
}

class _FileManagerState extends State<FileManager> {
  Directories directories = new Directories([]);
  Whiteboards whiteboards = new Whiteboards([]);
  ExtWhiteboards extWhiteboards = new ExtWhiteboards([]);
  OfflineWhiteboards offlineWhiteboards = new OfflineWhiteboards([]);
  Set<String> offlineWhiteboardIds = Set.of([]);
  String currentDirectory = "";
  List<Directory> currentDirectoryPath = [];
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  double font_size = 25;
  double file_icon_size = 50;
  final LocalStorage fileManagerStorageIndex =
      new LocalStorage('filemanager-index');
  final LocalStorage fileManagerStorage = new LocalStorage('filemanager');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> directoryAndWhiteboardButtons = [];
    List<BreadCrumbItem> breadCrumbItems = [];
    _mapDirectories(directoryAndWhiteboardButtons);
    _mapBreadCrumbs(breadCrumbItems);
    _mapWhiteboards(directoryAndWhiteboardButtons);
    _mapExtWhiteboards(directoryAndWhiteboardButtons);
    _mapOfflineWhiteboards(directoryAndWhiteboardButtons);

    return Container(
        child: Column(children: [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          children: [
            BreadCrumb(
              items: breadCrumbItems,
              divider: Icon(Icons.chevron_right),
              overflow: WrapOverflow(
                keepLastDivider: false,
                direction: Axis.horizontal,
              ),
            ),
            ActionButtons(
                widget.auth_token, currentDirectory, _refreshController),
          ],
        ),
      ),
      Expanded(
          child: SmartRefresher(
              enablePullDown: true,
              enablePullUp: false,
              controller: _refreshController,
              onRefresh: _getDirectoriesAndWhiteboards,
              child: GridView.extent(
                maxCrossAxisExtent: 100,
                children: directoryAndWhiteboardButtons,
              )))
    ]));
  }

  _mapDirectories(directoryButtons) {
    for (Directory directory in directories.list) {
      directoryButtons.add(Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                children: [
                  InkWell(
                    child:
                        Icon(Icons.folder_open_outlined, size: file_icon_size),
                    onTap: () {
                      setState(() {
                        currentDirectory = directory.id;
                        currentDirectoryPath.add(directory);
                      });
                      _refreshController.requestRefresh();
                    },
                  ),
                  Text(
                    directory.filename,
                    // style: TextStyle(fontSize: file_font_size),
                  )
                ],
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(child: Text("Rename Folder"), value: 0),
                  PopupMenuItem(child: Text("Delete Folder"), value: 1),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 0:
                      Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) => RenameFolder(
                                widget.auth_token,
                                directory.id,
                                currentDirectory,
                                directory.filename,
                                _refreshController),
                          ));
                      break;
                    case 1:
                      _deleteFolderDialog(context, directory);
                      break;
                  }
                },
              )
            ],
          ),
        ],
      ));
    }
  }

  _mapBreadCrumbs(breadCrumbItems) {
    breadCrumbItems.add(BreadCrumbItem(
        content: Icon(
          Icons.home,
          size: font_size,
        ),
        onTap: () {
          setState(() {
            currentDirectory = "";
            currentDirectoryPath.clear();
          });
          _refreshController.requestRefresh();
        }));
    for (int i = 0; i < currentDirectoryPath.length; i++) {
      String filename = currentDirectoryPath[i].filename;
      String uuid = currentDirectoryPath[i].id;
      breadCrumbItems.add(BreadCrumbItem(
          content: Text(filename, style: TextStyle(fontSize: font_size)),
          onTap: () {
            setState(() {
              currentDirectory = uuid;
            });
            currentDirectoryPath.removeRange(
                i + 1, currentDirectoryPath.length);
            _refreshController.requestRefresh();
          }));
    }
  }

  _mapWhiteboards(whiteboardButtons) {
    for (Whiteboard whiteboard in whiteboards.list) {
      whiteboardButtons.add(Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                children: [
                  InkWell(
                    child: Icon(Icons.assignment, size: file_icon_size),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                              builder: (BuildContext context) => WhiteboardView(
                                  whiteboard, null, null, widget.auth_token)));
                    },
                  ),
                  Text(
                    whiteboard.name,
                  )
                ],
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(child: Text("Rename Whiteboard"), value: 0),
                  PopupMenuItem(child: Text("Delete Whiteboard"), value: 1),
                  PopupMenuItem(child: Text("Share Whiteboard"), value: 2),
                  PopupMenuItem(child: Text("Download Whiteboard"), value: 3),
                ],
                onSelected: (value) async {
                  switch (value) {
                    case 0:
                      Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) => RenameWhiteboard(
                                widget.auth_token,
                                whiteboard.id,
                                currentDirectory,
                                whiteboard.name,
                                _refreshController),
                          ));
                      break;
                    case 1:
                      _deleteWhiteboardDialog(context, whiteboard);
                      break;
                    case 2:
                      Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) => ShareWhiteboard(
                                widget.auth_token,
                                widget.username,
                                whiteboard.id,
                                whiteboard.name,
                                currentDirectory,
                                whiteboard.view_id,
                                whiteboard.edit_id,
                                _refreshController),
                          ));
                      break;
                    case 3:
                      OfflineWhiteboard offlineWhiteboard =
                          new OfflineWhiteboard(
                              whiteboard.id,
                              whiteboard.name,
                              await _getUploads(
                                  whiteboard.id, whiteboard.edit_id),
                              await _getTextItems(
                                  whiteboard.id, whiteboard.edit_id),
                              await _getScribbles(
                                  whiteboard.id, whiteboard.edit_id));
                      offlineWhiteboards.list.add(offlineWhiteboard);
                      fileManagerStorage.setItem(
                          "offline_whiteboard-" + offlineWhiteboard.uuid,
                          offlineWhiteboard.toJSONEncodable());
                      for (OfflineWhiteboard offWhi
                          in offlineWhiteboards.list) {
                        offlineWhiteboardIds.add(offWhi.uuid);
                      }
                      fileManagerStorageIndex.setItem(
                          "indexes", jsonEncode(offlineWhiteboardIds.toList()));
                      _refreshController.requestRefresh();
                      break;
                  }
                },
              )
            ],
          ),
        ],
      ));
    }
  }

  _mapExtWhiteboards(whiteboardButtons) {
    for (ExtWhiteboard whiteboard in extWhiteboards.list) {
      whiteboardButtons.add(Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                children: [
                  InkWell(
                    child: Icon(Icons.assignment_ind, size: file_icon_size),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                              builder: (BuildContext context) => WhiteboardView(
                                  null, whiteboard, null, widget.auth_token)));
                    },
                  ),
                  Text(
                    whiteboard.name,
                    // style: TextStyle(fontSize: file_font_size),
                  ),
                ],
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(child: Text("Delete Whiteboard"), value: 0),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 0:
                      _deleteExtWhiteboardDialog(context, whiteboard);
                      break;
                  }
                },
              )
            ],
          ),
        ],
      ));
    }
  }

  _mapOfflineWhiteboards(whiteboardButtons) {
    for (OfflineWhiteboard whiteboard in offlineWhiteboards.list) {
      whiteboardButtons.add(Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                children: [
                  InkWell(
                    child: Icon(Icons.download_for_offline_outlined,
                        size: file_icon_size),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                              builder: (BuildContext context) => WhiteboardView(
                                  null, null, whiteboard, widget.auth_token)));
                    },
                  ),
                  Text(whiteboard.name
                      // style: TextStyle(fontSize: file_font_size),
                      ),
                ],
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(child: Text("Delete Whiteboard"), value: 0),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 0:
                      _deleteOfflineWhiteboardDialog(context, whiteboard);
                      break;
                  }
                },
              )
            ],
          ),
        ],
      ));
    }
  }

  _deleteFolderDialog(BuildContext context, Directory directory) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text('Please Confirm'),
            content: Text('Are you sure to delete the folder?'),
            actions: [
              TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    http.Response deleteResponse = await http.post(
                        Uri.parse(dotenv.env['REST_API_URL']! +
                            "/filemanager/directory/delete"),
                        headers: {
                          "content-type": "application/json",
                          "accept": "application/json",
                          "charset": "utf-8",
                          'Authorization': 'Bearer ' + widget.auth_token,
                        },
                        body: jsonEncode({
                          "id": directory.id,
                        }));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Trying to delete Folder"),
                    ));
                    if (deleteResponse.statusCode != 200) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Error while deleting Folder!"),
                          backgroundColor: Colors.red));
                    }
                    _refreshController.requestRefresh();
                  },
                  child: Text('Yes')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('No'))
            ],
          );
        });
  }

  _deleteWhiteboardDialog(BuildContext context, Whiteboard whiteboard) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text('Please Confirm'),
            content: Text('Are you sure to delete the Whiteboard?'),
            actions: [
              TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    http.Response deleteResponse = await http.post(
                        Uri.parse(dotenv.env['REST_API_URL']! +
                            "/filemanager/whiteboard/delete"),
                        headers: {
                          "content-type": "application/json",
                          "accept": "application/json",
                          "charset": "utf-8",
                          'Authorization': 'Bearer ' + widget.auth_token,
                        },
                        body: jsonEncode({
                          "id": whiteboard.id,
                        }));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Trying to delete Whiteboard ..."),
                    ));
                    if (deleteResponse.statusCode != 200) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Error while deleting Whiteboard!"),
                          backgroundColor: Colors.red));
                    }
                    _refreshController.requestRefresh();
                  },
                  child: Text('Yes')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('No'))
            ],
          );
        });
  }

  _deleteExtWhiteboardDialog(BuildContext context, ExtWhiteboard whiteboard) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text('Please Confirm'),
            content: Text('Are you sure to delete the Whiteboard?'),
            actions: [
              TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    http.Response deleteResponse = await http.post(
                        Uri.parse(dotenv.env['REST_API_URL']! +
                            "/filemanager-ext/whiteboard/delete"),
                        headers: {
                          "content-type": "application/json",
                          "accept": "application/json",
                          "charset": "utf-8",
                          'Authorization': 'Bearer ' + widget.auth_token,
                        },
                        body: jsonEncode({
                          "id": whiteboard.id,
                        }));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Trying to delete Whiteboard ..."),
                    ));
                    if (deleteResponse.statusCode != 200) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Error while deleting Whiteboard!"),
                          backgroundColor: Colors.red));
                    }
                    _refreshController.requestRefresh();
                  },
                  child: Text('Yes')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('No'))
            ],
          );
        });
  }

  _deleteOfflineWhiteboardDialog(
      BuildContext context, OfflineWhiteboard whiteboard) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text('Please Confirm'),
            content: Text('Are you sure to delete the Whiteboard?'),
            actions: [
              TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    fileManagerStorage
                        .deleteItem("offline_whiteboard-" + whiteboard.uuid);
                    offlineWhiteboardIds.remove(whiteboard.uuid);
                    fileManagerStorageIndex.setItem(
                        "indexes", jsonEncode(offlineWhiteboardIds.toList()));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Trying to delete Whiteboard ..."),
                    ));
                    _refreshController.requestRefresh();
                  },
                  child: Text('Yes')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('No'))
            ],
          );
        });
  }

  Future<void> _getDirectoriesAndWhiteboards() async {
    http.Response dirResponse = await http.post(
        Uri.parse(dotenv.env['REST_API_URL']! + "/filemanager/directory/get"),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          "charset": "utf-8",
          'Authorization': 'Bearer ' + widget.auth_token,
        },
        body: jsonEncode({
          "parent": currentDirectory,
        }));
    http.Response wbResponse = await http.post(
        Uri.parse(dotenv.env['REST_API_URL']! + "/filemanager/whiteboard/get"),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          "charset": "utf-8",
          'Authorization': 'Bearer ' + widget.auth_token,
        },
        body: jsonEncode({
          "directory": currentDirectory,
        }));
    http.Response wbExtResponse = await http.post(
        Uri.parse(
            dotenv.env['REST_API_URL']! + "/filemanager-ext/whiteboard/get"),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          "charset": "utf-8",
          'Authorization': 'Bearer ' + widget.auth_token,
        },
        body: jsonEncode({
          "directory": currentDirectory,
        }));
    Directories directories =
        Directories.fromJson(jsonDecode(utf8.decode((dirResponse.bodyBytes))));
    Whiteboards whiteboards =
        Whiteboards.fromJson(jsonDecode(utf8.decode((wbResponse.bodyBytes))));
    print(utf8.decode((wbExtResponse.bodyBytes)));
    ExtWhiteboards extWhiteboards = ExtWhiteboards.fromJson(
        jsonDecode(utf8.decode((wbExtResponse.bodyBytes))));
    _getOfflineWhiteboards();
    setState(() {
      this.directories = directories;
      this.whiteboards = whiteboards;
      this.extWhiteboards = extWhiteboards;
    });
    if (dirResponse.statusCode == 200 &&
        wbResponse.statusCode == 200 &&
        wbExtResponse.statusCode == 200)
      _refreshController.refreshCompleted();
    else
      _refreshController.refreshFailed();
  }

  _getOfflineWhiteboards() {
    setState(() {
      this.offlineWhiteboardIds = Set.of(
          jsonDecode(fileManagerStorageIndex.getItem("indexes") ?? [])
              .cast<String>());
      print(offlineWhiteboardIds);
      List<OfflineWhiteboard> offlineWhiteboards = List.empty(growable: true);
      for (String id in offlineWhiteboardIds) {
        Map<String, dynamic>? json = fileManagerStorage.getItem("offline_whiteboard-" + id);
        if(json != null){
          offlineWhiteboards.add(OfflineWhiteboard.fromJson(json));
        }

      }
      setState(() {
        this.offlineWhiteboards = new OfflineWhiteboards(offlineWhiteboards);
      });
    });
  }

  Future<Scribbles> _getScribbles(
      String whiteboard, String permissionId) async {
    http.Response scribbleResponse = await http.post(
        Uri.parse(dotenv.env['REST_API_URL']! + "/whiteboard/scribble/get"),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          'Authorization': 'Bearer ' + widget.auth_token,
        },
        body: jsonEncode(
            {"whiteboard": whiteboard, "permission_id": permissionId}));
    List<Scribble> scribbles = new List.empty(growable: true);
    if (scribbleResponse.statusCode == 200) {
      List<DecodeGetScribble> decodedScribbles =
          DecodeGetScribbleList.fromJsonList(jsonDecode(scribbleResponse.body));
      setState(() {
        for (DecodeGetScribble decodeGetScribble in decodedScribbles) {
          scribbles.add(new Scribble(
              decodeGetScribble.uuid,
              decodeGetScribble.strokeWidth,
              StrokeCap.values[decodeGetScribble.strokeCap],
              HexColor.fromHex(decodeGetScribble.color),
              decodeGetScribble.points,
              SelectedFigureTypeToolbar
                  .values[decodeGetScribble.selectedFigureTypeToolbar],
              PaintingStyle.values[decodeGetScribble.paintingStyle]));
        }
      });
    }
    return new Scribbles(scribbles);
  }

  Future<Uploads> _getUploads(String whiteboard, String permissionId) async {
    http.Response uploadResponse = await http.post(
        Uri.parse(dotenv.env['REST_API_URL']! + "/whiteboard/upload/get"),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          'Authorization': 'Bearer ' + widget.auth_token,
        },
        body: jsonEncode(
            {"whiteboard": whiteboard, "permission_id": permissionId}));
    List<Upload> uploads = new List.empty(growable: true);
    if (uploadResponse.statusCode == 200) {
      List<DecodeGetUpload> decodedUploads =
          DecodeGetUploadList.fromJsonList(jsonDecode(uploadResponse.body));
      setState(() {
        for (DecodeGetUpload decodeGetUpload in decodedUploads) {
          Uint8List uint8list = Uint8List.fromList(decodeGetUpload.imageData);
          ui.decodeImageFromList(uint8list, (image) {
            uploads.add(new Upload(
                decodeGetUpload.uuid,
                UploadType.values[decodeGetUpload.uploadType],
                uint8list,
                new Offset(
                    decodeGetUpload.offset_dx, decodeGetUpload.offset_dy),
                image));
          });
        }
      });
    }
    return new Uploads(uploads);
  }

  Future<TextItems> _getTextItems(
      String whiteboard, String permissionId) async {
    http.Response textItemResponse = await http.post(
        Uri.parse(dotenv.env['REST_API_URL']! + "/whiteboard/textitem/get"),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          'Authorization': 'Bearer ' + widget.auth_token,
        },
        body: jsonEncode(
            {"whiteboard": whiteboard, "permission_id": permissionId}));
    List<TextItem> texts = new List.empty(growable: true);
    if (textItemResponse.statusCode == 200) {
      List<DecodeGetTextItem> decodeTextItems =
          DecodeGetTextItemList.fromJsonList(jsonDecode(textItemResponse.body));
      setState(() {
        for (DecodeGetTextItem decodeGetTextItem in decodeTextItems) {
          texts.add(new TextItem(
              decodeGetTextItem.uuid,
              false,
              decodeGetTextItem.strokeWidth,
              decodeGetTextItem.maxWidth,
              decodeGetTextItem.maxHeight,
              HexColor.fromHex(decodeGetTextItem.color),
              decodeGetTextItem.contentText,
              new Offset(
                  decodeGetTextItem.offset_dx, decodeGetTextItem.offset_dy)));
        }
      });
    }
    return new TextItems(texts);
  }
}
