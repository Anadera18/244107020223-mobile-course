import 'package:campus_notes_clean/core/failures.dart';
import 'package:campus_notes_clean/features/notes/domain/entities/note.dart';
import 'package:campus_notes_clean/features/notes/domain/usecases/get_notes.dart';
import 'package:flutter_test/flutter_test.dart';
import 'fakes.dart';

void main() {
  test('GetNotes forwards the repository list', () async {
    final repo = FakeNoteRepository(items: [
      Note(title: 'A', updatedAt: DateTime(2026, 9, 27)),
    ]);
    final result = await GetNotes(repo).call();
    expect(result.failure, isNull);
    expect(result.notes.length, 1);
    expect(result.notes.first.title, 'A');
  });

  test('GetNotes forwards failure without throwing', () async {
    final repo = FakeNoteRepository(fail: true);
    final result = await GetNotes(repo).call();
    expect(result.failure, isA<LocalFailure>());
    expect(result.notes, isEmpty);
  });
}
