import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:uuid/uuid.dart';
import 'file_manager_types.dart';

class AddFolder extends StatefulWidget {
  final String authToken;
  final String parent;
  final RefreshController _refreshController;
  final Directories directories;
  final bool online;

  AddFolder(this.authToken, this.parent, this._refreshController,
      this.directories, this.online);

  @override
  _AddFolderState createState() => _AddFolderState();
}

class _AddFolderState extends State<AddFolder> {
  @override
  Widget build(BuildContext context) {
    return (Scaffold(
        appBar: AppBar(
          title: Text("Add Folder"),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                if (constraints.maxWidth > 600) {
                  return (FractionallySizedBox(
                      widthFactor: 0.5,
                      child: AddFolderForm(
                          widget.authToken,
                          widget.parent,
                          widget._refreshController,
                          widget.directories,
                          widget.online)));
                } else {
                  return (AddFolderForm(
                      widget.authToken,
                      widget.parent,
                      widget._refreshController,
                      widget.directories,
                      widget.online));
                }
              },
            ),
          ),
        )));
  }
}

class AddFolderForm extends StatefulWidget {
  final String authToken;
  final String parent;
  final RefreshController _refreshController;
  final Directories directories;
  final bool online;

  AddFolderForm(this.authToken, this.parent, this._refreshController,
      this.directories, this.online);

  @override
  _AddFolderFormState createState() => _AddFolderFormState();
}

class _AddFolderFormState extends State<AddFolderForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = new TextEditingController();
  final LocalStorage storage = new LocalStorage('account');
  final LocalStorage settingsStorage = new LocalStorage('settings');
  final LocalStorage fileManagerStorage = new LocalStorage('filemanager');

  _showError() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error while adding Folder! Please try an other Name."),
        backgroundColor: Colors.red));
  }

  var uuid = Uuid();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
            TextFormField(
              onFieldSubmitted: (value) => _addFolder(),
              controller: nameController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  icon: Icon(Icons.email_outlined),
                  hintText: "Enter your Directory Name",
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
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      textStyle: TextStyle(fontSize: 20),
                      minimumSize: const Size(
                          double.infinity, 60)),
                    onPressed: () => _addFolder(),
                    child: Text("Create Folder")))
          ])),
    );
  }

  _addFolder() async {
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate()) {
      // If the form is valid, display a snackbar. In the real world,
      // you'd often call a server or save the information in a database.
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Trying to create folder ...')));
      if (widget.online) {
        try {
          http.Response response = await http.post(
              Uri.parse((settingsStorage.getItem("REST_API_URL") ?? dotenv.env['REST_API_URL']!) +
                  "/filemanager/directory/create"),
              headers: {
                "content-type": "application/json",
                "accept": "application/json",
                'Authorization': 'Bearer ' + widget.authToken,
              },
              body: jsonEncode({
                'filename': nameController.text,
                'parent': widget.parent,
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
      } else {
        await storage.ready;
        widget.directories.list.add(new Directory(
            uuid.v4(),
            storage.getItem('id') ?? "",
            widget.parent,
            nameController.text,
            DateTime.now().millisecond));
        fileManagerStorage
            .setItem("directories", widget.directories.toJSONEncodable())
            .then((value) => {
                  Navigator.pop(context),
                  widget._refreshController.requestRefresh()
                });
      }
    }
  }
}
