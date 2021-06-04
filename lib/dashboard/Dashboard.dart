import 'dart:convert';
import 'dart:developer';
import 'dart:math';

import 'package:fluffy_board/dashboard/AvatarIcon.dart';
import 'package:fluffy_board/dashboard/filemanager/FileManager.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'ActionButtons.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final LocalStorage accountStorage = new LocalStorage('account');
  bool storageReady = false;
  bool checkedLogin = false;
  bool loggedIn = false;
  late String auth_token;

  @override
  void initState() {
    super.initState();
    accountStorage.ready.then((value) async => {_setStorageReady()});
  }

  @override
  Widget build(BuildContext context) {
    const name = "Dashboard";

    if (!checkedLogin && !storageReady || (!checkedLogin && !storageReady && !loggedIn)) return (_loading(name));
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!loggedIn) Navigator.pushReplacementNamed(context, '/login');
    });
    return (Scaffold(
      appBar:
          AppBar(title: Text(name), actions: [ActionButtons(), AvatarIcon()]),
      body: Container(
        child: FileManager(auth_token),
      ),
    ));
  }

  Future<void> afterFirstLayout(BuildContext context) async {}

  Widget _loading(String name) {
    return (Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Center(child: CircularProgressIndicator()),
    ));
  }

  _setStorageReady() {
    auth_token = accountStorage.getItem("auth_token");
    setState(() {
      storageReady = true;
      this.auth_token = auth_token;
    });
    _checkLoggedIn(auth_token);
  }

  Future _checkLoggedIn(String auth_token) async {
    http.Response response = await http.get(
        Uri.parse(dotenv.env['REST_API_URL']! + "/account/check"),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          'Authorization': 'Bearer ' + auth_token,
        });
    setState(() {
      checkedLogin = true;
      loggedIn = response.statusCode == 200 ? true : false;
    });
  }
}
