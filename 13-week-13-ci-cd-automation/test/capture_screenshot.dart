import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week13_ci_cd_automation/main.dart';

/// Renders the app to a golden PNG so the README can show the real UI.
///
/// This file intentionally does not end in `_test.dart`, so `flutter test`
/// (and CI) do not run it: golden comparison is rendering-sensitive and would
/// differ across operating systems. Run it manually to regenerate the image:
///
///   flutter test test/capture_screenshot.dart --update-goldens
void main() {
  testWidgets('captures the week 13 home screen', (tester) async {
    final roboto = File('test/fonts/Roboto-Regular.ttf').readAsBytesSync();
    final iconsBytes =
        File('test/fonts/MaterialIcons-Regular.otf').readAsBytesSync();

    final robotoLoader = FontLoader('Roboto')
      ..addFont(Future.value(ByteData.view(roboto.buffer)));
    await robotoLoader.load();
    final iconLoader = FontLoader('MaterialIcons')
      ..addFont(Future.value(ByteData.view(iconsBytes.buffer)));
    await iconLoader.load();

    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const CiCdLabApp());
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../screenshots/app-home.png'),
    );
  });
}
