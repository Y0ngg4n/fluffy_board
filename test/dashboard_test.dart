import 'package:fluffy_board/account/Login.dart';
import 'package:fluffy_board/documentation/About.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:fluffy_board/main.dart';
import 'package:localstorage/localstorage.dart';

void main() {
  testWidgets('Dashboard widget', (WidgetTester tester) async {
    await tester.runAsync(() async {
      final LocalStorage accountStorage = new LocalStorage('account');
      await accountStorage.ready;
      accountStorage.clear();
    });
    await tester.pumpWidget(buildMaterialApp('/dashboard'));
    await tester.runAsync(() => Future.delayed(Duration(seconds: 20)));
    await tester.pump(Duration(seconds: 5));
    tester.binding.scheduleWarmUpFrame();
    print("Created Widget");
    await tester.runAsync(() => Future.delayed(Duration(seconds: 20)));

    /// Check for Login
    expect(find.text('Skip'), findsOneWidget);
    print("Checked Dashboard");
    await tester.pump(Duration(seconds: 5));
  });
}
