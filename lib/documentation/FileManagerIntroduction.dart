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

class _FileManagerIntroductionState extends State<FileManagerIntroduction>
    with TickerProviderStateMixin {
  final LocalStorage introStorage = new LocalStorage('intro');
  bool introStorageReady = false;
  List<PageViewModel> pages = List.empty();

  @override
  void initState() {
    super.initState();
    introStorage.ready.then((value) => setState(() {
          introStorageReady = true;
        }));
    pages = List.of([
      PageViewModel(
        title: "Create Whiteboard",
        body: "You can create Whiteboards and give them a name",
        image: Center(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
              "assets/images/FileManagerIntro/CreateWhiteboard.gif"),
        )),
      ),
      PageViewModel(
        title: "Rename Whiteboard",
        body: "If you want to change the name you can rename your Whiteboards",
        image: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
                "assets/images/FileManagerIntro/RenameWhiteboard.gif"),
          ),
        ),
      ),
      PageViewModel(
        title: "Share Whiteboard",
        body:
            "You can share your Whiteboards and others can import them to their collection",
        image: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
                "assets/images/FileManagerIntro/ShareWhiteboard.gif"),
          ),
        ),
      ),
      PageViewModel(
        title: "Download Whiteboards",
        body: "You can download Whiteboards to keep them local",
        image: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
                "assets/images/FileManagerIntro/DownloadWhiteboard.gif"),
          ),
        ),
      ),
      PageViewModel(
        title: "Upload Whiteboards",
        body:
            "You can upload your local Whiteboards to sync them with the cloud",
        image: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
                "assets/images/FileManagerIntro/UploadWhiteboard.gif"),
          ),
        ),
      ),
      PageViewModel(
        title: "Delete Whiteboards",
        body: "You can delete Whiteboards if you don´t need them anymore",
        image: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
                "assets/images/FileManagerIntro/DeleteWhiteboard.gif"),
          ),
        ),
      ),
      PageViewModel(
        title: "Create Folder",
        body: "You can create Folders to manage your Whiteboards",
        image: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                Image.asset("assets/images/FileManagerIntro/CreateFolder.gif"),
          ),
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: pages,
      onDone: () {
        introStorage.setItem('read', true);
        Navigator.of(context).pop();
      },
      next: const Icon(Icons.arrow_right),
      showNextButton: true,
      showSkipButton: true,
      skip: const Text("Skip"),
      done: const Text("Done", style: TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
