import 'package:fluffy_board/dashboard/filemanager/AddFolder.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'filemanager/AddExtWhiteboard.dart';
import 'filemanager/AddWhiteboard.dart';

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
    return Wrap(
          children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: ElevatedButton(onPressed: _createWhiteboard, child: Text("Create Whiteboard"))),
            Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: ElevatedButton(onPressed: _createFolder, child: Text("Create Folder"))),
            Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: ElevatedButton(onPressed: _importWhiteboard, child: Text("Import Whiteboard"))),
          ],
        );
  }

  _createFolder(){
    Navigator.push(context, MaterialPageRoute<void>(
      builder: (BuildContext context) => AddFolder(widget.auth_token,
          widget.parent, widget._refreshController),
    ),);
  }

  _createWhiteboard(){
    Navigator.push(context, MaterialPageRoute<void>(
      builder: (BuildContext context) => AddWhiteboard(widget.auth_token,
         widget.parent, widget._refreshController),
    ),);
  }

  _importWhiteboard(){
    Navigator.push(context, MaterialPageRoute<void>(
      builder: (BuildContext context) => AddExtWhiteboard(widget.auth_token,
          widget.parent, widget._refreshController),
    ),);
  }
}
