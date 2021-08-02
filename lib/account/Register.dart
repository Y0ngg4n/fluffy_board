import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:localstorage/localstorage.dart';
import 'package:url_launcher/url_launcher.dart';

class Register extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return (Scaffold(
        appBar: AppBar(
          title: Text("Register"),
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
  final TextStyle defaultStyle = TextStyle(color: Colors.grey);
  final TextStyle linkStyle = TextStyle(color: Colors.blue);

  final TextEditingController usernameController = new TextEditingController();
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();
  final LocalStorage storage = new LocalStorage('account');
  final LocalStorage settingsStorage = new LocalStorage('settings');

  _showError() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            "Error while registering your account! Please try an other Email."),
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
              controller: usernameController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  icon: Icon(Icons.person_outlined),
                  hintText: "Enter your Username",
                  labelText: "Username"),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a Username';
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: emailController,
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
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              onFieldSubmitted: (value) => _register(),
              controller: passwordController,
              obscureText: true,
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
                            launch(
                                "https://www.app-privacy-policy.com/live.php?token=R3OKXP0yWoKDwrnbBxRu6izDQKXZOpIB");
                          }),
                    TextSpan(text: ' and agree that you have read our '),
                    TextSpan(
                        text: 'Privacy Policy',
                        style: linkStyle,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            print('Privacy Policy"');
                            launch(
                                "https://www.app-privacy-policy.com/live.php?token=5xqgiUqBX8rTmLGwsGUjUW5tIZ1Cc38T");
                          }),
                  ],
                ),
              )),
          Padding(
              padding: const EdgeInsets.all(16),
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
                        onPressed: () => _register(), child: Text("Register")));
                  })),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Allready have an account? '),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: OutlinedButton(
                      child: Text('Login'),
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/login')),
                ),
              ],
            ),
          ),
        ],
      )),
    );
  }

  _register() async {
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate()) {
      // If the form is valid, display a snackbar. In the real world,
      // you'd often call a server or save the information in a database.
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Creating your Account ...')));
      try {
        http.Response response = await http.post(
            Uri.parse((settingsStorage.getItem("REST_API_URL") ??
                    dotenv.env['REST_API_URL']!) +
                "/account/register"),
            headers: {
              "content-type": "application/json",
              "accept": "application/json",
            },
            body: jsonEncode({
              'name': usernameController.text,
              'email': emailController.text,
              'password': passwordController.text,
            }));
        if (response.statusCode == 200) {
          Map<String, dynamic> body =
              jsonDecode(utf8.decode(response.bodyBytes));
          await storage.setItem("auth_token", body['auth_token']);
          await storage.setItem("id", body['id']);
          await storage.setItem("username", usernameController.text);
          await storage.setItem("email", emailController.text);
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          print(response.body);
          _showError();
        }
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error creating account!")));
      }
    }
  }
}
