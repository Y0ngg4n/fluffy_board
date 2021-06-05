import 'dart:convert';

import 'package:fluffy_board/dashboard/filemanager/RenameFolder.dart';
import 'package:fluffy_board/dashboard/filemanager/RenameWhiteboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';

import '../ActionButtons.dart';

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
  late String id, owner, parent, name;
  late int created;

  Whiteboard(this.id, this.owner, this.parent, this.name, this.created);
}

class Whiteboards {
  List<Whiteboard> list = [];

  Whiteboards(this.list);

  Whiteboards.fromJson(List<dynamic> json) {
    for (Map<String, dynamic> row in json) {
      list.add(new Whiteboard(row['id'], row['owner'], row['directory'],
          row['name'], row['created']));
    }
  }
}

class ExtWhiteboard {
  late String id, owner, parent, name;
  late int created;

  ExtWhiteboard(this.id, this.owner, this.parent, this.name, this.created);
}

class ExtWhiteboards {
  List<ExtWhiteboard> list = [];

  ExtWhiteboards(this.list);

  ExtWhiteboards.fromJson(List<dynamic> json) {
    for (Map<String, dynamic> row in json) {
      list.add(new ExtWhiteboard(row['id'], row['owner'], row['directory'],
          row['name'], row['created']));
    }
  }
}

class FileManager extends StatefulWidget {
  String auth_token;

  FileManager(this.auth_token);

  @override
  _FileManagerState createState() => _FileManagerState();
}

class _FileManagerState extends State<FileManager> {
  late Directories directories = new Directories([]);
  late Whiteboards whiteboards = new Whiteboards([]);
  late ExtWhiteboards extWhiteboards = new ExtWhiteboards([]);
  String currentDirectory = "";
  List<Directory> currentDirectoryPath = [];
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  double font_size = 25;
  double file_icon_size = 50;

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
              child: GridView.count(
                crossAxisCount: 10,
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
              InkWell(
                child: Icon(Icons.folder_open_outlined, size: file_icon_size),
                onTap: () {
                  setState(() {
                    currentDirectory = directory.id;
                    currentDirectoryPath.add(directory);
                  });
                  _refreshController.requestRefresh();
                },
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
          Text(
            directory.filename,
            // style: TextStyle(fontSize: file_font_size),
          )
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
              InkWell(
                child: Icon(Icons.assignment, size: file_icon_size),
                onTap: () {},
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(child: Text("Rename Whiteboard"), value: 0),
                  PopupMenuItem(child: Text("Delete Whiteboard"), value: 1),
                ],
                onSelected: (value) {
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
                  }
                },
              )
            ],
          ),
          Text(
            whiteboard.name,
            // style: TextStyle(fontSize: file_font_size),
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
              InkWell(
                child: Icon(Icons.assignment_ind, size: file_icon_size),
                onTap: () {},
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
          Text(
            whiteboard.name,
            // style: TextStyle(fontSize: file_font_size),
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
    ExtWhiteboards extWhiteboards = ExtWhiteboards.fromJson(
        jsonDecode(utf8.decode((wbExtResponse.bodyBytes))));
    setState(() {
      this.directories = directories;
      this.whiteboards = whiteboards;
      this.extWhiteboards = extWhiteboards;
    });
    if (dirResponse.statusCode == 200 && wbResponse.statusCode == 200)
      _refreshController.refreshCompleted();
    else
      _refreshController.refreshFailed();
  }
}
