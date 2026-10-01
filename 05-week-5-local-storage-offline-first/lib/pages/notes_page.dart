import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/network_errors.dart';
import '../data/providers.dart';
import '../widgets/note_dialog.dart';
import '../widgets/note_tile.dart';

/// LAB 2 + LAB 3 - CRUD catatan offline, badge dirty, tombol sync.
class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  Future<void> _sync(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final n = await ref.read(notesProvider.notifier).sync();
      messenger.showSnackBar(
        SnackBar(content: Text('$n catatan tersinkron')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(friendlyError(e))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);
    final dirty = ref.watch(dirtyCountProvider).value ?? 0;
    final offline = ref.watch(forceOfflineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Notes'),
        actions: [
          IconButton(
            tooltip: offline ? 'Offline (simulasi)' : 'Online',
            icon: Icon(offline ? Icons.airplanemode_active : Icons.wifi),
            onPressed: () => ref.read(forceOfflineProvider.notifier).toggle(),
          ),
          Badge(
            label: Text('$dirty'),
            isLabelVisible: dirty > 0,
            child: IconButton(
              tooltip: 'Sinkronkan',
              icon: const Icon(Icons.sync),
              onPressed: () => _sync(context, ref),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showNoteDialog(context);
          if (result != null) {
            await ref
                .read(notesProvider.notifier)
                .add(result.title, result.body);
          }
        },
        child: const Icon(Icons.add),
      ),
      // Empat state: loading, error (+ retry), empty, success
      body: notes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(friendlyError(e)),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(notesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Belum ada catatan. Tekan +'));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final note = items[i];
              return NoteTile(
                note: note,
                onTap: () => context.push('/note/${note.id}'),
                onDelete: () =>
                    ref.read(notesProvider.notifier).remove(note.id!),
              );
            },
          );
        },
      ),
    );
  }
}
