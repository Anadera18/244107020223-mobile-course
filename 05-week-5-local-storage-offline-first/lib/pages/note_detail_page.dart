import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/providers.dart';
import '../widgets/note_dialog.dart';

/// Refactoring #3 - Detail catatan via GoRouter (/note/:id),
/// membaca dari repository lokal, bukan dari state halaman list.
class NoteDetailPage extends ConsumerWidget {
  const NoteDetailPage({super.key, required this.id});
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final note = ref.watch(noteByIdProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail catatan'),
        actions: [
          if (note.value != null) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final n = note.value!;
                final r = await showNoteDialog(context, initial: n);
                if (r != null) {
                  await ref
                      .read(notesProvider.notifier)
                      .edit(n.copyWith(title: r.title, body: r.body));
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await ref.read(notesProvider.notifier).remove(id);
                if (context.mounted) context.pop();
              },
            ),
          ],
        ],
      ),
      body: note.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
        data: (n) {
          if (n == null) {
            return const Center(child: Text('Catatan tidak ditemukan.'));
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(n.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text('Diubah: ${n.updatedAt.toLocal()}'),
                Text(n.dirty ? 'Status: belum tersinkron' : 'Status: tersinkron'),
                const Divider(height: 32),
                Text(n.body.isEmpty ? '(tanpa isi)' : n.body),
              ],
            ),
          );
        },
      ),
    );
  }
}
