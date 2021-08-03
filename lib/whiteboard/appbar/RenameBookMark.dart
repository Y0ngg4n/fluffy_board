import 'dart:convert';

import 'package:fluffy_board/whiteboard/whiteboard-data/bookmark.dart';
import 'package:fluffy_board/whiteboard/whiteboard-data/json_encodable.dart';
import 'package:fluffy_board/whiteboard/Websocket/WebsocketConnection.dart';
import 'package:fluffy_board/whiteboard/Websocket/WebsocketSend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:localstorage/localstorage.dart';
import 'package:uuid/uuid.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RenameBookmark extends StatefulWidget {
  String auth_token;
  bool online;
  WebsocketConnection? websocketConnection;
  RefreshController refreshController;
  Bookmark bookmark;

  RenameBookmark(this.auth_token, this.online, this.websocketConnection,
      this.refreshController, this.bookmark);

  @override
  _RenameBookmarkState createState() => _RenameBookmarkState();
}

class _RenameBookmarkState extends State<RenameBookmark> {
  @override
  Widget build(BuildContext context) {
    return (Scaffold(
        appBar: AppBar(
          title: Text("Rename Bookmark"),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                if (constraints.maxWidth > 600) {
                  return (FractionallySizedBox(
                      widthFactor: 0.5,
                      child: RenameBookmarkForm(
                          widget.auth_token,
                          widget.online,
                          widget.websocketConnection,
                          widget.refreshController, widget.bookmark)));
                } else {
                  return (RenameBookmarkForm(
                      widget.auth_token,
                      widget.online,
                      widget.websocketConnection,
                      widget.refreshController, widget.bookmark));
                }
              },
            ),
          ),
        )));
  }
}

class RenameBookmarkForm extends StatefulWidget {
  String auth_token;
  bool online;
  WebsocketConnection? websocketConnection;
  RefreshController refreshController;
  Bookmark bookmark;

  RenameBookmarkForm(this.auth_token, this.online, this.websocketConnection,
      this.refreshController, this.bookmark);

  @override
  _RenameBookmarkFormState createState() => _RenameBookmarkFormState();
}

class _RenameBookmarkFormState extends State<RenameBookmarkForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = new TextEditingController();
  final LocalStorage storage = new LocalStorage('account');
  final LocalStorage fileManagerStorage = new LocalStorage('filemanager');
  var uuid = Uuid();

  _showError() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error while adding Bookmark! Please try an other Name."),
        backgroundColor: Colors.red));
  }

  @override
  void initState() {
    nameController.text = widget.bookmark.name;
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
              onFieldSubmitted: (value) => _renameBookmark(widget.bookmark),
              controller: nameController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  icon: Icon(Icons.email_outlined),
                  hintText: "Enter your Bookmark Name",
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
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                    onPressed: () => _renameBookmark(widget.bookmark),
                    child: Text("Rename Bookmark")))
          ])),
    );
  }

  _renameBookmark(Bookmark bookmark) async {
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate()) {
      // If the form is valid, display a snackbar. In the real world,
      // you'd often call a server or save the information in a database.
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Trying to create bookmark ...')));
      if (widget.online && widget.websocketConnection != null) {
        bookmark.name = nameController.text;
        WebsocketSend.sendBookmarkUpdate(bookmark, widget.websocketConnection);
        Navigator.pop(context);
        widget.refreshController.requestRefresh();
      }
    }
  }
}
