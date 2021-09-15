import 'package:fluffy_board/utils/theme_data_utils.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:localstorage/localstorage.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'file_manager_types.dart';

class RenameOfflineWhiteboard extends StatefulWidget {
  final OfflineWhiteboard offlineWhiteboard;
  final RefreshController _refreshController;

  RenameOfflineWhiteboard(this.offlineWhiteboard, this._refreshController);

  @override
  _RenameOfflineWhiteboardState createState() => _RenameOfflineWhiteboardState();
}

class _RenameOfflineWhiteboardState extends State<RenameOfflineWhiteboard> {
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
                      child: RenameOfflineWhiteboardForm(
                        widget.offlineWhiteboard,
                          widget._refreshController)));
                } else {
                  return (RenameOfflineWhiteboardForm(
                      widget.offlineWhiteboard,
                      widget._refreshController));
                }
              },
            ),
          ),
        )));
  }
}

class RenameOfflineWhiteboardForm extends StatefulWidget {
  final OfflineWhiteboard offlineWhiteboard;
  final RefreshController _refreshController;

  RenameOfflineWhiteboardForm(this.offlineWhiteboard, this._refreshController);

  @override
  _RenameOfflineWhiteboardFormState createState() => _RenameOfflineWhiteboardFormState();
}

class _RenameOfflineWhiteboardFormState extends State<RenameOfflineWhiteboardForm> {
  final _formKey = GlobalKey<FormState>();
  final LocalStorage settingsStorage = new LocalStorage('settings');
  final TextEditingController nameController = new TextEditingController();
  final LocalStorage fileManagerStorage = new LocalStorage('filemanager');

  _showError() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.errorRenameWhiteboard),
        backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    nameController.text = widget.offlineWhiteboard.name;
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
            TextFormField(
              onFieldSubmitted: (value) => _renameOfflineWhiteboard(),
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
                  style: ThemeDataUtils.getFullWithElevatedButtonStyle(),
                    onPressed: () => _renameOfflineWhiteboard(),
                    child: Text(AppLocalizations.of(context)!.renameWhiteboard)))
          ])),
    );
  }

  _renameOfflineWhiteboard() async{
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate()) {
      // If the form is valid, display a snackbar. In the real world,
      // you'd often call a server or save the information in a database.
      widget.offlineWhiteboard.name = nameController.text;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.tryingRenameWhiteboard)));
      try {
        await fileManagerStorage.setItem("offline_whiteboard-" + widget.offlineWhiteboard.uuid,
            widget.offlineWhiteboard.toJSONEncodable());
        widget._refreshController.requestRefresh();
        Navigator.pop(context);
      } catch (e) {
        print(e);
        _showError();
      }
    }
  }
}
