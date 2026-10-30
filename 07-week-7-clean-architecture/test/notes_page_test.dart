import 'package:campus_notes_clean/features/notes/presentation/pages/notes_page.dart';
import 'package:campus_notes_clean/features/notes/presentation/providers/notes_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('cancel closes the add-note dialog without adding a note', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [notesProvider.overrideWith((ref) async => const [])],
        child: const MaterialApp(home: NotesPage()),
      ),
    );

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('New note'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('New note'), findsNothing);
    expect(find.text('No notes yet.'), findsOneWidget);
  });

  testWidgets('blank title is rejected by the domain validation', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [notesProvider.overrideWith((ref) async => const [])],
        child: const MaterialApp(home: NotesPage()),
      ),
    );

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Title must not be empty.'), findsOneWidget);
  });
}
