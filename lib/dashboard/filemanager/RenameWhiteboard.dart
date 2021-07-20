import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RenameWhiteboard extends StatefulWidget {
  String auth_token;
  String directory;
  String id;
  String currentName;
  RefreshController _refreshController;

  RenameWhiteboard(this.auth_token, this.id, this.directory, this.currentName, this._refreshController);

  @override
  _RenameWhiteboardState createState() => _RenameWhiteboardState();
}

class _RenameWhiteboardState extends State<RenameWhiteboard> {
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
                      child: RenameWhiteboardForm(
                          widget.auth_token,
                          widget.id,
                          widget.directory,
                          widget.currentName,
                          widget._refreshController)));
                } else {
                  return (RenameWhiteboardForm(
                      widget.auth_token,
                      widget.id,
                      widget.directory,
                      widget.currentName,
                      widget._refreshController));
                }
              },
            ),
          ),
        )));
  }
}

class RenameWhiteboardForm extends StatefulWidget {
  String auth_token;
  String directory;
  String id;
  String currentName;
  RefreshController _refreshController;

  RenameWhiteboardForm(
      this.auth_token, this.id, this.directory, this.currentName, this._refreshController);

  @override
  _RenameWhiteboardFormState createState() => _RenameWhiteboardFormState();
}

class _RenameWhiteboardFormState extends State<RenameWhiteboardForm> {
  final _formKey = GlobalKey<FormState>();
  final LocalStorage settingsStorage = new LocalStorage('settings');
  final TextEditingController nameController = new TextEditingController();

  _showError() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error while renaming Whiteboard! Please try an other Name."),
        backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    print(widget.currentName);
    nameController.text = widget.currentName;
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
            TextFormField(
              onFieldSubmitted: (value) => _renameWhiteboard(),
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
                    onPressed: () => _renameWhiteboard(),
                    child: Text("Rename Whiteboard")))
          ])),
    );
  }

  _renameWhiteboard() async{
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate()) {
      // If the form is valid, display a snackbar. In the real world,
      // you'd often call a server or save the information in a database.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Trying to rename whiteboard ...')));
      try {
        http.Response response = await http.post(
            Uri.parse((settingsStorage.getItem("REST_API_URL") ?? dotenv.env['REST_API_URL']!) +
                "/filemanager/whiteboard/rename"),
            headers: {
              "content-type": "application/json",
              "accept": "application/json",
              'Authorization':
              'Bearer ' + widget.auth_token,
            },
            body: jsonEncode({
              'id': widget.id,
              'name': nameController.text,
            }));
        if (response.statusCode == 200) {
          Navigator.pop(context);
          widget._refreshController.requestRefresh();
        } else {
          _showError();
        }
      } catch (e) {
        print(e);
        _showError();
      }
    }
  }
}
