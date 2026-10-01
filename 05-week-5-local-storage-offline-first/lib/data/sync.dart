import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'local/db.dart';
import 'local/note.dart';
import 'models/post.dart';
import 'repositories/note_repository.dart';

/// LAB 3 - Cache lokal untuk posts (tabel `cached_posts`).
class PostCache {
  PostCache({Future<Database> Function()? openDb})
      : _openDb = openDb ?? openNotesDb;

  final Future<Database> Function() _openDb;

  Future<List<Post>> readCachedPosts() async {
    final db = await _openDb();
    final rows = await db.query('cached_posts', orderBy: 'id ASC');
    return rows
        .map((r) => Post.fromJson(
            jsonDecode(r['payload'] as String? ?? '{}') as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveCachedPosts(List<Post> posts) async {
    final db = await _openDb();
    final now = DateTime.now().toIso8601String();
    await db.transaction((txn) async {
      await txn.delete('cached_posts');
      final batch = txn.batch();
      for (final p in posts) {
        batch.insert(
          'cached_posts',
          {'id': p.id, 'payload': jsonEncode(p.toJson()), 'cached_at': now},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }
}

/// ATURAN KONFLIK (didokumentasikan): LAST-WRITE-WINS berdasarkan `updated_at`.
/// Versi dengan updated_at lebih baru menang; jika sama, versi lokal menang.
Note resolveConflict(Note local, Note remote) =>
    remote.updatedAt.isAfter(local.updatedAt) ? remote : local;

/// Sinkronisasi catatan dirty. Server disimulasikan dengan delay 1 detik.
/// Mengembalikan jumlah catatan yang berhasil disinkronkan.
Future<int> syncNotes(NoteRepository repo) async {
  final dirtyCount = await repo.countDirty();
  if (dirtyCount == 0) return 0;
  // Proyek nyata: kirim tiap catatan dirty ke REST API di sini,
  // lalu tandai bersih hanya jika server menjawab 2xx.
  await Future.delayed(const Duration(seconds: 1));
  await repo.markAllSynced();
  return dirtyCount;
}
