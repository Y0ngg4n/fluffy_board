import 'package:fluffy_board/utils/theme_data_utils.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ServerSettings extends StatefulWidget {
  @override
  _ServerSettingsState createState() => _ServerSettingsState();
}

class _ServerSettingsState extends State<ServerSettings> {
  @override
  Widget build(BuildContext context) {
    return (Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.changeServer),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                if (constraints.maxWidth > 600) {
                  return (FractionallySizedBox(
                      widthFactor: 0.5, child: ServerSettingsForm()));
                } else {
                  return (ServerSettingsForm());
                }
              },
            ),
          ),
        )));
  }
}

class ServerSettingsForm extends StatefulWidget {
  @override
  _ServerSettingsFormState createState() => _ServerSettingsFormState();
}

class _ServerSettingsFormState extends State<ServerSettingsForm> {
  final LocalStorage settingsStorage = new LocalStorage('settings');
  final _formKey = GlobalKey<FormState>();
  final TextEditingController restApiController = new TextEditingController();
  final TextEditingController websocketController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: SingleChildScrollView(
            child: FutureBuilder(
                future: settingsStorage.ready,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.data == null) {
                    return Center(child: CircularProgressIndicator());
                  }
                  String restAPI =
                      settingsStorage.getItem("REST_API_URL") ?? "";
                  String wsAPI = settingsStorage.getItem("WS_API_URL") ?? "";
                  restApiController.text = restAPI;
                  websocketController.text = wsAPI;
                  return (Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        TextFormField(
                            controller: restApiController,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                icon: Icon(Icons.person_outlined),
                                hintText: AppLocalizations.of(context)!.restURL,
                                labelText:
                                    AppLocalizations.of(context)!.restURL)),
                        TextFormField(
                            controller: websocketController,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                icon: Icon(Icons.person_outlined),
                                hintText: AppLocalizations.of(context)!.wsURL,
                                labelText:
                                    AppLocalizations.of(context)!.wsURL)),
                        Padding(
                            padding: const EdgeInsets.all(16),
                            child: ElevatedButton(
                                style: ThemeDataUtils.getFullWithElevatedButtonStyle(),
                                onPressed: () async {
                                  // Validate returns true if the form is valid, or false otherwise.
                                  if (_formKey.currentState!.validate()) {
                                    // If the form is valid, display a snackbar. In the real world,
                                    // you'd often call a server or save the information in a database.
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                AppLocalizations.of(context)!
                                                    .saving)));
                                    await settingsStorage.setItem(
                                        "REST_API_URL", restApiController.text);
                                    await settingsStorage.setItem(
                                        "WS_API_URL", websocketController.text);
                                    Navigator.pushReplacementNamed(
                                        context, "/login");
                                  }
                                },
                                child: Text(AppLocalizations.of(context)!
                                    .changeServer)))
                      ]));
                })));
  }
}
