import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AddWhiteboard extends StatefulWidget {
  String auth_token;
  String directory;
  RefreshController _refreshController;

  AddWhiteboard(this.auth_token, this.directory, this._refreshController);

  @override
  _AddWhiteboardState createState() => _AddWhiteboardState();
}

class _AddWhiteboardState extends State<AddWhiteboard> {
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
                      widthFactor: 0.5, child: AddWhiteboardForm(widget.auth_token,
                      widget.directory, widget._refreshController)));
                } else {
                  return (AddWhiteboardForm(widget.auth_token,
                  widget.directory,widget._refreshController));
                }
              },
            ),
          ),
        )));
  }
}

class AddWhiteboardForm extends StatefulWidget {
  String auth_token;
  String directory;
  RefreshController _refreshController;

  AddWhiteboardForm(this.auth_token, this.directory, this._refreshController);

  @override
  _AddWhiteboardFormState createState() => _AddWhiteboardFormState();
}

class _AddWhiteboardFormState extends State<AddWhiteboardForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController =
  new TextEditingController();

  _showError() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error while adding Whiteboard! Please try an other Name."),
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
                    hintText: "Enter your Whiteboard Name",
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
                                    SnackBar(content: Text('Trying to create your Whiteboard ...')));
                                try {
                                  http.Response response = await http.post(
                                      Uri.parse(dotenv.env['REST_API_URL']! +
                                          "/filemanager/whiteboard/create"),
                                      headers: {
                                        "content-type": "application/json",
                                        "accept": "application/json",
                                        'Authorization': 'Bearer ' + widget.auth_token,
                                      },
                                      body: jsonEncode({
                                        'name': nameController.text,
                                        'directory': widget.directory,
                                        'password': "",
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
                            child: Text("Create Whiteboard")))
                      ])),
    );
  }
}
