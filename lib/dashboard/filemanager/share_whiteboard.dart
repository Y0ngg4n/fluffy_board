import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:mailto/mailto.dart';

// For Flutter applications, you'll most likely want to use
// the url_launcher package.
import 'package:url_launcher/url_launcher.dart';

class ShareWhiteboard extends StatefulWidget {
  String auth_token;
  String username;
  String id;
  String name;
  String directory;
  String view_id;
  String edit_id;
  RefreshController _refreshController;

  ShareWhiteboard(this.auth_token, this.username, this.id, this.name,
      this.directory, this.view_id, this.edit_id, this._refreshController);

  @override
  _ShareWhiteboardState createState() => _ShareWhiteboardState();
}

class _ShareWhiteboardState extends State<ShareWhiteboard> {
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
                      widthFactor: 0.6,
                      child: ShareWhiteboardForm(
                          widget.auth_token,
                          widget.username,
                          widget.id,
                          widget.name,
                          widget.directory,
                          widget.view_id,
                          widget.edit_id,
                          widget._refreshController)));
                } else {
                  return (ShareWhiteboardForm(
                      widget.auth_token,
                      widget.username,
                      widget.id,
                      widget.name,
                      widget.directory,
                      widget.view_id,
                      widget.edit_id,
                      widget._refreshController));
                }
              },
            ),
          ),
        )));
  }
}

class ShareWhiteboardForm extends StatefulWidget {
  String auth_token;
  String username;
  String id;
  String name;
  String directory;
  String view_id;
  String edit_id;
  RefreshController _refreshController;

  ShareWhiteboardForm(this.auth_token, this.username, this.id, this.name,
      this.directory, this.view_id, this.edit_id, this._refreshController);

  @override
  _ShareWhiteboardFormState createState() => _ShareWhiteboardFormState();
}

class _ShareWhiteboardFormState extends State<ShareWhiteboardForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController viewController = new TextEditingController();
  final TextEditingController editController = new TextEditingController();

  _showError() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text("Error while sharing Whiteboard! Please try an other Name."),
        backgroundColor: Colors.red));
  }

  _copySuccess() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Copied to Clipboard'), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    viewController.text = widget.id + "#" + widget.view_id;
    editController.text = widget.id + "#" + widget.edit_id;

    return Form(
        key: _formKey,
        child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Share this Whiteboard",
                  style: TextStyle(fontSize: 30),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                      controller: viewController,
                      readOnly: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        icon: Icon(Icons.visibility_outlined),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelText: "Readonly/View Invite",
                        suffixIcon: IconButton(
                            icon: Icon(Icons.content_copy),
                            onPressed: () {
                              Clipboard.setData(
                                  new ClipboardData(text: viewController.text));
                              _copySuccess();
                            }),
                      ))),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                    controller: editController,
                    readOnly: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      icon: Icon(Icons.edit_outlined),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: "Writable/Edit Invite",
                      suffixIcon: IconButton(
                          icon: Icon(Icons.content_copy),
                          onPressed: () {
                            Clipboard.setData(
                                new ClipboardData(text: editController.text));
                            _copySuccess();
                          }),
                    )),
              ),
              Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          textStyle: TextStyle(fontSize: 20),
                          minimumSize: const Size(double.infinity, 60)),
                      onPressed: () {
                        launchMailto(widget.id + "#" + widget.view_id);
                      },
                      child: Text("Share Readonly/View Invite via Email"))),
              Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          textStyle: TextStyle(fontSize: 20),
                          minimumSize: const Size(double.infinity, 60)),
                      onPressed: () {
                        launchMailto(widget.id + "#" + widget.edit_id);
                      },
                      child: Text("Share Writable/Edit Invite via Email")))
            ])));
  }

  launchMailto(String inviteCode) async {
    final mailtoLink = Mailto(
      to: [],
      cc: [],
      subject:
          '${widget.username} invites you to the ${widget.name} Whiteboard',
      body: 'Dear FluffyBoard User,\n ${widget.username} wants to invite you to the ${widget.name} Whiteboard.\n' +
          'You can join this clicking the \"Import Whiteboard\" button on your Dashboard.\n'
              'Then paste the following id: \n\n'
              '${inviteCode} \n\n'
              'and click the Button \"Import Whiteboard\".\n\n'
              'Congratulations. You have imported the Whiteboard successfull.',
    );
    // Convert the Mailto instance into a string.
    // Use either Dart's string interpolation
    // or the toString() method.
    await launch('$mailtoLink');
  }
}
