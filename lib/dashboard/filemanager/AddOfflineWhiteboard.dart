import 'dart:convert';

import 'package:fluffy_board/whiteboard/DrawPoint.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'FileManager.dart';
import 'package:uuid/uuid.dart';

import 'FileManagerTypes.dart';

class AddOfflineWhiteboard extends StatefulWidget {
  String auth_token;
  String directory;
  OfflineWhiteboards offlineWhiteboards;
  Set<String> offlineWhiteboardIds = Set.of([]);
  RefreshController _refreshController;

  AddOfflineWhiteboard(this.auth_token, this.directory, this._refreshController,
      this.offlineWhiteboards, this.offlineWhiteboardIds);

  @override
  _AddOfflineWhiteboardState createState() => _AddOfflineWhiteboardState();
}

class _AddOfflineWhiteboardState extends State<AddOfflineWhiteboard> {
  @override
  Widget build(BuildContext context) {
    return (Scaffold(
        appBar: AppBar(
          title: Text("Add Whiteboard"),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                if (constraints.maxWidth > 600) {
                  return (FractionallySizedBox(
                      widthFactor: 0.5,
                      child: AddOfflineWhiteboardForm(
                          widget.auth_token,
                          widget.directory,
                          widget._refreshController,
                          widget.offlineWhiteboards,
                          widget.offlineWhiteboardIds)));
                } else {
                  return (AddOfflineWhiteboardForm(
                      widget.auth_token,
                      widget.directory,
                      widget._refreshController,
                      widget.offlineWhiteboards,
                      widget.offlineWhiteboardIds));
                }
              },
            ),
          ),
        )));
  }
}

class AddOfflineWhiteboardForm extends StatefulWidget {
  String auth_token;
  String directory;
  RefreshController _refreshController;
  OfflineWhiteboards offlineWhiteboards;
  Set<String> offlineWhiteboardIds = Set.of([]);

  AddOfflineWhiteboardForm(
      this.auth_token,
      this.directory,
      this._refreshController,
      this.offlineWhiteboards,
      this.offlineWhiteboardIds);

  @override
  _AddOfflineWhiteboardFormState createState() =>
      _AddOfflineWhiteboardFormState();
}

class _AddOfflineWhiteboardFormState extends State<AddOfflineWhiteboardForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = new TextEditingController();
  var uuid = Uuid();
  final LocalStorage fileManagerStorageIndex =
      new LocalStorage('filemanager-index');
  final LocalStorage fileManagerStorage = new LocalStorage('filemanager');

  _showError() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            "Error while adding Offline Whiteboard! Please try an other Name."),
        backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
            TextFormField(
              onFieldSubmitted: (value) => _addOfflineWhiteboard(),
              controller: nameController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  icon: Icon(Icons.email_outlined),
                  hintText: "Enter your Whiteboard Name",
                  labelText: "Name"),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a Name';
                } else if (value.length > 50) {
                  return 'Please enter a Name smaller than 50';
                }
                return null;
              },
            ),
            Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 8),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      textStyle: TextStyle(fontSize: 20),
                      minimumSize: const Size(
                          double.infinity, 60)),
                    onPressed: () => _addOfflineWhiteboard(),
                    child: Text("Create Offline Whiteboard")))
          ])),
    );
  }

  _addOfflineWhiteboard() async {
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate()) {
      // If the form is valid, display a snackbar. In the real world,
      // you'd often call a server or save the information in a database.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Trying to create your Offline Whiteboard ...')));
      OfflineWhiteboard offlineWhiteboard = new OfflineWhiteboard(
          uuid.v4(),
          widget.directory,
          nameController.text,
          new Uploads([]),
          new TextItems([]),
          new Scribbles([]),
          new Bookmarks([]), Offset.zero, 1);

      widget.offlineWhiteboards.list.add(offlineWhiteboard);
      await fileManagerStorage.setItem("offline_whiteboard-" + offlineWhiteboard.uuid,
          offlineWhiteboard.toJSONEncodable());
      for (OfflineWhiteboard offWhi in widget.offlineWhiteboards.list) {
        widget.offlineWhiteboardIds.add(offWhi.uuid);
      }
      await fileManagerStorageIndex.setItem(
          "indexes", jsonEncode(widget.offlineWhiteboardIds.toList()));
      Navigator.pop(context);
      widget._refreshController.requestRefresh();
    }
  }
}
