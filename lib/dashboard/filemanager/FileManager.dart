import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';

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

class FileManager extends StatefulWidget {
  String auth_token;

  FileManager(this.auth_token);

  @override
  _FileManagerState createState() => _FileManagerState();
}

class _FileManagerState extends State<FileManager> {
  late Directories directories = new Directories([]);
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
    List<Widget> directoryButtons = [];
    for (Directory directory in directories.list) {
      directoryButtons.add(Column(
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
          Text(
            directory.filename,
            // style: TextStyle(fontSize: file_font_size),
          ),
        ],
      ));
    }

    List<BreadCrumbItem> breadCrumbItems = [];
    // Home Icon
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
                i, currentDirectoryPath.length - 1);
            _refreshController.requestRefresh();
          }));
    }

    return Container(
        child: Column(children: [
      BreadCrumb(
        items: breadCrumbItems,
        divider: Icon(Icons.chevron_right),
      ),
      Expanded(
          child: SmartRefresher(
              enablePullDown: true,
              enablePullUp: false,
              controller: _refreshController,
              onRefresh: _getDirectoriesAndWhiteboards,
              child: GridView.count(
                crossAxisCount: 1,
                children: directoryButtons,
              )))
    ]));
  }

  Future<void> _getDirectoriesAndWhiteboards() async {
    http.Response response = await http.post(
        Uri.parse(dotenv.env['REST_API_URL']! + "/filemanager/directory/get"),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          'Authorization': 'Bearer ' + super.widget.auth_token,
        },
        body: jsonEncode({
          "parent": currentDirectory,
        }));
    print(response.body);
    Directories directories = Directories.fromJson(jsonDecode(response.body));
    setState(() {
      this.directories = directories;
    });
    if (response.statusCode == 200)
      _refreshController.refreshCompleted();
    else
      _refreshController.refreshFailed();
  }
}
