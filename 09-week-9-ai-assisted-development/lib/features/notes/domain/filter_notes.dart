import 'note.dart';

/// Returns notes whose titles contain [query], ignoring letter case.
/// An empty or whitespace-only query returns every note.
List<Note> filterNotes(List<Note> notes, String query) {
  final normalizedQuery = query.trim().toLowerCase();
  if (normalizedQuery.isEmpty) return List<Note>.unmodifiable(notes);

  return List<Note>.unmodifiable(
    notes.where((note) => note.title.toLowerCase().contains(normalizedQuery)),
  );
}
