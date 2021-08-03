import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
class AvatarIcon extends StatefulWidget {
  final bool online;

  AvatarIcon(this.online);

  @override
  _AvatarIconState createState() => _AvatarIconState();
}

class _AvatarIconState extends State<AvatarIcon> {
  final LocalStorage accountStorage = new LocalStorage('account');

  @override
  Widget build(BuildContext context) {
    if(!widget.online) return Container();
    return Container(
      child:
        PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(child: Text("Edit Account"), value: "/edit-account"),
            PopupMenuItem(child: Text("Logout"), value: "/login"),
            PopupMenuItem(child: Text("Change Server"), value: "/server-settings"),
            PopupMenuItem(child: Text("Sync Server"), value: "/webdav-settings"),
          ],
          onSelected: (route) async {
            switch (route){
              case "/edit-account":
                Navigator.pushNamed(context, route.toString());
                break;
              case "/login":
                await accountStorage.ready;
                accountStorage.clear();
                Navigator.pushReplacementNamed(context, route.toString());
                break;
              case "/server-settings":
                Navigator.pushReplacementNamed(context, route.toString());
                break;
              case "/webdav-settings":
                if(kIsWeb) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Not available on web")));
                else Navigator.pushNamed(context, route.toString());
                break;
            }
          },
        )
    );
  }
}
