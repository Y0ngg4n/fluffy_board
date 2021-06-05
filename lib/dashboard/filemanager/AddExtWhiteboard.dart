import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AddExtWhiteboard extends StatefulWidget {
  String auth_token;
  String directory;
  RefreshController _refreshController;

  AddExtWhiteboard(this.auth_token, this.directory, this._refreshController);

  @override
  _AddExtWhiteboardState createState() => _AddExtWhiteboardState();
}

class _AddExtWhiteboardState extends State<AddExtWhiteboard> {
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
                      widthFactor: 0.5, child: AddExtWhiteboardForm(widget.auth_token,
                      widget.directory, widget._refreshController)));
                } else {
                  return (AddExtWhiteboardForm(widget.auth_token,
                  widget.directory,widget._refreshController));
                }
              },
            ),
          ),
        )));
  }
}

class AddExtWhiteboardForm extends StatefulWidget {
  String auth_token;
  String directory;
  RefreshController _refreshController;

  AddExtWhiteboardForm(this.auth_token, this.directory, this._refreshController);

  @override
  _AddExtWhiteboardFormState createState() => _AddExtWhiteboardFormState();
}

class _AddExtWhiteboardFormState extends State<AddExtWhiteboardForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController =
  new TextEditingController();

  _showError() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error while adding Whiteboard! Please try an other Invite ID."),
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
                    hintText: "Enter your Invite ID",
                    labelText: "Invite ID"),
                validator: (value) {
                  if (value == null || value.isEmpty
                      && RegExp(r"[a-f0-9]{8}-?[a-f0-9]{4}-?4[a-f0-9]{3}-?[89ab][a-f0-9]{3}-?[a-f0-9]{12}#[a-f0-9]{8}-?[a-f0-9]{4}-?4[a-f0-9]{3}-?[89ab][a-f0-9]{3}-?[a-f0-9]{12}").hasMatch(value)) {
                    return 'Please enter a valid Invite ID';
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
                                    SnackBar(content: Text('Trying to let you in ...')));
                                try {
                                  String inviteId = nameController.text;
                                  List splitInviteId = inviteId.split("#");
                                  http.Response response = await http.post(
                                      Uri.parse(dotenv.env['REST_API_URL']! +
                                          "/filemanager-ext/whiteboard/create"),
                                      headers: {
                                        "content-type": "application/json",
                                        "accept": "application/json",
                                        'Authorization': 'Bearer ' + widget.auth_token,
                                      },
                                      body: jsonEncode({
                                        'id': splitInviteId[0],
                                        'directory': widget.directory,
                                        'permission_id': splitInviteId[1]
                                      }));
                                  if (response.statusCode == 200) {
                                    Navigator.pop(context);
                                    widget._refreshController.requestRefresh();
                                  }else{
                                    _showError();
                                  }
                                } catch (e) {
                                  print(e);
                                  _showError();
                                }
                              }
                            },
                            child: Text("Import Whiteboard")))
                      ])),
    );
  }
}
