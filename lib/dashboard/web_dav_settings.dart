import 'package:fluffy_board/utils/theme_data_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localstorage/localstorage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'filemanager/web_dav_manager.dart';

class WebDavSettings extends StatefulWidget {
  @override
  _WebDavSettingsState createState() => _WebDavSettingsState();
}

class _WebDavSettingsState extends State<WebDavSettings> {
  @override
  Widget build(BuildContext context) {
    return (Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.changeWebDavSync),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                if (constraints.maxWidth > 600) {
                  return (FractionallySizedBox(
                      widthFactor: 0.5, child: WebDavSettingsForm()));
                } else {
                  return (WebDavSettingsForm());
                }
              },
            ),
          ),
        )));
  }
}

class WebDavSettingsForm extends StatefulWidget {
  @override
  _WebDavSettingsFormState createState() => _WebDavSettingsFormState();
}

class _WebDavSettingsFormState extends State<WebDavSettingsForm> {
  final LocalStorage settingsStorage = new LocalStorage('settings');
  final _formKey = GlobalKey<FormState>();
  final TextEditingController webDavURLController = new TextEditingController();
  final TextEditingController webDavPasswordController =
      new TextEditingController();
  final TextEditingController webDavUsernameController =
      new TextEditingController();
  final TextEditingController syncIntervalController =
      new TextEditingController();
  bool webDavEnabled = true;

  @override
  void initState() {
    super.initState();
    settingsStorage.ready.then((value) => {
          setState(() {
            webDavEnabled = settingsStorage.getItem("WEB_DAV_ENABLED") ?? true;
            String webDavURL = settingsStorage.getItem("WEB_DAV_URL") ?? "";
            String webDavUsername =
                settingsStorage.getItem("WEB_DAV_USERNAME") ?? "";
            String webDavPassword =
                settingsStorage.getItem("WEB_DAV_PASSWORD") ?? "";
            String syncInterval =
                settingsStorage.getItem("WEB_DAV_SYNC_INTERVAL") ?? "";
            webDavURLController.text = webDavURL;
            webDavUsernameController.text = webDavUsername;
            webDavPasswordController.text = webDavPassword;
            syncIntervalController.text = syncInterval;
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: SingleChildScrollView(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: <
                    Widget>[
          Text("Enable WebDav Sync"),
          Switch.adaptive(
            value: webDavEnabled,
            onChanged: (value) => setState(() {
              webDavEnabled = value;
            }),
          ),
          TextFormField(
              controller: webDavURLController,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  icon: Icon(Icons.person_outlined),
                  hintText: AppLocalizations.of(context)!.webDavURL,
                  labelText: AppLocalizations.of(context)!.webDavURL)),
          TextFormField(
              controller: webDavUsernameController,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  icon: Icon(Icons.person_outlined),
                  hintText: AppLocalizations.of(context)!.webDavUsername,
                  labelText: AppLocalizations.of(context)!.webDavUsername)),
          TextFormField(
              controller: webDavPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  icon: Icon(Icons.password_outlined),
                  hintText: AppLocalizations.of(context)!.webDavPassword,
                  labelText: AppLocalizations.of(context)!.webDavPassword)),
          TextFormField(
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              controller: syncIntervalController,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  icon: Icon(Icons.password_outlined),
                  hintText: AppLocalizations.of(context)!.webDavSyncInterval,
                  labelText: AppLocalizations.of(context)!.webDavSyncInterval)),
          Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                  style: ThemeDataUtils.getFullWithElevatedButtonStyle(),
                  onPressed: () async {
                    // Validate returns true if the form is valid, or false otherwise.
                    if (_formKey.currentState!.validate()) {
                      // If the form is valid, display a snackbar. In the real world,
                      // you'd often call a server or save the information in a database.
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text('Saving ...')));
                      await settingsStorage.setItem(
                          "WEB_DAV_ENABLED", webDavEnabled);
                      await settingsStorage.setItem(
                          "WEB_DAV_URL", webDavURLController.text);
                      await settingsStorage.setItem(
                          "WEB_DAV_USERNAME", webDavUsernameController.text);
                      await settingsStorage.setItem(
                          "WEB_DAV_PASSWORD", webDavPasswordController.text);
                      await settingsStorage.setItem(
                          "WEB_DAV_SYNC_INTERVAL", syncIntervalController.text);
                      Navigator.pop(context);
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.changeWebDavSync))),
          // TODO: Recursive restore
          ElevatedButton(
              style: ThemeDataUtils.getFullWithElevatedButtonStyle(),
              onPressed: () {
                WebDavManager.restoreFromWebDav();
              },
              child: Text("Restore"))
        ])));
  }
}
