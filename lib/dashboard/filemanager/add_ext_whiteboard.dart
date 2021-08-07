import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddExtWhiteboard extends StatefulWidget {
  final String authToken;
  final String directory;
  final RefreshController _refreshController;

  AddExtWhiteboard(this.authToken, this.directory, this._refreshController);

  @override
  _AddExtWhiteboardState createState() => _AddExtWhiteboardState();
}

class _AddExtWhiteboardState extends State<AddExtWhiteboard> {
  @override
  Widget build(BuildContext context) {
    return (Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.collabWhiteboard),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                if (constraints.maxWidth > 600) {
                  return (FractionallySizedBox(
                      widthFactor: 0.5, child: AddExtWhiteboardForm(widget.authToken,
                      widget.directory, widget._refreshController)));
                } else {
                  return (AddExtWhiteboardForm(widget.authToken,
                  widget.directory,widget._refreshController));
                }
              },
            ),
          ),
        )));
  }
}

class AddExtWhiteboardForm extends StatefulWidget {
  final String authToken;
  final String directory;
  final RefreshController _refreshController;

  AddExtWhiteboardForm(this.authToken, this.directory, this._refreshController);

  @override
  _AddExtWhiteboardFormState createState() => _AddExtWhiteboardFormState();
}

class _AddExtWhiteboardFormState extends State<AddExtWhiteboardForm> {
  final _formKey = GlobalKey<FormState>();
  final LocalStorage settingsStorage = new LocalStorage('settings');
  final TextEditingController nameController =
  new TextEditingController();

  _showError() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.errorCollabWhiteboard),
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
                onFieldSubmitted: (value) => _addExtWhiteboard(),
                decoration: InputDecoration(
                    errorMaxLines: 5,
                    border: OutlineInputBorder(),
                    icon: Icon(Icons.email_outlined),
                    hintText: AppLocalizations.of(context)!.enterInviteID,
                    suffixIcon: IconButton(
                        icon: Icon(Icons.content_paste),
                        onPressed: () async {
                          ClipboardData? clipboardData = await Clipboard.getData("text/plain");
                          if(clipboardData != null && clipboardData.text != null){
                            nameController.text = clipboardData.text!;
                          }
                        },
                    ),
                    labelText: AppLocalizations.of(context)!.inviteID),
                validator: (value) {
                  if (value == null || value.isEmpty
                      && RegExp(r"[a-f0-9]{8}-?[a-f0-9]{4}-?4[a-f0-9]{3}-?[89ab][a-f0-9]{3}-?[a-f0-9]{12}#[a-f0-9]{8}-?[a-f0-9]{4}-?4[a-f0-9]{3}-?[89ab][a-f0-9]{3}-?[a-f0-9]{12}").hasMatch(value)) {
                    return AppLocalizations.of(context)!.enterValidInviteID;
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
                            onPressed: () => _addExtWhiteboard(),
                            child: Text(AppLocalizations.of(context)!.importWhiteboard)))
                      ])),
    );
  }

  _addExtWhiteboard() async {
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate()) {
      // If the form is valid, display a snackbar. In the real world,
      // you'd often call a server or save the information in a database.
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.tryingJoin)));
      try {
        String inviteId = nameController.text;
        List splitInviteId = inviteId.split("#");
        http.Response response = await http.post(
            Uri.parse((settingsStorage.getItem("REST_API_URL") ?? dotenv.env['REST_API_URL']!) +
                "/filemanager-ext/whiteboard/create"),
            headers: {
              "content-type": "application/json",
              "accept": "application/json",
              'Authorization': 'Bearer ' + widget.authToken,
            },
            body: jsonEncode({
              'id': splitInviteId[0],
              'directory': widget.directory,
              'permission_id': splitInviteId[1]
            }));
        print(splitInviteId[0]);
        print(splitInviteId[1]);
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
  }
}
