import 'package:sqflite/sqflite.dart';
import '../local/db.dart';
import '../local/note.dart';

/// LAB 2 - Satu-satunya pintu ke tabel `notes` (CRUD + dirty flag).
class NoteRepository {
  NoteRepository({Future<Database> Function()? openDb})
      : _openDb = openDb ?? openNotesDb;

  final Future<Database> Function() _openDb;

  // READ (urut updated_at terbaru)
  Future<List<Note>> fetchNotes() async {
    final db = await _openDb();
    final rows = await db.query('notes', orderBy: 'updated_at DESC');
    return rows.map(Note.fromMap).toList();
  }

  Future<Note?> getById(int id) async {
    final db = await _openDb();
    final rows = await db.query('notes', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : Note.fromMap(rows.first);
  }

  // CREATE - catatan baru otomatis dirty = true
  Future<Note> addNote({required String title, String body = ''}) async {
    final db = await _openDb();
    final note = Note(
      title: title,
      body: body,
      updatedAt: DateTime.now(),
      dirty: true,
    );
    final id = await db.insert('notes', note.toMap());
    return note.copyWith(id: id);
  }

  // UPDATE - perubahan lokal juga menandai dirty + updated_at baru
  Future<void> updateNote(Note note) async {
    final db = await _openDb();
    final updated = note.copyWith(updatedAt: DateTime.now(), dirty: true);
    await db.update(
      'notes',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  // DELETE
  Future<void> deleteNote(int id) async {
    final db = await _openDb();
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  // Antrean sync
  Future<int> countDirty() async {
    final db = await _openDb();
    final rows =
        await db.rawQuery('SELECT COUNT(*) AS c FROM notes WHERE dirty = 1');
    return (rows.first['c'] as num?)?.toInt() ?? 0;
  }

  Future<void> markAllSynced() async {
    final db = await _openDb();
    await db.update('notes', {'dirty': 0}, where: 'dirty = 1');
  }
}
