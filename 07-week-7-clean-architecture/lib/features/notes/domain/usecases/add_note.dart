import '../../../../core/failures.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

/// A use case is justified here: it owns a business rule (title validation)
/// instead of just forwarding to the repository.
class AddNote {
  const AddNote(this._repository);
  final NoteRepository _repository;

  Future<({Note? note, Failure? failure})> call({
    required String title,
    String body = '',
  }) {
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) {
      return Future.value((
        note: null,
        failure: const ValidationFailure('Title must not be empty.'),
      ));
    }
    return _repository.addNote(title: cleanTitle, body: body.trim());
  }
}
