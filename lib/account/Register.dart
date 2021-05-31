import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  @override
  Widget build(BuildContext context) {
    return (Scaffold(
        appBar: AppBar(
          title: Text("Register"),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                if (constraints.maxWidth > 600) {
                  return (FractionallySizedBox(
                      widthFactor: 0.5, child: RegisterForm()));
                } else {
                  return (RegisterForm());
                }
              },
            ),
          ),
        )));
  }
}

class RegisterForm extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
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
                hintText: "Enter your Username",
                labelText: "Username"),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a Username';
              }
              return null;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                icon: Icon(Icons.email_outlined),
                hintText: "Enter your Email",
                labelText: "Email"),
            validator: (value) {
              if (value == null ||
                  value.isEmpty ||
                  !EmailValidator.validate(value)) {
                return 'Please enter a correct Email';
              }
              return null;
            },
          ),
          TextFormField(
            controller: passwordController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                icon: Icon(Icons.password_outlined),
                hintText: "Enter your Password",
                labelText: "Password"),
            validator: (value) {
              if (value == null ||
                  value.isEmpty ||
                  !RegExp(r"^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z]).{8,}$")
                      .hasMatch(value)) {
                return 'Please make shure you password is at least 8 Characters long and contains lowercase and uppercase letters';
              }
              return null;
            },
          ),
          // FlutterPwValidator(
          //   controller: passwordController,
          //   minLength: 8,
          //   uppercaseCharCount: 1,
          //   numericCharCount: 1,
          //   width: 400,
          //   height: 150,
          //   onSuccess: () {},
          // ),
          Padding(
              padding: const EdgeInsets.all(16),
              child: RichText(
                text: TextSpan(
                  style: defaultStyle,
                  children: <TextSpan>[
                    TextSpan(text: 'By clicking Register you agree to our '),
                    TextSpan(
                        text: 'Terms of Service',
                        style: linkStyle,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            print('Terms of Service"');
                          }),
                    TextSpan(text: ' and agree that you have read our '),
                    TextSpan(
                        text: 'Privacy Policy',
                        style: linkStyle,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            print('Privacy Policy"');
                          }),
                  ],
                ),
              )),
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
                  TextSpan(text: 'Allready have an account? '),
                  TextSpan(
                      text: 'Login here.',
                      style: linkStyle,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          print('Login');
                          Navigator.pushReplacementNamed(context, '/login');
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
