import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math';

import 'package:fluffy_board/dashboard/AvatarIcon.dart';
import 'package:fluffy_board/dashboard/filemanager/FileManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:ui';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'ActionButtons.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();

  static Widget loading(String name) {
    return (Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Center(child: CircularProgressIndicator()),
    ));
  }
}

class _DashboardState extends State<Dashboard> {
  final LocalStorage accountStorage = new LocalStorage('account');
  bool storageReady = false;
  bool checkedLogin = false;
  bool online = true;
  bool loggedIn = false;
  late String auth_token;
  late String username;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance!.addPostFrameCallback((_) => {
          accountStorage.ready.then((value) async => {_setStorageReady()})
        });
  }

  @override
  Widget build(BuildContext context) {
    const name = "Dashboard";

    if (!checkedLogin && !storageReady) return (Dashboard.loading(name));
    SchedulerBinding.instance!.addPostFrameCallback((_) => {
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (checkedLogin && !loggedIn && online)
              Navigator.pushReplacementNamed(context, '/login');
          })
        });
    if (!checkedLogin && !loggedIn && online) return (Dashboard.loading(name));
    return (Scaffold(
      appBar: AppBar(title: Text(name), actions: [AvatarIcon(online)]),
      body: Container(
        child: FileManager(auth_token, username, online),
      ),
    ));
  }

  Future<void> afterFirstLayout(BuildContext context) async {}

  _setStorageReady() {
    auth_token = accountStorage.getItem("auth_token");
    username = accountStorage.getItem("username");
    setState(() {
      this.storageReady = true;
      this.auth_token = auth_token;
      this.username = username;
    });
    _checkLoggedIn(auth_token);
  }

  Future _checkLoggedIn(String auth_token) async {
    print("Checking if logged in...");
    if (auth_token == null) {
      setState(() {
        checkedLogin = true;
        loggedIn = false;
      });
    } else {
      try {
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
      } catch (e) {
        setState(() {
          online = false;
        });
      }
    }
  }
}
