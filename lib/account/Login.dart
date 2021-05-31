import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
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
    final TextEditingController passwordController =
        new TextEditingController();

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
          TextFormField(
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
            child: ElevatedButton(
                onPressed: () {
                  // Validate returns true if the form is valid, or false otherwise.
                  if (_formKey.currentState!.validate()) {
                    // If the form is valid, display a snackbar. In the real world,
                    // you'd often call a server or save the information in a database.
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Creating your Account ...')));
                  }
                },
                child: Text("Register")),
          ),
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
                          print('Register');
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
