import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EditAccount extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Edit Account")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                if (constraints.maxWidth > 600) {
                  return (FractionallySizedBox(
                      widthFactor: 0.5, child: EditAccountForm()));
                } else {
                  return (EditAccountForm());
                }
              },
            ),
          ),
        ));
  }
}

class EditAccountForm extends StatefulWidget {

  @override
  _EditAccountFormState createState() => _EditAccountFormState();
}

class _EditAccountFormState extends State<EditAccountForm> {
  final LocalStorage accountStorage = new LocalStorage('account');
  final LocalStorage settingsStorage = new LocalStorage('settings');
  final LocalStorage fileManagerStorageIndex =
  new LocalStorage('filemanager-index');
  final LocalStorage fileManagerStorage = new LocalStorage('filemanager');
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = new TextEditingController();

  _showError() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Could not change username"),
        backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: SingleChildScrollView(
            child: FutureBuilder(
                future: accountStorage.ready,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.data == null) {
                    return Center(child: CircularProgressIndicator());
                  }
                  String authToken =
                      accountStorage.getItem("auth_token") ?? "";
                  String email = accountStorage.getItem("email") ?? "";
                  String username = accountStorage.getItem("username") ?? "";
                  usernameController.text = username;
                  return (Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        TextFormField(
                            controller: usernameController,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                icon: Icon(Icons.person_outlined),
                                hintText: "Enter your new Username",
                                labelText: "New Username")),
                        Padding(
                            padding: const EdgeInsets.all(16),
                            child: ElevatedButton(
                                onPressed: () async {
                                  // Validate returns true if the form is valid, or false otherwise.
                                  if (_formKey.currentState!.validate()) {
                                    // If the form is valid, display a snackbar. In the real world,
                                    // you'd often call a server or save the information in a database.
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Saving ...')));
                                    try {
                                      http.Response response = await http.post(
                                          Uri.parse((settingsStorage.getItem(
                                                      "REST_API_URL") ??
                                                  dotenv.env['REST_API_URL']!) +
                                              "/account/update/username"),
                                          headers: {
                                            "content-type": "application/json",
                                            "accept": "application/json",
                                            'Authorization':
                                                'Bearer ' + authToken,
                                          },
                                          body: jsonEncode({
                                            'name': usernameController.text,
                                            'email': email,
                                          }));
                                      if (response.statusCode == 200) {
                                        await accountStorage.setItem("username",
                                            usernameController.text);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content:
                                                    Text('Username updated'),
                                                backgroundColor: Colors.green));
                                      } else {
                                        _showError();
                                      }
                                    } catch (e) {
                                      print(e);
                                      _showError();
                                    }
                                  }
                                },
                                child: Text("Save Username"))),
                        Divider(),
                        Card(
                          color: Colors.redAccent,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                            child: ElevatedButton(
                              style: ButtonStyle(backgroundColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                      (Set<MaterialState> states) {
                                return Colors.red;
                              })),
                              onPressed: () {_deleteAccountDialog(authToken);},
                              child: Text("Delete account"),
                            ),
                          ),
                        )
                      ]));
                })));
  }

  _deleteAccountDialog(String authToken){
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            backgroundColor: Colors.redAccent,
            title: Text('Delete your Whiteboards first!!! Please Confirm Account deletion.'),
            content: Text('This will not delete your whiteboards!!! Please delete them manually!!! Are you sure you want to delete your Account?'),
            actions: [
              TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    http.Response deleteResponse = await http.post(
                        Uri.parse((settingsStorage.getItem("REST_API_URL") ?? dotenv.env['REST_API_URL']!) +
                            "/account/delete"),
                        headers: {
                          "content-type": "application/json",
                          "accept": "application/json",
                          "charset": "utf-8",
                          'Authorization': 'Bearer ' + authToken,
                        },
                    );
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Trying to delete your account ..."),
                    ));
                    if(deleteResponse.statusCode == 200){
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Successfully deleted your account"), backgroundColor: Colors.green,
                      ));
                      await accountStorage.ready;
                      accountStorage.clear();
                      await fileManagerStorage.ready;
                      await fileManagerStorageIndex.ready;
                      fileManagerStorage.clear();
                      fileManagerStorageIndex.clear();
                      Navigator.of(context).pushReplacementNamed('/login');
                    }
                  },
                  child: Text('Yes')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('No'))
            ],
          );
        });
  }
}
