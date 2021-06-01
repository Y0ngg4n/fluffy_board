import 'dart:convert';
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

  @override
  Widget build(BuildContext context) {
    final LocalStorage accountStorage = new LocalStorage('account');
    bool storageReady = false;
    bool loggedIn = false;

    accountStorage.ready.then((value) async => {
      setState(() {
        storageReady = true;
      })
    });

    String auth_token = accountStorage.getItem("auth_token");
    String username = accountStorage.getItem("username");

    if(!storageReady) return(_loading());
    else {
      _checkLoggedIn(auth_token).then((value) =>
      {
        setState(() {
          loggedIn = true;
        })
      });

      print(storageReady);
      print(loggedIn);
    }
    if(!loggedIn && !storageReady) return (_loading());
    else return(Scaffold( appBar: AppBar(
      title: Text("Dashboard"),
    ),body: Text("Dshboard"),));
  }

  Widget _loading(){
    return(Scaffold( appBar: AppBar(
      title: Text("Dashboard"),
    ),body: CircularProgressIndicator(),));
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
    return response.statusCode == 200 ? true : false;
  }
}
