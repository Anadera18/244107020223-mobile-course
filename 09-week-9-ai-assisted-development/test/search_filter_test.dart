import 'package:flutter_test/flutter_test.dart';
import 'package:week9_ai_assisted_development/features/notes/domain/filter_notes.dart';
import 'package:week9_ai_assisted_development/features/notes/domain/note.dart';

void main() {
  const notes = [
    Note(title: 'Grocery list', body: 'Milk and bread'),
    Note(title: 'Flutter study plan', body: 'Practice widgets'),
    Note(title: 'Groceries to buy', body: 'Coffee'),
  ];

  test('matches titles without regard to letter case', () {
    final result = filterNotes(notes, 'gRoC');

    expect(
        result.map((note) => note.title), ['Grocery list', 'Groceries to buy']);
  });

  test('returns an empty list when no title matches', () {
    expect(filterNotes(notes, 'zzz-missing'), isEmpty);
  });

  test('empty and whitespace queries return all notes', () {
    expect(filterNotes(notes, ''), hasLength(3));
    expect(filterNotes(notes, '   '), hasLength(3));
  });
}
