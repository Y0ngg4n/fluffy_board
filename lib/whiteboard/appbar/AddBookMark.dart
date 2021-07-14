import 'dart:convert';

import 'package:fluffy_board/whiteboard/DrawPoint.dart';
import 'package:fluffy_board/whiteboard/Websocket/WebsocketConnection.dart';
import 'package:fluffy_board/whiteboard/Websocket/WebsocketSend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:localstorage/localstorage.dart';
import 'package:uuid/uuid.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AddBookmark extends StatefulWidget {
  String auth_token;
  bool online;
  WebsocketConnection? websocketConnection;
  Offset offset;
  double scale;
  RefreshController refreshController;

  AddBookmark(this.auth_token, this.online, this.websocketConnection,
      this.offset, this.scale, this.refreshController);

  @override
  _AddBookmarkState createState() => _AddBookmarkState();
}

class _AddBookmarkState extends State<AddBookmark> {
  @override
  Widget build(BuildContext context) {
    return (Scaffold(
        appBar: AppBar(
          title: Text("Add Bookmark"),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                if (constraints.maxWidth > 600) {
                  return (FractionallySizedBox(
                      widthFactor: 0.5,
                      child: AddBookmarkForm(
                          widget.auth_token,
                          widget.online,
                          widget.websocketConnection,
                          widget.offset,
                          widget.scale,
                          widget.refreshController)));
                } else {
                  return (AddBookmarkForm(
                      widget.auth_token,
                      widget.online,
                      widget.websocketConnection,
                      widget.offset,
                      widget.scale,
                      widget.refreshController));
                }
              },
            ),
          ),
        )));
  }
}

class AddBookmarkForm extends StatefulWidget {
  String auth_token;
  bool online;
  WebsocketConnection? websocketConnection;
  Offset offset;
  double scale;
  RefreshController refreshController;

  AddBookmarkForm(this.auth_token, this.online, this.websocketConnection,
      this.offset, this.scale, this.refreshController);

  @override
  _AddBookmarkFormState createState() => _AddBookmarkFormState();
}

class _AddBookmarkFormState extends State<AddBookmarkForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = new TextEditingController();
  final LocalStorage storage = new LocalStorage('account');
  final LocalStorage fileManagerStorage = new LocalStorage('filemanager');

  _showError() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error while adding Bookmark! Please try an other Name."),
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
              onFieldSubmitted: (value) => _addBookmark(),
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
                    onPressed: () => _addBookmark(),
                    child: Text("Create Bookmark")))
          ])),
    );
  }

  _addBookmark() async {
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate()) {
      // If the form is valid, display a snackbar. In the real world,
      // you'd often call a server or save the information in a database.
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Trying to create bookmark ...')));
      if (widget.online && widget.websocketConnection != null) {
        Bookmark bookmark = new Bookmark(
            uuid.v4(), nameController.text, widget.offset, widget.scale);
        WebsocketSend.sendBookmarkAdd(bookmark, widget.websocketConnection);
        widget.refreshController.requestRefresh();
        Navigator.pop(context);
      } else {
        // await storage.ready;
        //   widget.directories.list.add(new Directory(
        //       uuid.v4(),
        //       storage.getItem('id') ?? "",
        //       widget.parent,
        //       nameController.text,
        //       DateTime.now().millisecond));
        //   fileManagerStorage
        //       .setItem("directories", widget.directories.toJSONEncodable())
        //       .then((value) => {
        //     Navigator.pop(context),
        //     widget._refreshController.requestRefresh()
        //   });
        // }
      }
    }
  }
}
