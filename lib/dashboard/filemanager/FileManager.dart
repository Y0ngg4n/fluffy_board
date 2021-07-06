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
import 'package:file_saver/file_saver.dart';

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

  toJSONEncodable() {
    Map<String, dynamic> m = new Map();

    m['uuid'] = uuid;
    m['directory'] = directory;
    m['name'] = name;
    m['uploads'] = uploads.toJSONEncodable();
    m['texts'] = texts.toJSONEncodable();
    m['scribbles'] = scribbles.toJSONEncodable();
    return m;
  }

  OfflineWhiteboard.fromJson(Map<String, dynamic> json)
      : uuid = json['uuid'],
        directory = json['directory'],
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

  OfflineWhiteboard(this.uuid, this.directory, this.name, this.uploads,
      this.texts, this.scribbles);
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

class CreateWhiteboardResponse {
  String id;
  String directory;

  CreateWhiteboardResponse.fromJson(Map<String, dynamic> json)
      : this.id = json['id'],
        this.directory = json['directory'];
}

class FileManager extends StatefulWidget {
  String auth_token;
  String username;
  bool online;

  FileManager(this.auth_token, this.username, this.online);

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
  double file_icon_size = 100;
  final LocalStorage fileManagerStorageIndex =
      new LocalStorage('filemanager-index');
  final LocalStorage fileManagerStorage = new LocalStorage('filemanager');
  var uuid = Uuid();

