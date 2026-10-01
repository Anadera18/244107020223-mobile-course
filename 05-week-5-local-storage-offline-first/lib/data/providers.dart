import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'local/note.dart';
import 'models/post.dart';
import 'prefs.dart';
import 'repositories/note_repository.dart';
import 'repositories/post_repository.dart';
import 'sync.dart';
import 'network_errors.dart';

// ---------------------------------------------------------------- LAB 1
final previousOpenedProvider = Provider<String?>((ref) => null);
final prefsRepositoryProvider = Provider((ref) => PrefsRepository());

final darkModeProvider =
    AsyncNotifierProvider<DarkModeNotifier, bool>(DarkModeNotifier.new);

class DarkModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => ref.watch(prefsRepositoryProvider).getDarkMode();

  Future<void> toggle() async {
    final next = !(state.value ?? false);
    state = await AsyncValue.guard(() async {
      await ref.read(prefsRepositoryProvider).setDarkMode(next);
      return next;
    });
  }
}

// ---------------------------------------------------------------- LAB 2
final noteRepositoryProvider =
    Provider<NoteRepository>((ref) => NoteRepository());

final notesProvider =
    AsyncNotifierProvider<NotesNotifier, List<Note>>(NotesNotifier.new);

class NotesNotifier extends AsyncNotifier<List<Note>> {
  NoteRepository get _repo => ref.read(noteRepositoryProvider);

  @override
  Future<List<Note>> build() => ref.watch(noteRepositoryProvider).fetchNotes();

  Future<void> _reload() async {
    state = await AsyncValue.guard(_repo.fetchNotes);
  }

  Future<void> add(String title, String body) async {
    await _repo.addNote(title: title, body: body);
    await _reload();
  }

  Future<void> edit(Note note) async {
    await _repo.updateNote(note);
    await _reload();
  }

  Future<void> remove(int id) async {
    await _repo.deleteNote(id);
    await _reload();
  }

  /// LAB 3 - sync catatan dirty. Ditolak bila mode offline aktif.
  Future<int> sync() async {
    if (ref.read(forceOfflineProvider)) throw const OfflineException();
    final count = await syncNotes(_repo);
    await _reload();
    return count;
  }
}

/// Detail catatan dibaca dari repository (bukan dari state list).
final noteByIdProvider = FutureProvider.family<Note?, int>((ref, id) {
  ref.watch(notesProvider); // refresh otomatis setelah mutasi
  return ref.read(noteRepositoryProvider).getById(id);
});

/// Jumlah catatan belum tersinkron (badge antrean sync).
final dirtyCountProvider = FutureProvider<int>((ref) async {
  await ref.watch(notesProvider.future);
  return ref.read(noteRepositoryProvider).countDirty();
});

// ---------------------------------------------------------------- LAB 3
/// Toggle offline deterministik untuk demo & testing.
final forceOfflineProvider =
    NotifierProvider<ForceOfflineNotifier, bool>(ForceOfflineNotifier.new);

class ForceOfflineNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void toggle() => state = !state;
}

final postRepositoryProvider = Provider((ref) => PostRepository());
final postCacheProvider = Provider((ref) => PostCache());

final postsProvider =
    AsyncNotifierProvider<PostsNotifier, List<Post>>(PostsNotifier.new);

/// Cache-first: kembalikan cache seketika, refresh jaringan di background.
class PostsNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    final cached = await ref.read(postCacheProvider).readCachedPosts();
    if (cached.isNotEmpty) {
      unawaited(_refreshInBackground());
      return cached;
    }
    return _fetchAndStore(); // pertama kali: wajib ke jaringan
  }

  Future<List<Post>> _fetchAndStore() async {
    if (ref.read(forceOfflineProvider)) throw const OfflineException();
    final fresh = await ref.read(postRepositoryProvider).fetchPosts();
    await ref.read(postCacheProvider).saveCachedPosts(fresh);
    return fresh;
  }

  Future<void> _refreshInBackground() async {
    try {
      final fresh = await _fetchAndStore();
      state = AsyncData(fresh);
    } catch (_) {
      // Gagal refresh? Tetap tampilkan cache lama.
    }
  }
}
