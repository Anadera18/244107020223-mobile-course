import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week9_ai_assisted_development/features/notes/domain/filter_notes.dart';
import 'package:week9_ai_assisted_development/features/notes/domain/note.dart';
import 'package:week9_ai_assisted_development/features/notes/presentation/notes_page.dart';

void main() {
  const notes = [
    Note(title: 'Grocery list', body: 'Milk and bread'),
    Note(title: 'Flutter study plan', body: 'Practice widgets'),
  ];

  testWidgets('shows matching note after entering a query', (tester) async {
    await tester.pumpWidget(_app(notes));
    await tester.enterText(
        find.byKey(const Key('notes-search-field')), 'FLUTTER');
    await tester.pumpAndSettle();

    expect(find.text('Flutter study plan'), findsOneWidget);
    expect(find.text('Grocery list'), findsNothing);
  });

  testWidgets('shows empty state when no title matches', (tester) async {
    await tester.pumpWidget(_app(notes));
    await tester.enterText(
      find.byKey(const Key('notes-search-field')),
      'zzz-missing',
    );
    await tester.pumpAndSettle();

    expect(find.text('No notes match your search'), findsOneWidget);
  });

  testWidgets('shows no-notes state for an empty collection', (tester) async {
    await tester.pumpWidget(_app(const []));

    expect(find.text('No notes yet'), findsOneWidget);
  });
}

Widget _app(List<Note> notes) => MaterialApp(
      home: NotesPage(notes: notes, filterNotes: filterNotes),
    );
