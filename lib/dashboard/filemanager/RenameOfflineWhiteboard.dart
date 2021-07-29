import 'dart:convert';

import 'package:fluffy_board/dashboard/filemanager/FileManager.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'FileManagerTypes.dart';

class RenameOfflineWhiteboard extends StatefulWidget {
  OfflineWhiteboard offlineWhiteboard;
  RefreshController _refreshController;

  RenameOfflineWhiteboard(this.offlineWhiteboard, this._refreshController);

  @override
  _RenameOfflineWhiteboardState createState() => _RenameOfflineWhiteboardState();
}

class _RenameOfflineWhiteboardState extends State<RenameOfflineWhiteboard> {
  @override
  Widget build(BuildContext context) {
    return (Scaffold(
        appBar: AppBar(
          title: Text("Rename Folder"),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                if (constraints.maxWidth > 600) {
                  return (FractionallySizedBox(
                      widthFactor: 0.5,
                      child: RenameOfflineWhiteboardForm(
                        widget.offlineWhiteboard,
                          widget._refreshController)));
                } else {
                  return (RenameOfflineWhiteboardForm(
                      widget.offlineWhiteboard,
                      widget._refreshController));
                }
              },
            ),
          ),
        )));
  }
}

class RenameOfflineWhiteboardForm extends StatefulWidget {
  OfflineWhiteboard offlineWhiteboard;
  RefreshController _refreshController;

  RenameOfflineWhiteboardForm(this.offlineWhiteboard, this._refreshController);

  @override
  _RenameOfflineWhiteboardFormState createState() => _RenameOfflineWhiteboardFormState();
}

class _RenameOfflineWhiteboardFormState extends State<RenameOfflineWhiteboardForm> {
  final _formKey = GlobalKey<FormState>();
  final LocalStorage settingsStorage = new LocalStorage('settings');
  final TextEditingController nameController = new TextEditingController();
  final LocalStorage fileManagerStorage = new LocalStorage('filemanager');

  _showError() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error while renaming Whiteboard! Please try an other Name."),
        backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    nameController.text = widget.offlineWhiteboard.name;
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
            TextFormField(
              onFieldSubmitted: (value) => _renameOfflineWhiteboard(),
              controller: nameController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  icon: Icon(Icons.email_outlined),
                  hintText: "Enter your new Whiteboard name",
                  labelText: "New name"),
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
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                    onPressed: () => _renameOfflineWhiteboard(),
                    child: Text("Rename Whiteboard")))
          ])),
    );
  }

  _renameOfflineWhiteboard() async{
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate()) {
      // If the form is valid, display a snackbar. In the real world,
      // you'd often call a server or save the information in a database.
      widget.offlineWhiteboard.name = nameController.text;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Trying to rename whiteboard ...')));
      try {
        fileManagerStorage.setItem("offline_whiteboard-" + widget.offlineWhiteboard.uuid,
            widget.offlineWhiteboard.toJSONEncodable());
        widget._refreshController.requestRefresh();
        Navigator.pop(context);
      } catch (e) {
        print(e);
        _showError();
      }
    }
  }
}
