import 'dart:convert';

import 'package:fluffy_board/utils/theme_data_utils.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddWhiteboard extends StatefulWidget {
  final String authToken;
  final String directory;
  final RefreshController _refreshController;

  AddWhiteboard(this.authToken, this.directory, this._refreshController);

  @override
  _AddWhiteboardState createState() => _AddWhiteboardState();
}

class _AddWhiteboardState extends State<AddWhiteboard> {
  @override
  Widget build(BuildContext context) {
    return (Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.createWhiteboard),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                if (constraints.maxWidth > 600) {
                  return (FractionallySizedBox(
                      widthFactor: 0.5, child: AddWhiteboardForm(widget.authToken,
                      widget.directory, widget._refreshController)));
                } else {
                  return (AddWhiteboardForm(widget.authToken,
                  widget.directory,widget._refreshController));
                }
              },
            ),
          ),
        )));
  }
}

class AddWhiteboardForm extends StatefulWidget {
  final String authToken;
  final String directory;
  final RefreshController _refreshController;

  AddWhiteboardForm(this.authToken, this.directory, this._refreshController);

  @override
  _AddWhiteboardFormState createState() => _AddWhiteboardFormState();
}

class _AddWhiteboardFormState extends State<AddWhiteboardForm> {
  final _formKey = GlobalKey<FormState>();
  final LocalStorage settingsStorage = new LocalStorage('settings');

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
                onFieldSubmitted: (value) => _addWhiteboard(),
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
                  }else if(value.length > 50){
                    return AppLocalizations.of(context)!.nameSmaller;
                  }
                  return null;
                },
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
                       child: ElevatedButton(
                         style: ThemeDataUtils.getFullWithElevatedButtonStyle(),
                            onPressed: () => _addWhiteboard(),
                            child: Text(AppLocalizations.of(context)!.createWhiteboard)))
                      ])),
    );
  }

  _addWhiteboard() async{
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate()) {
      // If the form is valid, display a snackbar. In the real world,
      // you'd often call a server or save the information in a database.
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.tryingCreateWhiteboard)));
      try {
        http.Response response = await http.post(
            Uri.parse((settingsStorage.getItem("REST_API_URL") ?? dotenv.env['REST_API_URL']!) +
                "/filemanager/whiteboard/create"),
            headers: {
              "content-type": "application/json",
              "accept": "application/json",
              'Authorization': 'Bearer ' + widget.authToken,
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
  }
}
