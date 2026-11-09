import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week11_performance_optimization/main.dart';

void main() {
  testWidgets('captures the optimized performance lab', (tester) async {
    final fontBytes = File('test/fonts/Roboto-Regular.ttf').readAsBytesSync();
    final fontLoader = FontLoader('CaptureRoboto')
      ..addFont(Future.value(ByteData.view(fontBytes.buffer)));
    await fontLoader.load();
    final iconBytes =
        File('test/fonts/MaterialIcons-Regular.otf').readAsBytesSync();
    final iconLoader = FontLoader('MaterialIcons')
      ..addFont(Future.value(ByteData.view(iconBytes.buffer)));
    await iconLoader.load();
    final defaultFontLoader = FontLoader('Roboto')
      ..addFont(Future.value(ByteData.view(fontBytes.buffer)));
    await defaultFontLoader.load();

    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const PerformanceLabApp());
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../screenshots/performance-lab.png'),
    );
  });
}
