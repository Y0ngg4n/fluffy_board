import 'dart:convert';

import 'package:fluffy_board/utils/theme_data_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:localstorage/localstorage.dart';

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return (Scaffold(
        appBar: AppBar(
          title: Text("Login"),
          actions: [
            PopupMenuButton(
              itemBuilder: (context) {
                return [PopupMenuItem(child: Text("Change server"), value: 0)];
              },
              onSelected: (value) {
                switch (value) {
                  case 0:
                    Navigator.pushNamed(context, "/server-settings");
                }
              },
            )
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                if (constraints.maxWidth > 600) {
                  return (FractionallySizedBox(
                      widthFactor: 0.5, child: LoginForm()));
                } else {
                  return (LoginForm());
                }
              },
            ),
          ),
        )));
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();
  final LocalStorage settingsStorage = new LocalStorage('settings');
  final LocalStorage storage = new LocalStorage('account');

  _showError() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error while login you in!"),
        backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              autofocus: true,
              controller: emailController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  icon: Icon(Icons.email_outlined),
                  hintText: "Enter your Email",
                  labelText: "Email"),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              onFieldSubmitted: (value) => _login(),
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  icon: Icon(Icons.password_outlined),
                  hintText: "Enter your Password",
                  labelText: "Password"),
            ),
          ),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: FutureBuilder(
                  future: storage.ready,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.data == null) {
                      return Center(child: CircularProgressIndicator());
                    }
                    return (ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          textStyle: TextStyle(fontSize: 20),
                          minimumSize: const Size(
                              double.infinity, 60)),
                        onPressed: () => _login(),
                        child: Text("Login")));
                  })),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Don`t have an account?'),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: OutlinedButton(
                    child: Text('Register'),
                    onPressed: () =>
                        {Navigator.pushReplacementNamed(context, '/register')},
                  ),
                )
              ],
            ),
          ),
        ],
      )),
    );
  }

  _login() async {
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate()) {
      // If the form is valid, display a snackbar. In the real world,
      // you'd often call a server or save the information in a database.
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Trying to login ...')));
      try {
        http.Response response = await http.post(
            Uri.parse((settingsStorage.getItem("REST_API_URL") ??
                    dotenv.env['REST_API_URL']!) +
                "/account/login"),
            headers: {
              "content-type": "application/json",
              "accept": "application/json",
            },
            body: jsonEncode({
              'email': emailController.text,
              'password': passwordController.text,
            }));
        if (response.statusCode == 200) {
          Map<String, dynamic> body =
              jsonDecode(utf8.decode(response.bodyBytes));
          await storage.setItem("auth_token", body['auth_token']);
          await storage.setItem("id", body['id']);
          await storage.setItem("email", body['email']);
          await storage.setItem("username", body['name']);
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          print(response.body);
          _showError();
        }
      } catch (e) {
        print(e);
        _showError();
      }
    }
  }
}
