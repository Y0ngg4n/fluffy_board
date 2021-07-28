import 'dart:io';

import 'package:fluffy_board/utils/ScreenUtils.dart';
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
    } else if (screenWidth < 600 && screenWidth >= 500) {
      setState(() {
        sizeFactor = 0.25;
      });
    } else if (screenWidth < 500) {
      setState(() {
        sizeFactor = 0.15;
      });
    } else {
      setState(() {
        sizeFactor = 1;
      });
    }

    TextStyle animatedHeadingTextStyle =
        GoogleFonts.fredokaOne(fontSize: 100 * sizeFactor);
    TextStyle cardHeadingTextStyle =
        GoogleFonts.fredokaOne(fontSize: 70 * sizeFactor);
    TextStyle cardTextStyle = TextStyle(fontSize: 40 * sizeFactor);

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
              Flexible(
                child: Text(
                  "FluffyBoard",
                  style: GoogleFonts.fredokaOne(fontSize: 150 * sizeFactor),
                ),
              )
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Perfect for Students, Schools and Teams",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30 * sizeFactor),
                )
              ],
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 50.0, 16.0, 16.0),
                child: ElevatedButton(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(children: [
                      Text("Get started", style: TextStyle(fontSize: 50)),
                      Icon(Icons.arrow_right)
                    ]),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed("/dashboard");
                  },
                ),
              )
            ]),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 50.0, 16.0, 16.0),
              child: Wrap(spacing: 30, children: [
                SizedBox(
                  height: 400 * sizeFactor,
                  width: 600 * sizeFactor,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text("Open Source", style: cardHeadingTextStyle),
                          Flexible(
                            child: Text(
                              "This project is fully open source, \nyou can view the source code \nand make requests to it, \nor just create a pull request \nso your coded changes \nwill be in the next release",
                              style: cardTextStyle,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 400 * sizeFactor,
                  width: 600 * sizeFactor,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Flexible(
                              child: Text("Infinite Canvas",
                                  style: cardHeadingTextStyle)),
                          Flexible(
                            child: Text(
                              "Infinite space to give you \ninfinite possibilities to get creative",
                              style: cardTextStyle,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 400 * sizeFactor,
                  width: 600 * sizeFactor,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Flexible(
                              child: Text("Collaboration",
                                  style: cardHeadingTextStyle)),
                          Flexible(
                            child: Text(
                              "Work together with your team and \ncollaborate to achieve your goals.",
                              style: cardTextStyle,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 400 * sizeFactor,
                  width: 600 * sizeFactor,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Flexible(
                              child: Text("Import/Export",
                                  style: cardHeadingTextStyle)),
                          Flexible(
                            child: Text(
                              "You can import and export \nWhiteboards to transfer \nthem to other accounts.",
                              style: cardTextStyle,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 400 * sizeFactor,
                  width: 600 * sizeFactor,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Flexible(
                              child: Text("Offline use",
                                  style: cardHeadingTextStyle)),
                          Flexible(
                            child: Text(
                              "You can download your \nWhiteboards and use them offline.\n And if you have internet again\n you can upload them back.",
                              style: cardTextStyle,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 400 * sizeFactor,
                  width: 600 * sizeFactor,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Flexible(
                              child: Text("Import Media",
                                  style: cardHeadingTextStyle)),
                          Flexible(
                            child: Text(
                              "You can import images and PDF \nfiles to share your files with your Team",
                              style: cardTextStyle,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 400 * sizeFactor,
                  width: 600 * sizeFactor,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Flexible(
                              child: Text("View only invites",
                                  style: cardHeadingTextStyle)),
                          Flexible(
                            child: Text(
                              "Sharing is posible with view only rights. \nSo you can just present your whiteboard \nwithout giving others the permission to edit them",
                              style: cardTextStyle,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 400 * sizeFactor,
                  width: 600 * sizeFactor,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Flexible(
                              child: Text("Self hosted",
                                  style: cardHeadingTextStyle)),
                          Flexible(
                            child: Text(
                              "Because this project is open source you can self host it and have full control over your data.",
                              style: cardTextStyle,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 400 * sizeFactor,
                  width: 600 * sizeFactor,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Flexible(
                              child: Text("No tracking",
                                  style: cardHeadingTextStyle)),
                          Flexible(
                            child: Text(
                              "No tracking. No spying. No unnecessary data will be collected. Have full controll over your data.",
                              style: cardTextStyle,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ]),
            )
          ]),
        ),
      ),
    );
  }
}
