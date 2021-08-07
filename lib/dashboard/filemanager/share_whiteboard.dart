
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:mailto/mailto.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// For Flutter applications, you'll most likely want to use
// the url_launcher package.
import 'package:url_launcher/url_launcher.dart';

class ShareWhiteboard extends StatefulWidget {
  final String authToken;
  final String username;
  final String id;
  final String name;
  final String directory;
  final String viewId;
  final String editId;

  ShareWhiteboard(this.authToken, this.username, this.id, this.name,
      this.directory, this.viewId, this.editId);

  @override
  _ShareWhiteboardState createState() => _ShareWhiteboardState();
}

class _ShareWhiteboardState extends State<ShareWhiteboard> {
  @override
  Widget build(BuildContext context) {
    return (Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.shareWhiteboard),
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
                          widget.authToken,
                          widget.username,
                          widget.id,
                          widget.name,
                          widget.directory,
                          widget.viewId,
                          widget.editId)));
                } else {
                  return (ShareWhiteboardForm(
                      widget.authToken,
                      widget.username,
                      widget.id,
                      widget.name,
                      widget.directory,
                      widget.viewId,
                      widget.editId
                  ));
                }
              },
            ),
          ),
        )));
  }
}

class ShareWhiteboardForm extends StatefulWidget {
  final String authToken;
  final String username;
  final String id;
  final String name;
  final String directory;
  final String viewId;
  final String editId;

  ShareWhiteboardForm(this.authToken, this.username, this.id, this.name,
      this.directory, this.viewId, this.editId);

  @override
  _ShareWhiteboardFormState createState() => _ShareWhiteboardFormState();
}

class _ShareWhiteboardFormState extends State<ShareWhiteboardForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController viewController = new TextEditingController();
  final TextEditingController editController = new TextEditingController();

  _copySuccess() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.copiedClipboard), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    viewController.text = widget.id + "#" + widget.viewId;
    editController.text = widget.id + "#" + widget.editId;

    return Form(
        key: _formKey,
        child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  AppLocalizations.of(context)!.shareWhiteboard,
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
                        labelText: AppLocalizations.of(context)!.readOnlyInvite,
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
                      labelText: AppLocalizations.of(context)!.writeInvite,
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
                        launchMailto(widget.id + "#" + widget.viewId);
                      },
                      child: Text(AppLocalizations.of(context)!.shareReadOnlyEmail))),
              Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          textStyle: TextStyle(fontSize: 20),
                          minimumSize: const Size(double.infinity, 60)),
                      onPressed: () {
                        launchMailto(widget.id + "#" + widget.editId);
                      },
                      child: Text(AppLocalizations.of(context)!.shareWriteEmail)))
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
              '$inviteCode \n\n'
              'and click the Button \"Import Whiteboard\".\n\n'
              'Congratulations. You have imported the Whiteboard successfull.',
    );
    // Convert the Mailto instance into a string.
    // Use either Dart's string interpolation
    // or the toString() method.
    await launch('$mailtoLink');
  }
}
