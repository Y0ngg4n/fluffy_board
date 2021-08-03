import 'package:fluffy_board/account/login.dart';
import 'package:fluffy_board/documentation/about.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:fluffy_board/main.dart';
import 'package:localstorage/localstorage.dart';

void main() {
  testWidgets('About widget', (WidgetTester tester) async {
    await tester.runAsync(() async {
      final LocalStorage accountStorage = new LocalStorage('account');
      await accountStorage.ready;
      accountStorage.clear();
    });

    // await tester.pumpWidget(buildMaterialApp('/about'));
    await tester.pump(Duration(seconds: 5));
    print("Created Widget");

    /// Check for Accounts before Slideshow
    expect(find.text('Create awesome'), findsOneWidget);
    print("Checked About");
    await tester.pump(Duration(seconds: 5));
  });
}
