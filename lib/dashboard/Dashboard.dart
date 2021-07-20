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
      body: Center(child: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset("assets/images/FluffyBoardIcon.png", height: 300,),
            CircularProgressIndicator(),
          ],
        ),
      )),
    ));
  }
}

class _DashboardState extends State<Dashboard> {
  final LocalStorage accountStorage = new LocalStorage('account');
  final LocalStorage introStorage = new LocalStorage('intro');
  final LocalStorage settingsStorage = new LocalStorage('settings');
  bool storageReady = false;
  bool introStorageReady = false;
  bool checkedLogin = false;
  bool online = true;
  bool loggedIn = false;
  late String auth_token;
  late String username;
  late String id;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance!.addPostFrameCallback((_) => {
          accountStorage.ready.then((value) async => {_setStorageReady()}),
          introStorage.ready.then((value) async => {_setIntroStorageReady()})
        });
  }

  @override
  Widget build(BuildContext context) {
    const name = "Dashboard";

    if ((!checkedLogin && !storageReady) || !introStorageReady) return (Dashboard.loading(name));
    SchedulerBinding.instance!.addPostFrameCallback((_) => {
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (checkedLogin && !loggedIn && online)
              Navigator.of(context).pushReplacementNamed('/login');
          })
        });
    if (!checkedLogin && !loggedIn && online) return (Dashboard.loading(name));
    if(introStorage.getItem('read') == null)
      SchedulerBinding.instance!.addPostFrameCallback((_) => {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (checkedLogin && !loggedIn && online)
            Navigator.of(context).pushNamed('/intro');
        })
      });
    return (Scaffold(
      appBar: AppBar(title: Text(name), actions: [AvatarIcon(online)]),
      body: Container(
        child: FileManager(auth_token, username, id,  online),
      ),
    ));
  }

  _setStorageReady() {
    auth_token = accountStorage.getItem("auth_token") ?? "";
    username = accountStorage.getItem("username") ?? "";
    id = accountStorage.getItem("id") ?? "";
    setState(() {
      this.storageReady = true;
      this.auth_token = auth_token;
      this.username = username;
    });
    _checkLoggedIn(auth_token);
  }

  _setIntroStorageReady(){
    setState(() {
      introStorageReady = true;
    });
  }

  Future _checkLoggedIn(String auth_token) async {
    print("Checking if logged in...");
    if (auth_token.isEmpty) {
      setState(() {
        checkedLogin = true;
        loggedIn = false;
      });
    } else {
      try {
        http.Response response = await http.get(
            Uri.parse((settingsStorage.getItem("REST_API_URL") ?? dotenv.env['REST_API_URL']!) + "/account/check"),
            headers: {
              "content-type": "application/json",
              "accept": "application/json",
              'Authorization': 'Bearer ' + auth_token,
              'Access-Control-Allow-Origin': '*'
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
