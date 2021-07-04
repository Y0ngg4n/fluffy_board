import 'package:fluffy_board/dashboard/Dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:ui';
import 'package:localstorage/localstorage.dart';
import 'package:introduction_screen/introduction_screen.dart';

class FileManagerIntroduction extends StatefulWidget {
  @override
  _FileManagerIntroductionState createState() =>
      _FileManagerIntroductionState();
}

class _FileManagerIntroductionState extends State<FileManagerIntroduction> {
  final LocalStorage introStorage = new LocalStorage('intro');
  bool introStorageReady = false;
  List<PageViewModel> pages = List.empty();

  @override
  void initState() {
    super.initState();
    introStorage.ready.then((value) =>
        setState(() {
          introStorageReady = true;
        }));
    pages = List.of([
      PageViewModel(
        title: "Title of first page",
        body:
        "Here you can write the description of the page, to explain someting...",
        image: Center(
          child: Image.network(
              "https://media.tenor.com/images/9a977fdf29d86ecaae3309a12ef853ed/tenor.gif",
              height: 175.0),
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    if (!introStorageReady) return (Dashboard.loading("Fluffy Board"));
    SchedulerBinding.instance!.addPostFrameCallback((_) =>
    {
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (introStorage.getItem('read') != null) Navigator
            .restorablePushReplacementNamed(context, '/dashboard');
      })
    });
    return IntroductionScreen(
      pages: pages,
      onDone: () {
        // introStorage.setItem('read', true);
        SchedulerBinding.instance!.addPostFrameCallback((_) => {
        Navigator.restorablePushReplacementNamed(context, '/dashboard')
        });
      },
      next: const Icon(Icons.arrow_right),
      showNextButton: true,
      showSkipButton: true,
      skip: const Text("Skip"),
      done: const Text("Done", style: TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
