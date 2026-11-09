import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/failures.dart';
import 'features/announcements/domain/entities/announcement.dart';
import 'features/announcements/presentation/pages/announcements_page.dart';
import 'features/announcements/presentation/providers/announcements_providers.dart';
import 'features/notes/domain/entities/note.dart';
import 'features/notes/domain/repositories/note_repository.dart';
import 'features/notes/domain/usecases/add_note.dart';
import 'features/notes/presentation/pages/notes_page.dart';
import 'features/notes/presentation/providers/notes_providers.dart';

void main() {
  final screen = Uri.base.queryParameters['screen'] ?? 'lab2-list';
  final notes = switch (screen) {
    'lab2-validation' => const <Note>[],
    'lab3-notes' => [
        Note(
          id: 1,
          title: 'Clean Architecture',
          body: 'Keep presentation, domain, and data responsibilities separate.',
          updatedAt: DateTime(2026, 10, 30),
        ),
        Note(
          id: 2,
          title: 'Repository pattern',
          body: 'Depend on the domain contract and inject its implementation.',
          updatedAt: DateTime(2026, 10, 29),
        ),
      ],
    _ => [
        Note(
          id: 1,
          title: 'First note',
          body: 'A note displayed through the domain and data layers.',
          updatedAt: DateTime(2026, 10, 30),
        ),
      ],
  };
  runApp(ProviderScope(
    overrides: [
      notesProvider.overrideWith((ref) async => notes),
      addNoteProvider.overrideWith((ref) => AddNote(_CaptureNoteRepository())),
      announcementsProvider.overrideWith((ref) async {
        if (screen == 'lab3-error') {
          throw Exception('Network unavailable');
        }
        return const [
          Announcement(
            id: 1,
            title: 'Campus update',
            body: 'New campus announcements are available for students.',
          ),
          Announcement(
            id: 2,
            title: 'Library hours',
            body: 'The library will open at 8:00 AM this week.',
          ),
        ];
      }),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Campus Notes (Clean Architecture)',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF4F7DC9),
        useMaterial3: true,
      ),
      home: screen == 'lab3-announcements' || screen == 'lab3-error'
          ? const AnnouncementsPage()
          : const NotesPage(),
    ),
  ));
}

class _CaptureNoteRepository implements NoteRepository {
  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async =>
      (notes: const <Note>[], failure: null);

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async => (
        note: Note(title: title, body: body, updatedAt: DateTime(2026, 10, 30)),
        failure: null,
      );
}
