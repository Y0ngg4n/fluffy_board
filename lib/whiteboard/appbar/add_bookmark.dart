import 'package:fluffy_board/whiteboard/whiteboard-data/bookmark.dart';
import 'package:fluffy_board/whiteboard/websocket/websocket_connection.dart';
import 'package:fluffy_board/whiteboard/websocket/websocket_manager_send.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:uuid/uuid.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

typedef OnOfflineBookMarkAdd = Function(Bookmark);

class AddBookmark extends StatefulWidget {
  final String authToken;
  final bool online;
  final WebsocketConnection? websocketConnection;
  final Offset offset;
  final double scale;
  final RefreshController refreshController;
  final OnOfflineBookMarkAdd offlineBookMarkAdd;

  AddBookmark(this.authToken, this.online, this.websocketConnection,
      this.offset, this.scale, this.refreshController, this.offlineBookMarkAdd);

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
                          widget.authToken,
                          widget.online,
                          widget.websocketConnection,
                          widget.offset,
                          widget.scale,
                          widget.refreshController,
                          widget.offlineBookMarkAdd)));
                } else {
                  return (AddBookmarkForm(
                      widget.authToken,
                      widget.online,
                      widget.websocketConnection,
                      widget.offset,
                      widget.scale,
                      widget.refreshController,
                      widget.offlineBookMarkAdd));
                }
              },
            ),
          ),
        )));
  }
}

class AddBookmarkForm extends StatefulWidget {
  final String authToken;
  final bool online;
  final WebsocketConnection? websocketConnection;
  final Offset offset;
  final double scale;
  final RefreshController refreshController;
  final OnOfflineBookMarkAdd onOfflineBookMarkAdd;

  AddBookmarkForm(this.authToken, this.online, this.websocketConnection,
      this.offset, this.scale, this.refreshController,
      this.onOfflineBookMarkAdd);

  @override
  _AddBookmarkFormState createState() => _AddBookmarkFormState();
}

class _AddBookmarkFormState extends State<AddBookmarkForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = new TextEditingController();
  final LocalStorage storage = new LocalStorage('account');
  final LocalStorage fileManagerStorage = new LocalStorage('filemanager');

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
      Bookmark bookmark = new Bookmark(
          uuid.v4(), nameController.text, widget.offset, widget.scale);
      if (widget.online && widget.websocketConnection != null) {
        WebsocketSend.sendBookmarkAdd(bookmark, widget.websocketConnection);
      } else {
        widget.onOfflineBookMarkAdd(bookmark);
      }
        widget.refreshController.requestRefresh();
        Navigator.pop(context);
    }
  }
}