  _showUploadError() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error while uploading Whiteboard!"),
        backgroundColor: Colors.red));
  }

  _showMoveError() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error while moving Whiteboard!"),
        backgroundColor: Colors.red));
  }

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
                widget.auth_token,
                currentDirectory,
                _refreshController,
                offlineWhiteboards,
                offlineWhiteboardIds,
                widget.online,
                directories)
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
                maxCrossAxisExtent: 200,
                children: directoryAndWhiteboardButtons,
              )))
    ]));
  }

  _mapDirectories(directoryButtons) {
    for (Directory directory in directories.list) {
      directoryButtons.add(DragTarget(
        onAccept: (data) async {
          await _moveWhiteboard(data, directory.id);
        },
        builder: (context, candidateData, rejectedData) {
          return LongPressDraggable<Directory>(
            data: directory,
            feedback: Icon(Icons.folder_open_outlined, size: file_icon_size),
            child: (Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                        child: Column(
                      children: [
                        InkWell(
                          child: Icon(Icons.folder_open_outlined,
                              size: file_icon_size),
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
                    )),
                    PopupMenuButton(
                      itemBuilder: (context) => widget.online
                          ? [
                              PopupMenuItem(
                                  child: Text("Rename Folder"), value: 0),
                              PopupMenuItem(
                                  child: Text("Delete Folder"), value: 1),
                            ]
                          : [
                              PopupMenuItem(
                                  child: Text("Rename Folder"), value: 0),
                            ],
                      onSelected: (value) {
                        switch (value) {
                          case 0:
                            Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) =>
                                      RenameFolder(
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
            )),
          );
        },
      ));
    }
  }

  _mapBreadCrumbs(breadCrumbItems) {
    breadCrumbItems.add(BreadCrumbItem(
        content: DragTarget(onAccept: (data) async {
          await _moveWhiteboard(data, "");
        }, builder: (context, candidateData, rejectedData) {
          return Icon(
            Icons.home,
            size: font_size,
          );
        }),
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
          content: DragTarget(
            onAccept: (data) async {
              await _moveWhiteboard(data, uuid);
            },
            builder: (context, candidateData, rejectedData) {
              return Text(filename, style: TextStyle(fontSize: font_size));
            },
          ),
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
      whiteboardButtons.add(LongPressDraggable<Whiteboard>(
        data: whiteboard,
        feedback: Icon(Icons.assignment, size: file_icon_size),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      InkWell(
                        child: Icon(Icons.assignment, size: file_icon_size),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                  builder: (BuildContext context) =>
                                      WhiteboardView(whiteboard, null, null,
                                          widget.auth_token)));
                        },
                      ),
                      Text(
                        whiteboard.name,
                        maxLines: 1,
                      ),
                    ],
                  ),
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
                              builder: (BuildContext context) =>
                                  RenameWhiteboard(
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
                              builder: (BuildContext context) =>
                                  ShareWhiteboard(
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
                                uuid.v4(),
                                currentDirectory,
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
                        fileManagerStorageIndex.setItem("indexes",
                            jsonEncode(offlineWhiteboardIds.toList()));
                        _refreshController.requestRefresh();
                        break;
                    }
                  },
                )
              ],
            ),
          ],
        ),
      ));
    }
  }

  _mapExtWhiteboards(whiteboardButtons) {
    for (ExtWhiteboard whiteboard in extWhiteboards.list) {
      whiteboardButtons.add(LongPressDraggable<ExtWhiteboard>(
        data: whiteboard,
        feedback: Icon(Icons.assignment_ind, size: file_icon_size),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      InkWell(
                        child: Icon(Icons.assignment_ind, size: file_icon_size),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                  builder: (BuildContext context) =>
                                      WhiteboardView(null, whiteboard, null,
                                          widget.auth_token)));
                        },
                      ),
                      Text(
                        whiteboard.name,
                        // style: TextStyle(fontSize: file_font_size),
                      ),
                    ],
                  ),
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
        ),
      ));
    }
  }

  _mapOfflineWhiteboards(whiteboardButtons) {
    for (OfflineWhiteboard whiteboard in offlineWhiteboards.list) {
      whiteboardButtons.add(LongPressDraggable<OfflineWhiteboard>(
        data: whiteboard,
        feedback:
            Icon(Icons.download_for_offline_outlined, size: file_icon_size),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      InkWell(
                        child: Icon(Icons.download_for_offline_outlined,
                            size: file_icon_size),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                  builder: (BuildContext context) =>
                                      WhiteboardView(null, null, whiteboard,
                                          widget.auth_token)));
                        },
                      ),
                      Text(whiteboard.name
                          // style: TextStyle(fontSize: file_font_size),
                          ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(child: Text("Delete Whiteboard"), value: 0),
                    PopupMenuItem(child: Text("Upload Whiteboard"), value: 1),
                    PopupMenuItem(child: Text("Export Whiteboard"), value: 2)
                  ],
                  onSelected: (value) async {
                    switch (value) {
                      case 0:
                        _deleteOfflineWhiteboardDialog(context, whiteboard);
                        break;
                      case 1:
                        http.Response response = await http.post(
                            Uri.parse(dotenv.env['REST_API_URL']! +
                                "/filemanager/whiteboard/create"),
                            headers: {
                              "content-type": "application/json",
                              "accept": "application/json",
                              'Authorization': 'Bearer ' + widget.auth_token,
                            },
                            body: jsonEncode({
                              'name': whiteboard.name,
                              'directory': whiteboard.directory,
                              'password': "",
                            }));
                        CreateWhiteboardResponse createWhiteboardResponse =
                            CreateWhiteboardResponse.fromJson(
                                jsonDecode(response.body));
                        if (response.statusCode == 200) {
                          whiteboard.uuid = createWhiteboardResponse.id;
                          http.Response response = await http.post(
                              Uri.parse(dotenv.env['REST_API_URL']! +
                                  "/offline-whiteboard/import"),
                              headers: {
                                "content-type": "application/json",
                                "accept": "application/json",
                                'Authorization': 'Bearer ' + widget.auth_token,
                              },
                              body: jsonEncode(whiteboard.toJSONEncodable()));
                          if (response.statusCode == 200) {
                            print("Import Successfull");
                          } else {
                            _showUploadError();
                          }
                          _refreshController.requestRefresh();
                        } else {
                          _showUploadError();
                        }
                        break;
                      case 2:
                        await FileSaver.instance.saveFile(
                            "FluffyBoard-" + whiteboard.name,
                            Uint8List.fromList(
                                jsonEncode(whiteboard.toJSONEncodable())
                                    .codeUnits),
                            "json");
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                "Downloaded the Whiteboard to your Downloads folder"),
                            backgroundColor: Colors.green));
                        break;
                    }
                  },
                )
              ],
            ),
          ],
        ),
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
                    directories.list.remove(directory);
                    await fileManagerStorage.setItem(
                        "directories", directories.toJSONEncodable());
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

  _moveWhiteboard(dynamic data, String directoryUuid) async {
    if (data is Whiteboard) {
      Whiteboard whiteboard = data;
      whiteboard.parent = directoryUuid;
      http.Response response = await http.post(
          Uri.parse(
              dotenv.env['REST_API_URL']! + "/filemanager/whiteboard/move"),
          headers: {
            "content-type": "application/json",
            "accept": "application/json",
            'Authorization': 'Bearer ' + widget.auth_token,
          },
          body: jsonEncode({
            'id': whiteboard.id,
            'directory': directoryUuid,
          }));
      if (response.statusCode == 200) {
        _refreshController.requestRefresh();
      } else {
        _showMoveError();
      }
    } else if (data is ExtWhiteboard) {
      ExtWhiteboard whiteboard = data;
      whiteboard.directory = directoryUuid;
      http.Response response = await http.post(
          Uri.parse(
              dotenv.env['REST_API_URL']! + "/filemanager-ext/whiteboard/move"),
          headers: {
            "content-type": "application/json",
            "accept": "application/json",
            'Authorization': 'Bearer ' + widget.auth_token,
          },
          body: jsonEncode({
            'id': whiteboard.id,
            'directory': directoryUuid,
          }));
      if (response.statusCode == 200) {
        _refreshController.requestRefresh();
      } else {
        _showMoveError();
      }
    } else if (data is OfflineWhiteboard) {
      OfflineWhiteboard whiteboard = data;
      whiteboard.directory = directoryUuid;
      fileManagerStorage.setItem("offline_whiteboard-" + whiteboard.uuid,
          whiteboard.toJSONEncodable());
      _refreshController.requestRefresh();
    } else if (data is Directory) {
      Directory directory = data;
      if (directory.id == directoryUuid) return;
      http.Response response = await http.post(
          Uri.parse(
              dotenv.env['REST_API_URL']! + "/filemanager/directory/move"),
          headers: {
            "content-type": "application/json",
            "accept": "application/json",
            'Authorization': 'Bearer ' + widget.auth_token,
          },
          body: jsonEncode({
            'id': directory.id,
            'parent': directoryUuid,
          }));
      directory.id = directoryUuid;
      if (response.statusCode == 200) {
        _refreshController.requestRefresh();
      } else {
        _showMoveError();
      }
    }
  }

  Future<void> _getDirectoriesAndWhiteboards() async {
    await _getOfflineWhiteboards();
    Directories offlineDirectories = _getOfflineDirectories();
    if (!widget.online) {
      setState(() {
        this.directories = offlineDirectories;
        this.whiteboards = new Whiteboards([]);
        this.extWhiteboards = new ExtWhiteboards([]);
      });
      _refreshController.refreshCompleted();
      return;
    }
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
    List<String> directoryUuids = [];
    for (Directory directory in directories.list) {
      directoryUuids.add(directory.id);
    }
    List<Directory> removeOfflineDirectories = [];
    for (Directory offlineDirectory in offlineDirectories.list) {
      if (!directoryUuids.contains(offlineDirectory.id)) {
        http.Response response = await http.post(
            Uri.parse(
                dotenv.env['REST_API_URL']! + "/filemanager/directory/create"),
            headers: {
              "content-type": "application/json",
              "accept": "application/json",
              'Authorization': 'Bearer ' + widget.auth_token,
            },
            body: jsonEncode({
              'filename': offlineDirectory.filename,
              'parent': offlineDirectory.parent,
            }));
        if (response.statusCode == 200) {
          removeOfflineDirectories.add(offlineDirectory);
          print("Removeeee");
        }
      }
    }
    for (Directory dir in removeOfflineDirectories) {
      offlineDirectories.list.remove(dir);
    }
    await fileManagerStorage.setItem(
        "directories", directories.toJSONEncodable());

    Whiteboards whiteboards =
        Whiteboards.fromJson(jsonDecode(utf8.decode((wbResponse.bodyBytes))));
    ExtWhiteboards extWhiteboards = ExtWhiteboards.fromJson(
        jsonDecode(utf8.decode((wbExtResponse.bodyBytes))));
    fileManagerStorage.setItem("directories", directories.toJSONEncodable());

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

  _getOfflineWhiteboards() async {
    await fileManagerStorageIndex.ready;
    await fileManagerStorage.ready;
    setState(() {
      try {
        this.offlineWhiteboardIds = Set.of(
            jsonDecode(fileManagerStorageIndex.getItem("indexes"))
                    .cast<String>() ??
                []);
      } catch (e) {
        this.offlineWhiteboardIds = Set.of([]);
      }
      List<OfflineWhiteboard> offlineWhiteboards = List.empty(growable: true);
      for (String id in offlineWhiteboardIds) {
        Map<String, dynamic>? json =
            fileManagerStorage.getItem("offline_whiteboard-" + id);
        if (json != null) {
          OfflineWhiteboard offlineWhiteboard =
              OfflineWhiteboard.fromJson(json);
          if ((offlineWhiteboard.directory.isEmpty &&
                  currentDirectory.isEmpty) ||
              offlineWhiteboard.directory == currentDirectory) {
            offlineWhiteboards.add(offlineWhiteboard);
          }
        }
      }
      this.offlineWhiteboards = new OfflineWhiteboards(offlineWhiteboards);
    });
  }

  Directories _getOfflineDirectories() {
    Directories directories =
        Directories.fromOfflineJson(fileManagerStorage.getItem("directories"));
    List<Directory> removeList = [];
    for (Directory dir in directories.list) {
      if ((currentDirectory.isEmpty &&
          dir.parent == "00000000-0000-0000-0000-000000000000")) {
      } else if (dir.parent != currentDirectory) {
        removeList.add(dir);
      }
    }
    for (Directory dir in removeList) {
      directories.list.remove(dir);
    }
    return directories;
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
    if (uploadResponse.statusCode == 200) {
      List<DecodeGetUpload> decodedUploads =
          DecodeGetUploadList.fromJsonList(jsonDecode(uploadResponse.body));
      List<Upload> decodedUploadsWithImages =
          await getDecodedUploadImages(decodedUploads);
      return new Uploads(decodedUploadsWithImages);
    }
    return new Uploads([]);
  }

  Future<List<Upload>> getDecodedUploadImages(
      List<DecodeGetUpload> decodedUploads) async {
    List<Upload> uploads = new List.empty(growable: true);
    for (DecodeGetUpload decodeGetUpload in decodedUploads) {
      Uint8List uint8list = Uint8List.fromList(decodeGetUpload.imageData);
      final ui.Codec codec =
          await PaintingBinding.instance!.instantiateImageCodec(uint8list);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      uploads.add(new Upload(
          decodeGetUpload.uuid,
          UploadType.values[decodeGetUpload.uploadType],
          uint8list,
          new Offset(decodeGetUpload.offset_dx, decodeGetUpload.offset_dy),
          frameInfo.image));
    }
    return uploads;
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
