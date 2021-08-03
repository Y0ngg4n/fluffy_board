import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ServerSettings extends StatefulWidget {

  @override
  _ServerSettingsState createState() => _ServerSettingsState();
}

class _ServerSettingsState extends State<ServerSettings> {
  @override
  Widget build(BuildContext context) {
    return (Scaffold(
        appBar: AppBar(
          title: Text("Change Server"),
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
                  String restAPI = settingsStorage.getItem("REST_API_URL") ?? "";
                  String wsAPI = settingsStorage.getItem("WS_API_URL") ?? "";
                  restApiController.text = restAPI;
                  websocketController.text = wsAPI;
                  return (
                      Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            TextFormField(
                                controller: restApiController,
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    icon: Icon(Icons.person_outlined),
                                    hintText: "Enter your REST API URL",
                                    labelText: "New Server")),
                            TextFormField(
                                controller: websocketController,
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    icon: Icon(Icons.person_outlined),
                                    hintText: "Enter your Websocket URL",
                                    labelText: "New Websocket")),
                            Padding(
                                padding: const EdgeInsets.all(16),
                                child: ElevatedButton(
                                    onPressed: () async {
                                      // Validate returns true if the form is valid, or false otherwise.
                                      if (_formKey.currentState!.validate()) {
                                        // If the form is valid, display a snackbar. In the real world,
                                        // you'd often call a server or save the information in a database.
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                            SnackBar(
                                                content: Text('Saving ...')));
                                        await settingsStorage.setItem("REST_API_URL", restApiController.text);
                                        await settingsStorage.setItem("WS_API_URL", websocketController.text);
                                        Navigator.pushReplacementNamed(context, "/login");
                                      }
                                    },
                                    child: Text("Save Server")))
                          ]));
                })));
  }
}