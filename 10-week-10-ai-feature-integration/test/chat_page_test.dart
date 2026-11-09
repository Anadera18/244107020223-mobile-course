import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week10_ai_feature_integration/ai/ai_service.dart';
import 'package:week10_ai_feature_integration/ai/api_key_store.dart';
import 'package:week10_ai_feature_integration/features/chat/chat_page.dart';

class _MemoryKeyStore implements ApiKeyStore {
  String? key;

  @override
  Future<void> delete() async => key = null;

  @override
  Future<String?> read() async => key;

  @override
  Future<void> write(String value) async => key = value;
}

void main() {
  testWidgets('shows welcome, sends question and labels local fallback',
      (tester) async {
    final keyStore = _MemoryKeyStore();
    final service = AiService(keyStore: keyStore);
    await tester.pumpWidget(
        MaterialApp(home: ChatPage(service: service, keyStore: keyStore)));

    expect(find.textContaining('Halo! Saya asisten akademik'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('questionField')),
        'Bagaimana mulai belajar Flutter?');
    await tester.tap(find.byKey(const Key('sendButton')));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Bagaimana mulai belajar Flutter?'), findsOneWidget);
    expect(
        find.text('Tambahkan API key Gemini di Pengaturan.'), findsOneWidget);
    expect(find.text('MODE OFFLINE'), findsOneWidget);
    expect(find.textContaining('Contoh offline:'), findsOneWidget);
  });

  testWidgets('settings dialog exposes secure key save and delete controls',
      (tester) async {
    final keyStore = _MemoryKeyStore();
    final service = AiService(keyStore: keyStore);
    await tester.pumpWidget(
        MaterialApp(home: ChatPage(service: service, keyStore: keyStore)));
    await tester.tap(find.byKey(const Key('settingsButton')));
    await tester.pumpAndSettle();

    expect(find.text('Pengaturan Gemini'), findsOneWidget);
    expect(find.text('API key disimpan di secure storage perangkat.'),
        findsOneWidget);
    expect(find.text('Simpan'), findsOneWidget);
    expect(find.text('Hapus key'), findsOneWidget);
  });

  testWidgets('enforces the maximum prompt length', (tester) async {
    final keyStore = _MemoryKeyStore();
    final service = AiService(keyStore: keyStore);
    await tester.pumpWidget(
        MaterialApp(home: ChatPage(service: service, keyStore: keyStore)));
    final overlongQuestion = List.filled(501, 'a').join();
    await tester.enterText(
        find.byKey(const Key('questionField')), overlongQuestion);
    await tester.tap(find.byKey(const Key('sendButton')));
    await tester.pump();

    expect(find.byKey(const Key('questionField')), findsOneWidget);
    final textField =
        tester.widget<TextField>(find.byKey(const Key('questionField')));
    expect(textField.maxLength, 500);
    expect(find.text(overlongQuestion), findsNothing);
  });
}
