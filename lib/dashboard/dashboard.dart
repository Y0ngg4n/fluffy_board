import 'package:fluffy_board/dashboard/filemanager/file_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:localstorage/localstorage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();

  static Widget loading(String name, BuildContext context) {
    bool isDarkModeOn = Theme.of(context).brightness == Brightness.dark;
    return (Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Center(
          child: SingleChildScrollView(
        child: Column(
          children: [
            isDarkModeOn ? Image.asset(
              "assets/images/FluffyBoardIconDark.png",
              height: 300,
            ) : Image.asset(
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
  bool online = false;  // Default to offline mode for full offline usage
  bool loggedIn = true;  // Assume logged in for offline mode
  String authToken = "";  // Empty auth token for offline
  String username = "Offline User";  // Default offline username
  String id = "offline-user-id";  // Default offline ID

  @override
  void initState() {
    super.initState();
    // For offline mode, skip login check and go directly to dashboard
    WidgetsBinding.instance!.addPostFrameCallback((_) => {
          setState(() {
            introStorage.ready.then((value) => {_setIntroStorageReady()});
            // Set checkedLogin to true and loggedIn to true for offline mode
            checkedLogin = true;
            loggedIn = true;
            online = false;
            storageReady = true;
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
      return (Dashboard.loading(name, context));
    // Offline mode - skip login checks and go directly to dashboard
    if (introStorage.getItem('read') == null) {
      print("Switching to tutorial");
      SchedulerBinding.instance!.addPostFrameCallback((_) => {
            Navigator.of(context).pushNamed('/intro')
          });
      return (Dashboard.loading(name, context));
    }

    return (FileManager(authToken, username, id, online));
  }

  _setStorageReady() {
    // Not used in offline mode - kept for compatibility
  }

  _setIntroStorageReady() {
    setState(() {
      this.introStorageReady = true;
    });
  }

  // Not used in offline mode - kept for compatibility
  Future _checkLoggedIn(String authToken) async {
    // Offline mode - no login check needed
  }
}
