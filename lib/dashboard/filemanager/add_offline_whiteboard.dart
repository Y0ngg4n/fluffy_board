import 'dart:convert';

import 'package:fluffy_board/whiteboard/whiteboard-data/bookmark.dart';
import 'package:fluffy_board/whiteboard/whiteboard-data/scribble.dart';
import 'package:fluffy_board/whiteboard/whiteboard-data/textitem.dart';
import 'package:fluffy_board/whiteboard/whiteboard-data/upload.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:localstorage/localstorage.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

import 'file_manager_types.dart';

class AddOfflineWhiteboard extends StatefulWidget {
  final String authToken;
  final String directory;
  final OfflineWhiteboards offlineWhiteboards;
  final Set<String> offlineWhiteboardIds;
  final RefreshController _refreshController;

  AddOfflineWhiteboard(this.authToken, this.directory, this._refreshController,
      this.offlineWhiteboards, this.offlineWhiteboardIds);

  @override
  _AddOfflineWhiteboardState createState() => _AddOfflineWhiteboardState();
}

class _AddOfflineWhiteboardState extends State<AddOfflineWhiteboard> {
  @override
  Widget build(BuildContext context) {
    return (Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.createOfflineWhiteboard),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                if (constraints.maxWidth > 600) {
                  return (FractionallySizedBox(
                      widthFactor: 0.5,
                      child: AddOfflineWhiteboardForm(
                          widget.authToken,
                          widget.directory,
                          widget._refreshController,
                          widget.offlineWhiteboards,
                          widget.offlineWhiteboardIds)));
                } else {
                  return (AddOfflineWhiteboardForm(
                      widget.authToken,
                      widget.directory,
                      widget._refreshController,
                      widget.offlineWhiteboards,
                      widget.offlineWhiteboardIds));
                }
              },
            ),
          ),
        )));
  }
}

class AddOfflineWhiteboardForm extends StatefulWidget {
  final String authToken;
  final String directory;
  final RefreshController _refreshController;
  final OfflineWhiteboards offlineWhiteboards;
  final Set<String> offlineWhiteboardIds;

  AddOfflineWhiteboardForm(
      this.authToken,
      this.directory,
      this._refreshController,
      this.offlineWhiteboards,
      this.offlineWhiteboardIds);

  @override
  _AddOfflineWhiteboardFormState createState() =>
      _AddOfflineWhiteboardFormState();
}

class _AddOfflineWhiteboardFormState extends State<AddOfflineWhiteboardForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = new TextEditingController();
  var uuid = Uuid();
  final LocalStorage fileManagerStorageIndex =
      new LocalStorage('filemanager-index');
  final LocalStorage fileManagerStorage = new LocalStorage('filemanager');

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
            TextFormField(
              onFieldSubmitted: (value) => _addOfflineWhiteboard(),
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
                padding: EdgeInsets.fromLTRB(0, 16, 0, 8),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      textStyle: TextStyle(fontSize: 20),
                      minimumSize: const Size(
                          double.infinity, 60)),
                    onPressed: () => _addOfflineWhiteboard(),
                    child: Text(AppLocalizations.of(context)!.createOfflineWhiteboard)))
          ])),
    );
  }

  _addOfflineWhiteboard() async {
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate()) {
      // If the form is valid, display a snackbar. In the real world,
      // you'd often call a server or save the information in a database.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.tryingCreateWhiteboard)));
      OfflineWhiteboard offlineWhiteboard = new OfflineWhiteboard(
          uuid.v4(),
          widget.directory,
          nameController.text,
          new Uploads([]),
          new TextItems([]),
          new Scribbles([]),
          new Bookmarks([]), Offset.zero, 1);

      widget.offlineWhiteboards.list.add(offlineWhiteboard);
      await fileManagerStorage.setItem("offline_whiteboard-" + offlineWhiteboard.uuid,
          offlineWhiteboard.toJSONEncodable());
      for (OfflineWhiteboard offWhi in widget.offlineWhiteboards.list) {
        widget.offlineWhiteboardIds.add(offWhi.uuid);
      }
      await fileManagerStorageIndex.setItem(
          "indexes", jsonEncode(widget.offlineWhiteboardIds.toList()));
      Navigator.pop(context);
      widget._refreshController.requestRefresh();
    }
  }
}
