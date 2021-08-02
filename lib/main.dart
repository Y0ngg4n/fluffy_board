import 'package:fluffy_board/dashboard/filemanager/AddFolder.dart';
import 'package:fluffy_board/documentation/FileManagerIntroduction.dart';
import 'package:fluffy_board/utils/ThemeDataUtils.dart';
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
import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  print(dotenv.env['REST_API_URL']);
  runApp(EasyDynamicThemeWidget(child: FluffyboardApp()));
}

class FluffyboardApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return buildMaterialApp('/about', context);
    // return buildMaterialApp('/login', context);
  }
}

var lightThemeData = new ThemeData(
    brightness: Brightness.light,);

var darkThemeData = ThemeData(
    brightness: Brightness.dark,);

Widget buildMaterialApp(String initialRoute, context) {
  return MaterialApp(
    theme: lightThemeData,
    darkTheme: darkThemeData,
    themeMode: EasyDynamicTheme.of(context).themeMode,
    title: 'Flutter Demo',
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
