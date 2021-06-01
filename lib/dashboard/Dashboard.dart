import 'dart:convert';
import 'dart:developer';
import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {

  final LocalStorage accountStorage = new LocalStorage('account');
  bool storageReady = false;
  bool checkedLogin = false;
  bool loggedIn = false;

  @override
  void initState() {
    super.initState();
    accountStorage.ready.then((value) async => {
      _setStorageReady()
    });
  }

  @override
  Widget build(BuildContext context) {
    if(!checkedLogin && !storageReady) return (_loading());
    if(!loggedIn) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return (_loading());
    }
    return (Scaffold(appBar: AppBar(
      title: Text("Dashboard"),
    ), body: Text("Dshboard"),));
  }

  Future<void> afterFirstLayout(BuildContext context) async {

  }

  Widget _loading(){
    return(Scaffold( appBar: AppBar(
      title: Text("Dashboard"),
    ),body: Center(child: CircularProgressIndicator()),));
  }

  _setStorageReady(){
    setState(() {
      storageReady = true;
    });
    String auth_token = accountStorage.getItem("auth_token");
    print(auth_token);
    String username = accountStorage.getItem("username");
    _checkLoggedIn(auth_token).then((value) => {
      setState((){
        loggedIn = value;
      })
    });
  }

  Future<bool> _checkLoggedIn(String auth_token) async  {
    http.Response response = await http.get(
        Uri.parse(dotenv.env['REST_API_URL']! +
            "/account/check"),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          'Authorization': 'Bearer ' + auth_token,
        });
    setState(() {
      checkedLogin = true;
    });
    return response.statusCode == 200 ? true : false;
  }
}
