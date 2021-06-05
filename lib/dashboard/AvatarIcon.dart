import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:localstorage/localstorage.dart';

class AvatarIcon extends StatefulWidget {
  @override
  _AvatarIconState createState() => _AvatarIconState();
}

class _AvatarIconState extends State<AvatarIcon> {
  final LocalStorage accountStorage = new LocalStorage('account');

  @override
  Widget build(BuildContext context) {
    return Container(
      child:
        PopupMenuButton(
          icon: CircleAvatar(),
          itemBuilder: (context) => [
            PopupMenuItem(child: Text("Edit Account"), value: "/edit-account"),
            PopupMenuItem(child: Text("Logout"), value: "/login"),
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
            }
          },
        )
    );

  }
}
