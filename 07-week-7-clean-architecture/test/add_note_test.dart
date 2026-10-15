import 'package:campus_notes_clean/core/failures.dart';
import 'package:campus_notes_clean/features/notes/domain/usecases/add_note.dart';
import 'package:flutter_test/flutter_test.dart';
import 'fakes.dart';

void main() {
  test('AddNote rejects a blank title and never touches the repository',
      () async {
    final repo = FakeNoteRepository();
    final result = await AddNote(repo)(title: '   ');
    expect(result.failure, isA<ValidationFailure>());
    expect(result.note, isNull);
    expect(repo.addCalls, 0);
  });

  test('AddNote trims the title and saves', () async {
    final repo = FakeNoteRepository();
    final result = await AddNote(repo)(title: '  Hello  ', body: ' x ');
    expect(result.failure, isNull);
    expect(result.note!.title, 'Hello');
    expect(result.note!.body, 'x');
    expect(repo.addCalls, 1);
  });
}
