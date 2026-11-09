import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week10_ai_feature_integration/ai/ai_service.dart';
import 'package:week10_ai_feature_integration/ai/api_key_store.dart';
import 'package:week10_ai_feature_integration/features/chat/chat_page.dart';

class _ScreenshotKeyStore implements ApiKeyStore {
  @override
  Future<void> delete() async {}

  @override
  Future<String?> read() async => null;

  @override
  Future<void> write(String key) async {}
}

void main() {
  testWidgets('captures the chat home screen', (tester) async {
    final fontBytes = File('test/fonts/Roboto-Regular.ttf').readAsBytesSync();
    final fontLoader = FontLoader('CaptureRoboto')
      ..addFont(Future.value(ByteData.view(fontBytes.buffer)));
    await fontLoader.load();
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final keyStore = _ScreenshotKeyStore();
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          fontFamily: 'CaptureRoboto',
          fontFamilyFallback: const ['Roboto'],
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF335CFF)),
          useMaterial3: true,
        ),
        home: ChatPage(
          service: AiService(keyStore: keyStore),
          keyStore: keyStore,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../screenshots/chat-home.png'),
    );
  });

  testWidgets('captures a successful test run', (tester) async {
    final report = File('test-output.txt').readAsStringSync();
    expect(report, isNotEmpty);
    expect(report, isNot(contains('FAILED')));
  });
}
