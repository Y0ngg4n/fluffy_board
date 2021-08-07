import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RenameFolder extends StatefulWidget {
  final String authToken;
  final String parent;
  final String id;
  final String currentName;
  final RefreshController _refreshController;

  RenameFolder(this.authToken, this.id, this.parent, this.currentName, this._refreshController);

  @override
  _RenameFolderState createState() => _RenameFolderState();
}

class _RenameFolderState extends State<RenameFolder> {
  @override
  Widget build(BuildContext context) {
    return (Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.renameFolder),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                if (constraints.maxWidth > 600) {
                  return (FractionallySizedBox(
                      widthFactor: 0.5,
                      child: RenameFolderForm(
                          widget.authToken,
                          widget.id,
                          widget.parent,
                          widget.currentName,
                          widget._refreshController)));
                } else {
                  return (RenameFolderForm(
                      widget.authToken,
                      widget.id,
                      widget.parent,
                      widget.currentName,
                      widget._refreshController));
                }
              },
            ),
          ),
        )));
  }
}

class RenameFolderForm extends StatefulWidget {
  final String authToken;
  final String parent;
  final String id;
  final String currentName;
  final RefreshController _refreshController;

  RenameFolderForm(
      this.authToken, this.id, this.parent, this.currentName, this._refreshController);

  @override
  _RenameFolderFormState createState() => _RenameFolderFormState();
}

class _RenameFolderFormState extends State<RenameFolderForm> {
  final _formKey = GlobalKey<FormState>();
  final LocalStorage settingsStorage = new LocalStorage('settings');

  final TextEditingController nameController = new TextEditingController();

  _showError() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.errorRenameFolder),
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
              onFieldSubmitted: (value) => _renameFolder(),
              controller: nameController,
              decoration: InputDecoration(
                  errorMaxLines: 5,
                  border: OutlineInputBorder(),
                  icon: Icon(Icons.email_outlined),
                  hintText: AppLocalizations.of(context)!.enterDirectoryName,
                  labelText: AppLocalizations.of(context)!.enterDirectoryName),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!.enterDirectoryName;
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
                    onPressed: () => _renameFolder(),
                    child: Text(AppLocalizations.of(context)!.renameFolder)))
          ])),
    );
  }

  _renameFolder() async {
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate()) {
      // If the form is valid, display a snackbar. In the real world,
      // you'd often call a server or save the information in a database.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.tryingRenameFolder)));
      try {
        http.Response response = await http.post(
            Uri.parse((settingsStorage.getItem("REST_API_URL") ?? dotenv.env['REST_API_URL']!) +
                "/filemanager/directory/rename"),
            headers: {
              "content-type": "application/json",
              "accept": "application/json",
              'Authorization':
              'Bearer ' + widget.authToken,
            },
            body: jsonEncode({
              'id': widget.id,
              'filename': nameController.text,
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
