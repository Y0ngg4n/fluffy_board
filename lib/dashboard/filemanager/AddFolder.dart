import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AddFolder extends StatefulWidget {
  String auth_token;
  String parent;
  RefreshController _refreshController;

  AddFolder(this.auth_token, this.parent, this._refreshController);

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
                      widthFactor: 0.5, child: AddFolderForm(super.widget.auth_token,
                      super.widget.parent, super.widget._refreshController)));
                } else {
                  return (AddFolderForm(super.widget.auth_token,
                      super.widget.parent, super.widget._refreshController));
                }
              },
            ),
          ),
        )));
  }
}

class AddFolderForm extends StatefulWidget {
  String auth_token;
  String parent;
  RefreshController _refreshController;

  AddFolderForm(this.auth_token, this.parent, this._refreshController);

  @override
  _AddFolderFormState createState() => _AddFolderFormState();
}

class _AddFolderFormState extends State<AddFolderForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController =
  new TextEditingController();

  _showError() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error while adding Folder! Please try an other Name."),
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
                controller: nameController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    icon: Icon(Icons.email_outlined),
                    hintText: "Enter your Directory Name",
                    labelText: "Name"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a Name';
                  }else if(value.length > 50){
                    return 'Please enter a Name smaller than 50';
                  }
                  return null;
                },
              ),
              Padding(
                  padding: const EdgeInsets.all(16),
                       child: ElevatedButton(
                            onPressed: () async {
                              // Validate returns true if the form is valid, or false otherwise.
                              if (_formKey.currentState!.validate()) {
                                // If the form is valid, display a snackbar. In the real world,
                                // you'd often call a server or save the information in a database.
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Trying to create folder ...')));
                                try {
                                  http.Response response = await http.post(
                                      Uri.parse(dotenv.env['REST_API_URL']! +
                                          "/filemanager/directory/create"),
                                      headers: {
                                        "content-type": "application/json",
                                        "accept": "application/json",
                                        'Authorization': 'Bearer ' + super.widget.auth_token,
                                      },
                                      body: jsonEncode({
                                        'filename': nameController.text,
                                        'parent': super.widget.parent,
                                      }));
                                  if (response.statusCode == 200) {
                                    Navigator.pop(context);
                                    super.widget._refreshController.requestRefresh();
                                  }else{
                                    _showError();
                                  }
                                } catch (e) {
                                  print(e);
                                  _showError();
                                }
                              }
                            },
                            child: Text("Create Folder")))
                      ])),
    );
  }
}
