import 'dart:convert';

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

  @override
  Widget build(BuildContext context) {
    TextStyle defaultStyle = TextStyle(color: Colors.grey);
    TextStyle linkStyle = TextStyle(color: Colors.blue);
    final TextEditingController emailController = new TextEditingController();
    final TextEditingController passwordController =
        new TextEditingController();
    final LocalStorage storage = new LocalStorage('account');

    _showError(){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
              Text("Error while login you in!"), backgroundColor: Colors.red));
    }

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: emailController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                icon: Icon(Icons.email_outlined),
                hintText: "Enter your Email",
                labelText: "Email"),
          ),
          TextFormField(
            controller: passwordController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                icon: Icon(Icons.password_outlined),
                hintText: "Enter your Password",
                labelText: "Password"),
          ),
          Padding(
              padding: const EdgeInsets.all(16),
              child: FutureBuilder(
                  future: storage.ready,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.data == null) {
                      return Center(child: CircularProgressIndicator());
                    }
                    return (ElevatedButton(
                        onPressed: () async {
                          // Validate returns true if the form is valid, or false otherwise.
                          if (_formKey.currentState!.validate()) {
                            // If the form is valid, display a snackbar. In the real world,
                            // you'd often call a server or save the information in a database.
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Trying to login ...')));
                            try {
                              http.Response response = await http.post(
                                  Uri.parse(dotenv.env['REST_API_URL']! +
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
                                await storage.setItem(
                                    "auth_token", body['auth_token']);
                                await storage.setItem(
                                    "id", body['id']);
                                await storage.setItem("email", body['email']);
                                await storage.setItem("username", body['name']);
                                Navigator.pushReplacementNamed(
                                    context, '/dashboard');
                              }else{
                                _showError();
                              }
                            } catch (e) {
                              print(e);
                              _showError();
                            }
                          }
                        },
                        child: Text("Login")));
                  })),
          Padding(
            padding: const EdgeInsets.all(16),
            child: RichText(
              text: TextSpan(
                style: defaultStyle,
                children: <TextSpan>[
                  TextSpan(text: 'Don`t have an account? '),
                  TextSpan(
                      text: 'Register here.',
                      style: linkStyle,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          print('Login');
                          Navigator.pushReplacementNamed(context, '/register');
                        }),
                ],
              ),
            ),
          ),
        ],
      )),
    );
  }
}
