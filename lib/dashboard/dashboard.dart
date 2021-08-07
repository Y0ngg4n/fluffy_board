import 'package:fluffy_board/dashboard/filemanager/file_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();

  static Widget loading(String name) {
    return (Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Center(
          child: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              "assets/images/FluffyBoardIcon.png",
              height: 300,
            ),
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
  late String authToken;
  late String username;
  late String id;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) => {
          setState(() {
            accountStorage.ready.then((value) => {_setStorageReady()});
            introStorage.ready.then((value) => {_setIntroStorageReady()});
            settingsStorage.ready
                .then((value) => {print("Settingstorage is ready")});
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    String name = AppLocalizations.of(context)!.dashboard;
    print(checkedLogin);
    print(storageReady);
    print(introStorageReady);
    if ((!checkedLogin && !storageReady) || !introStorageReady)
      return (Dashboard.loading(name));
    WidgetsBinding.instance!.addPostFrameCallback((_) => {
          print("PostframeCallBack"),
          if (checkedLogin && !loggedIn && online)
            {
              print("Switching to login"),
              Navigator.of(context).pushReplacementNamed('/login')
            }
        });
    if (!checkedLogin && !loggedIn && online) return (Dashboard.loading(name));
    if (introStorage.getItem('read') == null) print("Switching to tutorial");
    SchedulerBinding.instance!.addPostFrameCallback((_) => {
          if (checkedLogin && !loggedIn && online)
            Navigator.of(context).pushNamed('/intro')
        });
    if (introStorage.getItem('read') == null) return (Dashboard.loading(name));

    return (FileManager(authToken, username, id, online));
  }

  _setStorageReady() {
    authToken = accountStorage.getItem("auth_token") ?? "";
    username = accountStorage.getItem("username") ?? "";
    id = accountStorage.getItem("id") ?? "";
    setState(() {
      this.storageReady = true;
      this.authToken = authToken;
      this.username = username;
    });
    _checkLoggedIn(authToken);
  }

  _setIntroStorageReady() {
    setState(() {
      this.introStorageReady = true;
    });
  }

  Future _checkLoggedIn(String authToken) async {
    print("Checking if logged in...");
    if (authToken.isEmpty) {
      setState(() {
        checkedLogin = true;
        loggedIn = false;
      });
    } else {
      try {
        await settingsStorage.ready;
        http.Response response = await http.get(
            Uri.parse((settingsStorage.getItem("REST_API_URL") ??
                    dotenv.env['REST_API_URL']!) +
                "/account/check"),
            headers: {
              "content-type": "application/json",
              "accept": "application/json",
              'Authorization': 'Bearer ' + authToken,
              'Access-Control-Allow-Origin': '*'
            });
        setState(() {
          print("Logged in");
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
