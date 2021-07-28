import 'package:fluffy_board/dashboard/filemanager/AddFolder.dart';
import 'package:fluffy_board/documentation/FileManagerIntroduction.dart';
import 'package:fluffy_board/whiteboard/WhiteboardView.dart';
import 'package:flutter/material.dart';

import 'account/Login.dart';
import 'account/Register.dart';
import 'dashboard/Dashboard.dart';
import 'dashboard/EditAccount.dart';
import 'dashboard/ServerSettings.dart';
import 'dashboard/filemanager/AddFolder.dart';
import 'documentation/About.dart';
import 'whiteboard/InfiniteCanvas.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  print(dotenv.env['REST_API_URL']);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return buildMaterialApp('/about');
  }
}

Widget buildMaterialApp(String initialRoute) {
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
      '/about': (context) => About(),
      '/intro': (context) => FileManagerIntroduction(),
      '/register': (context) => Register(),
      '/login': (context) => Login(),
      '/dashboard': (context) => Dashboard(),
      '/edit-account': (context) => EditAccount(),
      '/server-settings': (context) => ServerSettings(),
    },
    initialRoute: initialRoute,
  );
}
