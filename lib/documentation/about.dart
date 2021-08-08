import 'dart:io';

import 'package:fluffy_board/utils/screen_utils.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localstorage/localstorage.dart';

class About extends StatefulWidget {
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  double sizeFactor = 1;
  final LocalStorage accountStorage = new LocalStorage('account');
  final cardHeadings = [
    "Open Source",
    "Infinite Canvas",
    "Collaboration",
    "Import/Export",
    "Offline use",
    "Import Media",
    "View only invites",
    "Self hosted",
    "No tracking"
  ];
  final cardDescriptions = [
    "This project is fully open source, you can view the source code and make requests to it, or just create a pull request so your coded changes will be in the next release",
    "Infinite space to give you infinite possibilities to get creative",
    "Work together with your team and collaborate to achieve your goals.",
    "You can import and export Whiteboards to transfer them to other accounts.",
    "You can download your Whiteboards and use them offline. And if you have internet again you can upload them back.",
    "You can import images and PDF files to share your files with your Team",
    "Sharing is possible with view only rights. So you can just present your whiteboard without giving others the permission to edit them",
    "Because this project is open source you can self host it and have full control over your data.",
    "No tracking. No spying. No unnecessary data will be collected. Have full control over your data."
  ];

  @override
  void initState() {
    super.initState();
    try {
      SchedulerBinding.instance!.addPostFrameCallback((_) => {
            accountStorage.ready.then((value) async => {
                  Future.delayed(const Duration(seconds: 1), () {
                    if (accountStorage.getItem("auth_token") != null)
                      Navigator.of(context).pushReplacementNamed('/dashboard');
                  })
                }),
          });
    } catch (e) {
      stderr.writeln("[About] Could not check Authentication in About");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = ScreenUtils.getScreenWidth(context);
    if (screenWidth < 1000 && screenWidth >= 600) {
      setState(() {
        sizeFactor = 0.5;
      });
    } else if (screenWidth < 600) {
      setState(() {
        sizeFactor = 0.25;
      });
    } else {
      setState(() {
        sizeFactor = 1;
      });
    }

    TextStyle animatedHeadingTextStyle =
        GoogleFonts.fredokaOne(fontSize: 100 * sizeFactor);
    TextStyle cardHeadingTextStyle =
        GoogleFonts.fredokaOne(fontSize: 90 * sizeFactor);
    TextStyle cardTextStyle = TextStyle(fontSize: 70 * sizeFactor);

    return Scaffold(
      appBar: AppBar(
          leading: Image.asset(
            "assets/images/FluffyBoardIcon.png",
          ),
          title: Text("Fluffyboard")),
      body: SingleChildScrollView(
        child: Container(
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "FluffyBoard",
                  style: GoogleFonts.fredokaOne(fontSize: 150 * sizeFactor),
                ),
              ),
            ]),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 20.0 * sizeFactor, height: 350.0 * sizeFactor),
                Expanded(
                  flex: 1,
                  child: Text(
                    "Create awesome",
                    textAlign: TextAlign.end,
                    style: animatedHeadingTextStyle,
                  ),
                ),
                SizedBox(width: 20.0 * sizeFactor, height: 350.0 * sizeFactor),
                Expanded(
                  flex: 1,
                  child: Wrap(
                    children: [
                      AnimatedTextKit(
                        repeatForever: true,
                        animatedTexts: [
                          RotateAnimatedText('Drawings',
                              textStyle: animatedHeadingTextStyle),
                          RotateAnimatedText('Thinking',
                              textStyle: animatedHeadingTextStyle),
                          RotateAnimatedText('Mindmaps',
                              textStyle: animatedHeadingTextStyle),
                          RotateAnimatedText('Collages',
                              textStyle: animatedHeadingTextStyle),
                          RotateAnimatedText('Collabs',
                              textStyle: animatedHeadingTextStyle),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  "Perfect for Students, Schools and Teams",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 75 * sizeFactor),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 50, 16.0, 16),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    ElevatedButton(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(children: [
                          Text("Get started", style: TextStyle(fontSize: 150 * sizeFactor)),
                          Icon(Icons.arrow_right, size: 150 * sizeFactor)
                        ]),
                      ),
                      onPressed: () {
                        Navigator.of(context)
                            .pushReplacementNamed("/dashboard");
                      },
                    ),
                  ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 16.0),
              child: Column(children: [
                for (int i = 0; i < cardHeadings.length; i++)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 25.0, 8.0, 8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(cardHeadings[i],
                              style: cardHeadingTextStyle),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            cardDescriptions[i],
                            style: cardTextStyle,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
              ]),
            )
          ]),
        ),
      ),
    );
  }
}
