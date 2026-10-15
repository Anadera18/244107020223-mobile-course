import 'package:campus_notes_clean/core/failures.dart';
import 'package:campus_notes_clean/features/notes/domain/entities/note.dart';
import 'package:campus_notes_clean/features/notes/domain/repositories/note_repository.dart';

class FakeNoteRepository implements NoteRepository {
  FakeNoteRepository({this.items = const [], this.fail = false});

  final List<Note> items;
  final bool fail;
  int addCalls = 0;

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async {
    if (fail) {
      return (
        notes: const <Note>[],
        failure: const LocalFailure('db locked (simulated)'),
      );
    }
    return (notes: items, failure: null);
  }

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async {
    addCalls++;
    return (
      note: Note(title: title, body: body, updatedAt: DateTime(2026, 9, 27)),
      failure: null,
    );
  }
}
