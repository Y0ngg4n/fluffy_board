import 'package:fluffy_board/dashboard/filemanager/AddFolder.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ActionButtons extends StatefulWidget {
  String auth_token, parent;
  RefreshController _refreshController;

  ActionButtons(this.auth_token, this.parent, this._refreshController);

  @override
  _ActionButtonsState createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<ActionButtons> {

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ElevatedButton(onPressed: () {}, child: Text("Create Whiteboard")),
            ElevatedButton(onPressed: _createFolder, child: Text("Create Folder")),
          ],
        ));
  }

  _createFolder(){
    Navigator.push(context, MaterialPageRoute<void>(
      builder: (BuildContext context) => AddFolder(super.widget.auth_token,
          super.widget.parent, super.widget._refreshController),
    ),);
  }
}
