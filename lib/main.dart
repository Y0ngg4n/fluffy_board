import 'package:flutter/material.dart';

import 'account/Login.dart';
import 'account/Register.dart';
import 'dashboard/Dashboard.dart';
import 'dashboard/EditAccount.dart';
import 'whiteboard/InfiniteCanvas.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future main() async{
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/register': (context) => Register(),
        '/login': (context) => Login(),
        '/dashboard': (context) => Dashboard(),
        '/edit-account': (context) => EditAccount(),
      },
      initialRoute: '/dashboard',
    );
  }
}

