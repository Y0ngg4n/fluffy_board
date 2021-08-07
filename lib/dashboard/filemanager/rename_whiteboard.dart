import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RenameWhiteboard extends StatefulWidget {
  final String authToken;
  final String directory;
  final String id;
  final String currentName;
  final RefreshController _refreshController;

  RenameWhiteboard(this.authToken, this.id, this.directory, this.currentName, this._refreshController);

  @override
  _RenameWhiteboardState createState() => _RenameWhiteboardState();
}

class _RenameWhiteboardState extends State<RenameWhiteboard> {
  @override
  Widget build(BuildContext context) {
    return (Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.renameWhiteboard),
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
                          widget.authToken,
                          widget.id,
                          widget.directory,
                          widget.currentName,
                          widget._refreshController)));
                } else {
                  return (RenameWhiteboardForm(
                      widget.authToken,
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
  final String authToken;
  final String directory;
  final String id;
  final String currentName;
  final RefreshController _refreshController;

  RenameWhiteboardForm(
      this.authToken, this.id, this.directory, this.currentName, this._refreshController);

  @override
  _RenameWhiteboardFormState createState() => _RenameWhiteboardFormState();
}

class _RenameWhiteboardFormState extends State<RenameWhiteboardForm> {
  final _formKey = GlobalKey<FormState>();
  final LocalStorage settingsStorage = new LocalStorage('settings');
  final TextEditingController nameController = new TextEditingController();

  _showError() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.errorRenameWhiteboard),
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
              decoration: InputDecoration(
                  errorMaxLines: 5,
                  border: OutlineInputBorder(),
                  icon: Icon(Icons.email_outlined),
                  hintText: AppLocalizations.of(context)!.enterWhiteboardName,
                  labelText: AppLocalizations.of(context)!.enterWhiteboardName),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!.enterWhiteboardName;
                } else if (value.length > 50) {
                  return AppLocalizations.of(context)!.nameSmaller;
                }
                return null;
              },
            ),
            Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      textStyle: TextStyle(fontSize: 20),
                      minimumSize: const Size(
                          double.infinity, 60)),
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
              'Bearer ' + widget.authToken,
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
